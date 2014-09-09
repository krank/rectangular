﻿package rectangular {
	
	import fl.motion.MatrixTransformer;
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import flash.display.Scene;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import rectangular.Enemy;
	import rectangular.PhysicalObject;
	import rectangular.Solid;
	import rectangular.StaticLists;
	
	/* This is Rectangular's most complex and comprahensive class. It contains
	 * code for handling:
	 *
	 *  * Movement
	 *  * Animation
	 *  * Collisions (solids, enemies, keys, teleports)
	 *
	 * It is based on Physical Object which means its onEnterFrame will be run
	 * once each frame as long as it exists. It is subclassed by walkers,
	 * jumpers, enemies and bullets - everyone who has reason to move, be
	 * animated, and/or reach to collisions.
	 *
	 * */
	
	class DynamicObject extends PhysicalObject {
		
		/* Determines whether or not the camera should follow the object.
		 *
		 * Usually, only one object is ever followed: the player's avatar.
		 * */
		
		public var cameraFollowHorizontal : Boolean = false;
		public var cameraFollowVertical : Boolean = false;

		/* Used to store the root's "camera" rectangle while updating.
		 * 
		 * Only used if either of the cameraFollow variables is set to True.
		 * */
		public var rootCameraRectangle : Rectangle;
		
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
		
		// Used to remember the object's current and maximum health.
		public var health : Number = 0;
		public var healthMax : Number = 5;
		
		/* ====================================================================
		 *  GRAVITY RELATED VARIABLES
		 */
		
		// Is the object affected by gravity?
		public var useGravity : Boolean = false;
		
		/* Gravity acceleration in pixels per frame. Will be calculated
		 * based on gravityAccelerationReal, the Flash file's frames per
		 * second and pixelsPerMeter if not specified.
		 * */
		public var gravityAcceleration : Number = 0;

		/* What is the gravity acceleration in m/s? Earth default is 9.8.
		 * 
		 * Will only be used to calculate gravityAcceleration if it isn't
		 * specified.
		 * */
		public var gravityAccelerationReal : Number = 9.8;
		
		// Pixels per meter to use in the calculations for gravityAcceleration.
		public var pixelsPerMeter : int = 6;
		
		// Whether or not the object is currently touching the ground.
		public var onGround : Boolean = false;
		
		
		/* ====================================================================
		 *  ANIMATION VARIABLES
		 */
		
		// Vectors containing the object's possible actions/directions for animation
		public var actions : Vector.<String> = new Vector.<String>();
		public var directions : Vector.<String> = new Vector.<String>();
		
		// hash map containing the animation states that are generated
		public var animationStates : Object = {};
		
		// Remembers the current animationState. Used to detect changes.
		public var animationCurrentState : String;
		
		// Remembers the current(latest) animation direction and action, separately.
		public var animationDirectionVertical : String = "";
		public var animationDirectionHorizontal : String = ""
		public var animationAction : String;
		
		public var matrix : Matrix;
		public var degrees : Number = 0;
		public var mirrored : Boolean = false;
		
		/* ====================================================================
		 *  SETUP METHOD
		 */
		
		function setup() : void {
			// Follow camera?
			cameraFollowHorizontal = true;
			cameraFollowVertical = true;
			
			useGravity = true;
			pixelsPerMeter = 15; // Pixels per meter
			gravityAccelerationReal = 9.8; // meters per second (9.8 default = earth)
			
			healthMax = 5;
		}
		
		function DynamicObject() : void {
			
			// Set initial new, suggested position as equal to current position
			newPos = this.getBounds(root);
			
			// Get original matrix, needed for transformations
			matrix = this.transform.matrix;
			
			// Set all settings
			setup();
			
			// Setup health
			
			health = healthMax;
			
			// Setup gravity acceleration
			if (useGravity) {
				var fps : Number = root.stage.frameRate;
				
				fps = 60;
				if (gravityAcceleration == 0) {
					gravityAcceleration = gravityAccelerationReal / fps * pixelsPerMeter;
				}
			}
			
			// Find scene, regardless of how deep in the structure the object is
			
			if (StaticLists.sceneNames.length == 0) {
				for each (var s : Scene in MovieClip(root).scenes) {
					StaticLists.sceneNames.push(s.name);
				}
			}
			
			// Make sure the root stage doesnt focus on anything.
			// Required if entering scene from a SceneButton click.
			
			if (root != null) {
				root.stage.focus = null;
				
				if (cameraFollowHorizontal || cameraFollowVertical) {
					// Create scroll rectangle to hide things not seen by the camera.
					rootCameraRectangle = new Rectangle(-10, -10, root.stage.stageWidth + 20, root.stage.stageHeight + 20);
					root.scrollRect = rootCameraRectangle;
				}
				
			}
			
			// Stop this scene from playing, so next scene isn't loaded automatically.
			this.stop();
		
		}
		
		public function finalizeMovement() : void {
			
			if (hasEventListener(Event.ENTER_FRAME)) {
				var currentPos : Rectangle = this.getBounds(root);
				
				var moveX : Number = newPos.x - currentPos.x;
				var moveY : Number = newPos.y - currentPos.y;
				
				// Move the object. 
				matrix = this.transform.matrix;
				
				matrix.translate(moveX, moveY);
				
				this.transform.matrix = matrix;
				
				// Move the "camera"
				
				if (cameraFollowHorizontal || cameraFollowVertical) {
					
					// The rootCameraRectangle is the visible view of the stage
					if (cameraFollowHorizontal) {
						rootCameraRectangle.x += moveX;
						
					}
					
					if (cameraFollowVertical) {
						rootCameraRectangle.y += moveY;
						
					}
					
					// Apply the new scroll rectangle.
					root.scrollRect = rootCameraRectangle;
					
					// Fix rounding error that appears because scrollRect only handles int's
					
					root.x = (root.scrollRect.x - rootCameraRectangle.x);
					root.y = (root.scrollRect.y - rootCameraRectangle.y);
					
					// Move all static and parallax objects
					
					for each (var parallaxObject : Parallax in StaticLists.parallax) {
						parallaxObject.fix(new Point(root.scrollRect.x - root.x, root.scrollRect.y - root.y));
					}
					
				}
			}
		
		}
		
		override public function onEnterFrame(event : Event) : void {
			
			newPos = this.getBounds(root);
			
			applyGravity();
			applyForces();
			
			checkForTeleports();
			checkForKeys();
			checkForSolids();
			
			finalizeMovement();
		
		}
		
		/* ====================================================================
		 *   ANIMATION METHODS
		 */
		
		public function generateAnimationStates(directionsVector : Vector.<String> = null) : void {
			
			if (directionsVector == null) {
				directionsVector = directions;
			}
			
			// Create list containing the names of all labelled frames
			var labelNames : Vector.<String> = new Vector.<String>();
			
			for each (var f : FrameLabel in this.currentLabels) {
				labelNames.push(f.name);
			}
			
			// If more than two directions are specified, use rotation to
			// generate animation states when corresponding frames are not found
			// Otherwise, just use mirroring.
			// Length is likely always 2 or 4.
			
			var rotation : int;
			var mirror : Boolean;
			
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
			
			for each (var action : String in actions) {
				iDirection = 0;
				for each (var direction : String in directionsVector) {
					stateName = action + "_" + direction;
					
					if (labelNames.indexOf(stateName) >= 0) {
						// State exists. Save it.
						animationStates[stateName] = new AnimationState(stateName);
						
					} else if (iAction == 0 && iDirection == 0) {
						// First of everything. Use default.
						animationStates[stateName] = defaultAnimationState;
						
					} else if (iDirection == 0) {
						// First direction of this action. Use previous action's first direction.
						animationStates[stateName] = animationStates[actions[iAction - 1] + "_" + directionsVector[0]];
						
					} else {
						// In all other cases, use previous direction, rotated.
						
						// make a copy of the previous direction's state
						animationStates[stateName] = animationStates[actions[iAction] + "_" + directionsVector[0]].copy();
						
						// If copies should be mirrored, do so.
						// Otherwise, add rotation.
						if (mirror) {
							animationStates[stateName].mirror = true;
						} else {
							animationStates[stateName].rotation = iDirection * (360 / directionsVector.length);
						}
					}
					
					iDirection++;
				}
				
				iAction++;
			}
		
		}
		
		public function setAnimationState() : void {
			
			// Create 'state' string from action + direction
			var stateName : String = animationAction + "_" + animationDirectionVertical + animationDirectionHorizontal;
			
			// Check to see if the state has changed
			if (stateName != animationCurrentState) {
				
				// Save the new state string
				animationCurrentState = stateName;
				
				// Get the AnimationState to use.
				var s : AnimationState = AnimationState(animationStates[stateName]);
				
				// If the AnimationState is null, no AnimationState corresponding to the 
				// state string has been implemented.
				// Create a new, empty animation state and give an error.
				if (s == null) {
					s = new AnimationState("");
					trace("Animation state " + stateName + " not implemented yet");
				}
				
				// Goto either the named frame or to the specified frame number.
				if (s.sourceFrameName != "") {
					this.gotoAndStop(s.sourceFrameName);
				} else {
					this.gotoAndStop(s.sourceFrameNumber);
				}
				
				// Mirror the object, if the animation state says so and it isn't already
				if (s.mirror != this.mirrored) {
					//this.scaleX = -Math.abs(this.scaleX);
					
					var m : Matrix = this.transform.matrix.clone();
					MatrixTransformer.setScaleX(m, -Math.abs(this.scaleX));
					
					this.transform.matrix = m;
					
					// Remember if the object is currently mirrored.
					this.mirrored = s.mirror;
					
					// Negate offset wonkiness from mirroring
					this.x -= 2 * ((this.width / 2) - (x - this.getBounds(root).x));
					
				}
				
				// Rotate the object, if the animation state says it should be different from what it is.
				if (s.rotation != degrees) {
					
					var degreeChange : int = s.rotation - degrees;
					
					var beforeTransform : Rectangle = this.getBounds(root);
					
					// Clone the original matrix
					var matrixRotate : Matrix = matrix.clone();
					
					// Rotate the matrix around an internal point.
					MatrixTransformer.rotateAroundInternalPoint(matrixRotate, beforeTransform.width / 2, beforeTransform.height / 2, degreeChange);
					
					// Apply the rotated matrix to the object.
					this.transform.matrix = matrixRotate;
					
					// Save the number of degrees
					degrees = s.rotation;
					
					// Negate offset wonkiness from rotation
					var afterTransform : Rectangle = this.getBounds(root);
					
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
		
		public function applyGravity() : void {
			if (useGravity) {
				verticalForce += gravityAcceleration;
			}
		}
		
		public function applyInertia() : void {
			if (!useGravity) {
				if (verticalForce > 0) {
					verticalForce -= 1;
				} else if (verticalForce < 0) {
					verticalForce += 1;
				}
			}
			if (!useGravity || onGround) {
				if (horizontalForce > 0) {
					horizontalForce -= 1;
				} else if (horizontalForce < 0) {
					horizontalForce += 1;
				}
			}
		}
		
		public function applyForces() : void {
			newPos.x += horizontalForce;
			newPos.y += verticalForce;
		}
		
		/* ====================================================================
		 *   COLLISION CHECKING METHODS
		 */
		
		public function checkForSolids(returnDifference : Boolean = false) : Rectangle {
			
			if (returnDifference) {
				var newPosBefore : Rectangle = newPos.clone();
			}
			
			onGround = false;
			
			for each (var solid : Solid in StaticLists.solids) {
				
				var solidRect : Rectangle = solid.getBounds(root);
				
				// Check for intersection
				// Remember: intersects() is much cheaper than intersection().
				if (newPos.intersects(solidRect)) {
					
					// For the solids that actually intersect with the avatar, make a proper intersection rectangle
					
					var intersectRect : Rectangle = newPos.intersection(solidRect);
					
					// If the intersection rectangle is a square or wide, use vertical movement
					if (intersectRect.width >= intersectRect.height) {
						if (intersectRect.top == newPos.top) {
							newPos.y += intersectRect.height;
							
							// if gravity is in effect, intersecting with a box above means
							// hitting one's head on something during a jump.
							if (useGravity) {
								verticalForce = 0;
							}
						} else if (intersectRect.bottom == newPos.bottom) {
							newPos.y -= intersectRect.height;
							
							// If gravity is in effect, intersecting with a box below means
							// standing on the ground.
							if (useGravity && verticalForce > 0) {
								verticalForce = 0;
								onGround = true;
							}
							
						}
					}
					
					// If the intersection rectangle is a square or high, use horizontal movement
					if (intersectRect.width <= intersectRect.height) {
						if (intersectRect.left == newPos.left) {
							newPos.x += intersectRect.width;
						} else if (intersectRect.right == newPos.right) {
							newPos.x -= intersectRect.width;
						}
					}
					
					// Send the solid and the intersection rectangle to the effectSolid method
					effectSolid(solid, solidRect, intersectRect);
					
				}
				
			}
			
			if (returnDifference) {
				return new Rectangle(0, 0, newPosBefore.x - newPos.x, newPosBefore.y - newPos.y);
			} else {
				return null;
			}
		}
		
		public function effectSolid(solid : Solid, solidRect : Rectangle, intersectRect : Rectangle) : void {
			// Empty method, used to extend the effect Solids have on the object
		}
		
		public function checkForEnemies() : void {
			for each (var enemy : Enemy in StaticLists.enemies) {
				
				var enemyRect : Rectangle = enemy.getBounds(root);
				
				var xDir : int = 0;
				var yDir : int = 0;
				
				if (newPos.intersects(enemyRect)) {
					
					var intersectRect : Rectangle = newPos.intersection(enemyRect);
					
					// If the intersection rectangle is a square or wide, use vertical movement
					if (intersectRect.width >= intersectRect.height) {
						if (intersectRect.top == newPos.top) {
							yDir = -1;
						} else if (intersectRect.bottom == newPos.bottom) {
							yDir = 1;
							
						}
					}
					
					// If the intersection rectangle is a square or high, use horizontal movement
					if (intersectRect.width <= intersectRect.height) {
						if (intersectRect.left == newPos.left) {
							xDir = -1;
						} else if (intersectRect.right == newPos.right) {
							xDir = 1;
						}
					}
					
					hitEnemy(enemy, xDir, yDir);
				}
				
			}
		
		}
		
		public function hitEnemy(enemy : Enemy, xDir : int, yDir : int) : void {
		
			// Override for specific avatar/object
		
		}
		
		public function updateHealthIndicators() {
			// Go through all health indicators
			for each (var healthIndicator : HealthIndicator in StaticLists.healthIndicators) {
				// Set health of those connected to this avatar.
				if (healthIndicator.targetName == this.name) {
					healthIndicator.setHealth(health, healthMax);
				}
			}
		}
		
		public function checkForKeys() : void {
			
			for each (var key : Key in StaticLists.keys) {
				
				var keyRect : Rectangle = key.getBounds(root);
				
				// Check for intersection
				// Remember: intersects() is much cheaper than intersection().
				if (newPos.intersects(keyRect)) {
					key.unLock();
				}
				
			}
		
		}
		
		public function checkForTeleports() : void {
			
			// Go through all teleport sources in the scene, check for collision with newPos
			for each (var teleportSource : TeleportSource in StaticLists.teleportSources) {
				if (newPos.intersects(teleportSource.getBounds(root.stage))) {
					
					var tp : Boolean = false;
					
					// Go through all teleport target symbols in the scene, see if one matches the source's target
					for each (var target : TeleportTarget in StaticLists.teleportTargets) {
						if (target.name == teleportSource.targetName) {
							
							// The walker's new position should be centered on the target
							newPos.x = target.x + (target.width / 2) - (newPos.width / 2)
							newPos.y = target.y + (target.width / 2) - (newPos.width / 2)
							
							tp = true;
						}
					}
					
					// if no target was found (no teleport took place), see if there's a scene with the proper name
					if (!tp && StaticLists.sceneNames.indexOf(teleportSource.targetName) >= 0) {
						
						// Empty the lists, reset camera, move to the scene.
						StaticLists.empty();
						
						// Reset the camera
						root.x = 0;
						root.y = 0;
						
						rootCameraRectangle.x = 0;
						rootCameraRectangle.y = 0;
						root.scrollRect = rootCameraRectangle;
						
						MovieClip(root).gotoAndStop(1, teleportSource.targetName);
						
						break; // Don't go through the rest of the teleport sources
					} else if (!tp) {
						// If neither target symbol or scene exists, print error to console
						trace("Unable to find teleport target " + teleportSource.targetName);
					}
				}
			}
		}
	}
}