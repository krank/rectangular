package rectangular {
	
	import fl.motion.MatrixTransformer;
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import flash.display.Scene;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import rectangular.AnimationState;
	import rectangular.HealthIndicator;
	import rectangular.Key;
	import rectangular.Parallax;
	import rectangular.Solid;
	import rectangular.StaticLists;
	import rectangular.TeleportSource;
	import rectangular.TeleportTarget;
	
	/* This is Rectangular's most complex and comprahensive class. It contains
	 * code for handling:
	 *
	 *  * Movement
	 *  * Animation
	 *  * Collisions (solids, enemies, keys, teleports)
	 *  * Health (basics)
	 *
	 * It is based on Physical Object which means its onEnterFrame will be run
	 * once each frame as long as it exists. It is subclassed by walkers,
	 * jumpers, enemies and bullets - everyone who has reason to move, be
	 * animated, and/or reach to collisions.
	 *
	 * */
	
	public class DynamicObject extends GameObject {
		
		/* Determines whether or not the camera should follow the object.
		 * Usually, only one object is ever followed: the player's avatar.
		 * */
		
		public var cameraFollowHorizontal : Boolean = false;
		public var cameraFollowVertical : Boolean = false;
		
		/* Used to store the root's "camera" rectangle while updating. Only
		 * used if either of the cameraFollow variables is set to True.
		 * */
		public static var rootCameraRectangle : Rectangle;
		public static var rootCameraMargin : int = 10;
		
		/* Used to store the object's potential new position while it is
		 * determined whether or not it is legal and how it can be changed in
		 * order to become legal. Legality in this context mostly means it
		 * doesn't overlap solids.
		 * */
		public var newPos : Rectangle;
		
		/* Used to simulate physical forces affecting the object, like gravity
		 * or the upward force of a jump.
		 * */
		public var verticalForce : Number = 0;
		public var horizontalForce : Number = 0;
		
		// Used to remember the names of the object's named frames.
		public var labelNames : Vector.<String> = new Vector.<String>();
		
		/* ====================================================================
		 *  HEALTH RELATED VARIABLES
		 */
		
		// Used to remember the object's current and maximum health.
		protected var health : Number = 0;
		protected var healthMax : Number = 5;
		
		// Used to store whether the object is currently hurt/dead.
		protected var isHurt : Boolean = false;
		protected var isDead : Boolean = false;
		
		/* ====================================================================
		 *  GRAVITY RELATED VARIABLES
		 */
		
		// Is the object affected by gravity?
		protected var useGravity : Boolean = false;
		
		/* Gravity acceleration in pixels per frame. Will be calculated
		 * based on gravityAccelerationReal, the Flash file's frames per
		 * second and pixelsPerMeter if not specified.
		 * */
		protected static var gravityAcceleration : Number = 0;
		
		/* What is the gravity acceleration in m/s? Earth default is 9.8.
		 *
		 * Will only be used to calculate gravityAcceleration if it isn't
		 * specified.
		 * */
		protected static var gravityAccelerationReal : Number = 9.8;
		
		// Pixels per meter to use in the calculations for gravityAcceleration.
		protected var pixelsPerMeter : int = 6;
		
		// Whether or not the object is currently touching the ground.
		protected var onGround : Boolean = false;
		
		// Used to store the frames-per-second used in calculations.
		protected static var fps : Number = 0;
		
		/* ====================================================================
		 *  ANIMATION VARIABLES
		 */
		
		/* These vectors (simple lists) are used to store names of directions
		 * and actions. These are then combined to create frame names such as
		 * walk_right, which are then used to get the correct animation frame
		 * for each given moment.
		 * */
		protected var actions : Vector.<String> = new Vector.<String>();
		protected var directions : Vector.<String> = new Vector.<String>();
		
		/* This hash map / object is used to contain generated animationStates
		 * objects. These are used to remember for instance whether the object
		 * needs to be mirrored or rotated in order for the object to be
		 * displayed correctly.
		 * */
		protected var animationStates : Object = {};
		
		/* This string remembers the current animationState. It is used to
		 * detect changes.
		 * */
		protected var animationCurrentState : String;
		
		/* These strings are used to signal to the animation system which
		 * action direction to combine when deciding which animation state to
		 * show. Horizontal and vertical directions are signalled separately.
		 * */
		protected var animationDirectionVertical : String = "";
		protected var animationDirectionHorizontal : String = "";
		protected var animationAction : String;
		
		/* This number is mostly, if not exclusively, used by topdown enemies
		 * and avatars, and is used to remember the object's latest direction
		 * expressed in degrees of rotation.
		 * */
		protected var animationDirectionDegrees : Number = 0;
		
		/* These variables are used to remember if the object has been
		 * transformed (relative to its original state). Transformation is
		 * normally used in order to generate non-existing animation states
		 * from those who do exist.
		 * */
		protected var matrix : Matrix;
		protected var degrees : Number = 0;
		protected var mirrored : Boolean = false;
		
		/* ====================================================================
		 *  SETUP METHOD
		 * */
		
		/* The setup() method is used to let designers easily tinker with
		 * specific, commonly used settings.
		 *
		 * It is usually overridden by subclasses. These values should be
		 * considered reasonable defaults.
		 * */
		
		protected function setup() : void {
			
			// For most objects, the camera doesn't follow.
			cameraFollowHorizontal = false;
			cameraFollowVertical = false;
			
			/* Most objects are affected by gravity (in a platform game, at
			 * least.
			 * */
			useGravity = true;
			
			pixelsPerMeter = 15;
			gravityAccelerationReal = 9.8; // meters per second (9.8 default = earth)
			
			// Most objects only have a single hit point.
			healthMax = 1;
		}
		
		/* ====================================================================
		 *  BASIC METHODS -- CONSTRUCTOR, MOVEMENT, ONENTERFRAME
		 * */
		
		function DynamicObject() : void {
			
			// Set initial new, suggested position as equal to current position
			newPos = this.getBounds(root);
			
			// Get original matrix, needed for transformations
			matrix = this.transform.matrix;
			
			// Apply settings.
			setup();
			
			// Set current health to maximum
			health = healthMax;
			
			// Calculate gravity acceleration
			if (useGravity) {
				
				// if fps hasn't been set manually, get it from the file.
				if (fps == 0) {
					fps = root.stage.frameRate;
					
				}
				
				/* If gravity acceleration hasn't been set manually, calculate
				 * its value using other values.
				 * */
				if (gravityAcceleration == 0) {
					gravityAcceleration = gravityAccelerationReal / fps * pixelsPerMeter;
					
				}
			}
			
			/* If the static sceneNames list is empty, fill it with the names
			 * of all existing scene names.
			 * */
			if (StaticLists.sceneNames.length == 0) {
				for each (var s : Scene in MovieClip(root).scenes) {
					StaticLists.sceneNames.push(s.name);
					
				}
			}
			
			// Check if root exists
			if (root != null) {
				
				// Make sure the root stage is unfocused.
				root.stage.focus = null;
				
				// Check if the camera should follow along x or y axis
				if (cameraFollowHorizontal || cameraFollowVertical) {
					
					/* Create a rectangle to use as camera viewport into the
					 * scene.
					 *
					 * Objects outside the rectangle will not be rendered.
					 * */
					rootCameraRectangle = new Rectangle(
						-rootCameraMargin, 
						-rootCameraMargin, 
						root.stage.stageWidth  + (rootCameraMargin * 2),
						root.stage.stageHeight + (rootCameraMargin * 2)
					);
					
					// Apply the viewport rectangle
					root.scrollRect = rootCameraRectangle;
					
				}
				
			}
			
			/* Stop this object from playing. Otherwise, it would load its next
			 * frame automatically. The would be less than ideal, since we are
			 * using its different frames to store animation states.
			 * */
			this.stop();
		
		}
		
		// This method is run once every frame. It is usually overridden.
		override protected function onEnterFrame(event : Event) : void {
			
			/* Saves the current bounds (x,y,width,height), in the form of a
			 * Rectangle instance, in the newPos variable. This is used later
			 * on to apply provisionary changes to the position of the object.
			 * When all variables (solid collisions, gravity) have been
			 * accounted for, the object's position is set to be the same as
			 * the newPos.
			 * */
			newPos = this.getBounds(root);
			
			// Apply gravity and other forces.
			applyGravity();
			applyForces();
			
			checkForSolids();
			
			// Finalize movement, as detailed above.
			finalizeMovement();
		
		}
		
		public function finalizeMovement() : void {
			
			/* Only affect changes if the object still has a enter frame
			 * listener. This means it should only update if the object is
			 * still in the scene.
			 * */
			
			if (hasEventListener(Event.ENTER_FRAME)) {
				
				// Make another copy of the current position.
				var currentPos : Rectangle = this.getBounds(root);
				
				/* Subtract the current position's x and y from the x and y of
				 * the newPos to get the amount of x and y movement the object
				 * will be doing.
				 * */
				var moveX : Number = newPos.x - currentPos.x;
				var moveY : Number = newPos.y - currentPos.y;
				
				// Get a copy of the current transform matrix from the object.
				matrix = this.transform.matrix;
				
				// Translate the matrix - i.e. move it.
				matrix.translate(moveX, moveY);
				
				// Reapply it to the object
				this.transform.matrix = matrix;
				
				/* Should the camera follow the object's movement along any
				 * axis?
				 * */
				if (cameraFollowHorizontal || cameraFollowVertical) {
					
					/* Move the camera rectangle by the same number of
					 * pixels as the object moved, along either the x or y
					 * axis, or both.
					 * */
					if (cameraFollowHorizontal) {
						rootCameraRectangle.x += moveX;
					}
					
					if (cameraFollowVertical) {
						rootCameraRectangle.y += moveY;
					}
					
					// Apply the new camera rectangle to root.
					root.scrollRect = rootCameraRectangle;
					
					/* Fix rounding error that appears because scrollRect only
					 * handles integers.
					 * */
					root.x = (root.scrollRect.x - rootCameraRectangle.x) - rootCameraMargin;
					root.y = (root.scrollRect.y - rootCameraRectangle.y) - rootCameraMargin;
					
					// Move all static and parallax objects
					for each (var parallaxObject : Parallax in StaticLists.parallax) {
						parallaxObject.update(new Point(root.scrollRect.x - root.x, root.scrollRect.y - root.y));
					}
					
				}
			}
		
		}
		
		// Update all health indicators that have this object as their target.
		public function updateHealthIndicators() : void {
			// Go through all health indicators
			for each (var healthIndicator : HealthIndicator in StaticLists.healthIndicators) {
				// Set health of those connected to this avatar.
				if (healthIndicator.targetName == this.name) {
					healthIndicator.setHealth(health, healthMax);
				}
			}
		}
		
		/* ====================================================================
		 *   ANIMATION METHODS
		 */
		
		/* Generates "animation states". Each "state" is an instance of the
		 * AnimationState class and includes a referenmce to the name of a
		 * specific existing frame label and information on whether the object
		 * needs to be rotated or mirrored when the the state is activated.
		 *
		 * This is usually called in the object's constructor and may include a
		 * specified vector (list) of directions to be used in addition to the
		 * ones specified in the usual directions vector.
		 * */
		public function generateAnimationStates(directionsVector : Vector.<String> = null) : void {
			
			// If no list of directions was specified, use the default.
			if (directionsVector == null) {
				directionsVector = directions;
				
			}
			
			/* Create list containing the names of all labelled frames inside
			 * the object.
			 * */
			var labelNames : Vector.<String> = new Vector.<String>();
			
			for each (var f : FrameLabel in this.currentLabels) {
				labelNames.push(f.name);
				
			}
			
			/* If more than two directions are specified, use rotation to
			 * generate animation states when corresponding frames are not
			 * found. Otherwise, just use mirroring.
			 *
			 * Length is likely always 2 (platform) or 4 (topdown).
			 * */
			
			// Remembers if mirroring should be used.
			var mirror : Boolean;
			
			// Remembers how much each frame should be rotated.
			var rotation : int;
			
			if (directions.length > 2) {
				rotation = (360 / directions.length);
				mirror = false;
				
			} else {
				mirror = true;
				
			}
			
			// Create the root fallback animation state, in case no defined
			// animation state frames are found.
			var defaultAnimationState : AnimationState = new AnimationState("");
			
			// Go through each action
			var iAction : int = 0;
			var iDirection : int;
			var stateName : String;
			
			/* Go through the list of actions (usually beginning with idle and
			 * including walk, and generate one animation state corresponding
			 * to each direction and that action. If a specified animation
			 * frame doesn't exist, it defaults to the previous one in each
			 * list.
			 *
			 * If directions are ["right", "left"] and actions are
			 * ["idle", "walk"] then idle_left will default to idle_right,
			 * idle_right will default to frame 0. Walk_right will default to
			 * idle_right. This means all specified animation states are always
			 * generated, even if they are all just references to frame 0,
			 * mirrored or rotated (depending on the number of specified
			 * directions).
			 *
			 * */
			
			for each (var action : String in actions) {
				iDirection = 0;
				
				// Go through each direction
				for each (var direction : String in directionsVector) {
					
					// Generate name of animation state to be generated.
					stateName = action + "_" + direction;
					
					if (labelNames.indexOf(stateName) >= 0) {
						/* This should be the normal case. A frame matching the
						 * animation state name is found, so an AnimationState
						 * with neither rotation or mirroring is created based
						 * on it.
						 * */
						animationStates[stateName] = new AnimationState(stateName);
						
					} else if (iAction == 0 && iDirection == 0) {
						/* This is only true in cases where the object doesn't
						 * even have a basic idle_right or idle_up frame label.
						 * Then, an empty animation state is used. It will
						 * default to frame number 0.
						 * */
						animationStates[stateName] = new AnimationState("");
						;
						
					} else if (iDirection == 0) {
						/* The first direction of the current action wasn't
						 * found. Use previous action's first direction.
						 * */
						animationStates[stateName] = animationStates[actions[iAction - 1] + "_" + directionsVector[0]];
						
					} else {
						/* In all other cases, use previous direction, rotated
						 * or mirrored. This is the norm for non-existing
						 * frames.
						 * */
						
						// make a copy of the previous direction's state
						animationStates[stateName] = animationStates[actions[iAction] + "_" + directionsVector[0]].copy();
						
						/* If copies should be mirrored, do so. Otherwise, set
						 * rotation.
						 * */
						if (mirror) {
							animationStates[stateName].mirror = true;
							
						} else {
							animationStates[stateName].rotation = iDirection * (360 / directionsVector.length);
							
						}
					}
					
					// Increase direction index counter
					iDirection++;
				}
				
				// Increase action index counter
				iAction++;
			}
		
		}
		
		/* This method is usually run near the end of the object's OnEnterFrame
		 * method. It uses the current animationAction and animationDirection
		 * values to determine which animationState to show.
		 *
		 * It then makes the object display the frame associated with the state,
		 * and rotates or mirrors the object depending on what its settings are.
		 * */
		public function setAnimationState() : void {
			
			// Create 'state' string from action + direction
			var stateName : String = animationAction + "_" + animationDirectionVertical + animationDirectionHorizontal;
			
			// Check to see if the state has changed
			if (stateName != animationCurrentState) {
				
				// Save the new state string
				animationCurrentState = stateName;
				
				// Get the AnimationState to use.
				var s : AnimationState = AnimationState(animationStates[stateName]);
				
				/* If the AnimationState is null, no AnimationState
				 * corresponding to the state string has been generated.
				 * Create a new, empty animation state and give an error.
				 *
				 * This basically means an action or direction is requested
				 * somewhere in the code, but the lists containing all "valid"
				 * actions and directions has not been updated.
				 * */
				if (s == null) {
					s = new AnimationState("");
					trace("Animation state " + stateName + " not implemented yet");
					
				}
				
				// Goto either the named frame or to the specified frame number.
				if (s.sourceFrameName != "") {
					this.gotoAndStop(s.sourceFrameName);
					
				} else {
					/* This is usually just frame number 0, in cases of extreme
					 * defaulting in the framestate generation process.
					 * */
					
					this.gotoAndStop(s.sourceFrameNumber);
				}
				
				/* Check to see if the object is currently as mirrored as the
				 * animationState says it should be. If it isn't, mirror it.
				 * */
				if (s.mirror != this.mirrored) {
					
					// Create a clone of the current matrix
					var matrixMirror : Matrix = this.transform.matrix.clone();
					
					/* Use the absolute value of the current X-scaling to
					 * create a negative value. i.e. X-scales of +0.5 or -0.5
					 * should both become -0.5 in this process. Negative scaling
					 * means the object is mirrored.
					 *
					 * An already mirrored object which is mirrored again is,
					 * of course, returned to its original form.
					 * */
					MatrixTransformer.setScaleX(matrixMirror, -Math.abs(this.scaleX));
					
					// Apply the mirroring
					this.transform.matrix = matrixMirror;
					
					// Remember the new mirroring state of the object
					this.mirrored = s.mirror;
					
					// Negate offset wonkiness from mirroring
					this.x -= 2 * ((this.width / 2) - (x - this.getBounds(root).x));
					
				}
				
				/* Check to see if the object is currently as rotated as the
				 * animationState says it should be. If it isn't, rotate it.
				 * */
				if (s.rotation != degrees) {
					
					/* Calculate the difference between current rotation and
					 * the one specified by the animationState.
					 * */
					var degreeChange : int = s.rotation - degrees;
					
					// Remember current bounds
					var beforeTransform : Rectangle = this.getBounds(root);
					
					// Clone the original matrix
					var matrixRotate : Matrix = matrix.clone();
					
					// Rotate the matrix around the object's center
					MatrixTransformer.rotateAroundInternalPoint(matrixRotate, beforeTransform.width / 2, beforeTransform.height / 2, degreeChange);
					
					// Apply the rotated matrix to the object.
					this.transform.matrix = matrixRotate;
					
					// Remember the new rotation
					degrees = s.rotation;
					
					// Negate offset wonkiness from rotation
					var afterTransform : Rectangle = this.getBounds(root);
					
					// Fix some camera-related issues.
					if (cameraFollowVertical) {
						rootCameraRectangle.y += afterTransform.y - beforeTransform.y;
					}
					
					if (cameraFollowHorizontal) {
						rootCameraRectangle.x += afterTransform.x - beforeTransform.x;
					}
				}
			}
		}
		
		/* ====================================================================
		 *   PHYSICS METHODS
		 */
		
		/* A simple method that applies gravioty acceleration to the vertical
		 * force affecting the character.
		 * */
		public function applyGravity() : void {
			if (useGravity) {
				verticalForce += gravityAcceleration;
				
			}
		}
		
		/* A simple method for simulating friction. Without it, no non-gravity
		 * related force would ever stop affecting the object.
		 * */
		public function applyFriction() : void {
			
			/* If gravity does not affect the object, then it is likely not
			 * part of a platform game. This means the object is always
			 * considered being "on the ground" and should therefore also
			 * always be affected by friction.
			 * */
			if (!useGravity) {
				
				// Force tends towards 0.
				if (verticalForce > 0) {
					verticalForce -= 1;
					
				} else if (verticalForce < 0) {
					verticalForce += 1;
					
				}
			}
			
			/* Horizontal friction affects the object if it's either standing
			 * on the ground (having fallen to it using gravity) or if gravity
			 * is not in effect.
			 * */
			if (!useGravity || onGround) {
				
				// Force tends towards 0.
				if (horizontalForce > 0) {
					horizontalForce -= 1;
					
				} else if (horizontalForce < 0) {
					horizontalForce += 1;
					
				}
			}
		}
		
		// Apply horizontal and vertical forces to the provisional new position
		public function applyForces() : void {
			newPos.x += horizontalForce;
			newPos.y += verticalForce;
		
		}
		
		/* ====================================================================
		 *   COLLISION CHECKING METHODS
		 */
		
		/* Check for collisions with solids. Call on effectSolid method for
		 * each solid that's actually hit.
		 * */
		
		public function checkForSolids() : void {
			
			// If no solids are collided with then object is not on the ground.
			onGround = false;
			
			// Go through the static list of solids.
			for each (var solid : Solid in StaticLists.solids) {
				
				// Get the bounds of the solid
				var solidRect : Rectangle = solid.getBounds(root);
				
				/* Check for intersection. Uses intersects() instead of
				 * intersection() because the former is much cheaper in terms
				 * of clock cycles than the latter. Only use intersection()
				 * when it is relevant to access the size and shape of the
				 * intersection. Which is only the case for solids we already
				 * know are intersecting the object.
				 * */
				if (newPos.intersects(solidRect)) {
					
					// Send the solid to the effectSolid method. 
					effectSolid(solid);
					
				}
				
			}
		}
		
		protected function effectSolid(solid : Solid) : void {
			
			// Use intersection() to get the size of the intersection
			var intersectRect : Rectangle = newPos.intersection(solid.getBounds(root));
			
			/* If the intersection rectangle is a square or wide, use vertical
			 * movement negation. It means the intersection is either at a
			 * corner (square) or from the top or bottom (wide rectangle).
			 *
			 * Comparing the top, bottom, left hand side and right hand side of
			 * the intersection rectangle and the provisional position
			 * rectangle gives the position of the solid.
			 *
			 * Example: If their top sides coincide, then the solid is above
			 * the object.
			 *
			 * The provisional rectangle is then moved by the width or height
			 * of the intersection rectangle in order to negate the overlap
			 * between the rectangles.
			 *
			 * Then, any lingering vertical or horizontal forces are negated.
			 *
			 * */
			if (intersectRect.width >= intersectRect.height) {
				
				if (intersectRect.top == newPos.top) {
					newPos.y += intersectRect.height;
					
					/* When the object hits its head on a solid, negate its
					 * vertical force.
					 * */
					
					verticalForce = 0;
					
				} else if (intersectRect.bottom == newPos.bottom) {
					newPos.y -= intersectRect.height;
					
					/* when the object is actually falling down on a solid and
					 * connects with it, negate its vertical force and remember
					 * that it's landed on the ground.
					 * */
					if (verticalForce >= 0) {
						verticalForce = 0;
						onGround = true;
						
					}
					
				}
				
			}
			
			/* If the intersection rectangle is a square or a high rectangle,
			 * use horizontal movement negation.
			 * */
			if (intersectRect.width <= intersectRect.height) {
				if (intersectRect.left == newPos.left) {
					
					newPos.x += intersectRect.width;
					horizontalForce = 0;
					
				} else if (intersectRect.right == newPos.right) {
					newPos.x -= intersectRect.width;
					horizontalForce = 0;
				}
			}
		}
		
		/* Check for collisions with enemies. Call on hitEnemy for each enemy
		 * that's actually hit.
		 * */
		public function checkForEnemies() : void {
			
			// Go through the static list of enemies.
			for each (var enemy : Enemy in StaticLists.enemies) {
				
				// Get the bounds of the enemy
				var enemyRect : Rectangle = enemy.getBounds(root);
				
				/* Check for intersection. Uses intersects() instead of
				 * intersection() because the former is much cheaper in terms
				 * of clock cycles than the latter. Only use intersection()
				 * when it is relevant to access the size and shape of the
				 * intersection. Which is almost never the case for enemies.
				 * */
				if (newPos.intersects(enemyRect)) {
					
					// Send the enemy to the hitEnemy method.
					hitEnemy(enemy);
				}
				
			}
		
		}
		
		protected function hitEnemy(enemy : Enemy) : Vector.<int> {
			
			/* These are used to remember the enemy's position relative to the
			 * object. -1 means top/left, +1 means bottom/right.
			 * */
			var xDir : int = 0;
			var yDir : int = 0;
			
			// Get the enemy's bounding rectangle
			var enemyRect : Rectangle = enemy.getBounds(root);
			
			/* Check if the enemy's center x-value is greater than the object's
			 * own center x. If it is, enemy is located to the right. If not, 
			 * it's located to the left.
			 * */
			if (enemyRect.x + enemyRect.width / 2 > newPos.x + newPos.width / 2) {
				xDir = 1
			} else {
				xDir = -1;
			}
			
			/* Check if the enemy's center y-value is greater than the object's
			 * own center y. If it is, enemy is located below the object. If 
			 * not, it's located above.
			 * */
			if (enemyRect.y + enemyRect.height / 2 > newPos.y + newPos.height / 2) {
				yDir = 1
			} else {
				yDir = -1;
			}
			
			// Return direction. Used by overriding methods.
			return new <int>[xDir, yDir];
		
		}
		
		// Look for keys this object collides with.
		public function checkForKeys() : void {
			
			// Go through the static list of keys
			for each (var key : Key in StaticLists.keys) {
				
				// Get the bounds for each key
				var keyRect : Rectangle = key.getBounds(root);
				
				/* Check to see if the provisional position rectangle
				 * intersects with the key's rectangle
				 * */
				if (newPos.intersects(keyRect)) {
					
					// Use the key to immediately unlock all related locks.
					key.unLock();
					
				}
				
			}
		
		}
		
		// Check if the object collides with any teleportation sources
		public function checkForTeleports() : void {
			
			// Go through all teleport sources in the static list
			for each (var teleportSource : TeleportSource in StaticLists.teleportSources) {
				
				// Get the bounds of each teleportation source
				var sourceRect : Rectangle = teleportSource.getBounds(root);
				
				/* Check to see if those bounds intersect the provisionary
				 * movement rectangle
				 * */
				if (newPos.intersects(sourceRect)) {
					
					/* Use this variable to remember whether or not a
					 * teleportation has taken place.
					 * */
					var tp : Boolean = false;
					
					/* Go through all teleport target symbols in the scene, see
					 * if there's one with the same target name as the source.
					 * */
					for each (var target : TeleportTarget in StaticLists.teleportTargets) {
						if (target.name == teleportSource.targetName) {
							
							// The walker's new position should be centered on the target
							newPos.x = target.x + (target.width / 2) - (newPos.width / 2)
							newPos.y = target.y + (target.height / 2) - (newPos.height / 2)
							
							// Remember that a teleportation took place.
							tp = true;
						}
					}
					
					/* if no target with the was found (no teleport took place), see if
					 * there's a scene with the same name as the source's target name.
					 * */
					if (!tp && StaticLists.sceneNames.indexOf(teleportSource.targetName) >= 0) {
						
						/* If trying to teleport to the current scene, stop 
						 * that nonsense and give an informative error. 
						 * */
						if (teleportSource.targetName == MovieClip(root).currentScene.name) {
							trace("Teleportation to current scene not allowed. Use TeleportTarget instance!");
							break;
						}
						
						// Empty the lists
						StaticLists.empty();
						
						// Reset the camera
						root.x = 0;
						root.y = 0;
						
						// Reset the camera rectangle
						rootCameraRectangle.x = 0;
						rootCameraRectangle.y = 0;
						root.scrollRect = rootCameraRectangle;
						
						// Move to the new scene
						MovieClip(root).gotoAndStop(1, teleportSource.targetName);
						
						// Don't go through the rest of the teleport sources
						break;
						
					} else if (!tp) {
						
						/* If neither target symbol or scene exists, write
						 * error to console
						 * */
						trace("Unable to find teleport target " + teleportSource.targetName);
						
					}
				}
			}
		}
	}
}