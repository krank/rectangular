package {
	import flash.display.MovieClip;
	import flash.display.Scene;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.display.FrameLabel;
	
	class DynamicObject extends PhysicalObject {
		
		/* Dynamic objects contain generalized code for gravity
		 * and collisions with other objects.
		 * ie. solids, water, teleport
		 */
		
		public var cameraFollowHorizontal : Boolean = false;
		public var cameraFollowVertical : Boolean = false;
		
		public var rootCameraRectangle : Rectangle;
		
		public var useTeleports : Boolean = false;
		public var useKeys : Boolean = false;
		
		public var newPos : Rectangle;
		public var offsetX : Number;
		public var offsetY : Number;
		
		public var gravityAcceleration : Number;
		public var ppm : int = 6;
		public var gravAccel : Number = 9.8;
		public var useGravity : Boolean = false;
		
		public var onGround : Boolean = false;
		
		public var verticalForce : Number = 0;
		public var horizontalForce : Number = 0;
		
		public var scene : Scene;
		
		public var sceneNames : Vector.<String> = new Vector.<String>();
		public var labelNames : Vector.<String> = new Vector.<String>();
		
		private var originalY : Number;
		private var originalX : Number;
		
		/* ====================================================================
		 *  ANIMATION VARIABLES
		 */
		
		// Vectors containing the object's possible actions/directions for animation
		var actions : Vector.<String> = new Vector.<String>();
		var directions : Vector.<String> = new Vector.<String>();
		
		// hash map containing the animation states that are generated
		public var animationStates : Object = new Object();
		
		// Remembers the current animationState. Used to detect changes.
		public var animationCurrentState : String;
		
		// Remembers the current(latest) animation direction and action, separately.
		public var animationDirectionVertical : String = "";
		public var animationDirectionHorizontal : String = ""
		public var animationAction : String;
		
		/* ====================================================================
		 *  SETUP METHOD
		 */
		
		function setup() : void {
			// Follow camera?
			cameraFollowHorizontal = true;
			cameraFollowVertical = true;
			
			useGravity = true;
			ppm = 15; // Pixels per meter
			gravAccel = 9.8; // meters per second (9.8 default = earth)
		}
		
		function DynamicObject() : void {
			
			// Set initial new, suggested position as equal to current position
			newPos = this.getBounds(root);
			
			setup();
			
			if (useGravity) {
				var fps : Number = root.stage.frameRate;
				
				fps = 60;
				
				gravityAcceleration = gravAccel / fps * ppm;
			}
			
			// Set offsets, in case object has an anchor point that's not in the upper right corner
			updateOffset();
			
			// Find scene, regardless of how deep in the structure the object is
			scene = MovieClip(root).currentScene;
			
			if (StaticLists.sceneNames.length == 0) {
				for each (var s : Scene in MovieClip(root).scenes) {
					StaticLists.sceneNames.push(s.name);
				}
			}
			// Make sure the root stage doesnt focus on anything.
			// Required if entering scene from a SceneButton click.
			root.stage.focus = null;
			
			// Stop this scene from playing, so next scene isn't loaded automatically.
			this.stop();
			
			if (cameraFollowHorizontal || cameraFollowVertical) {
				// Create scroll rectangle to hide things not seen by the camera.
				rootCameraRectangle = new Rectangle(-10, -10, root.stage.stageWidth+20, root.stage.stageHeight+20);
				root.scrollRect = rootCameraRectangle;
			}
			
			originalY = this.y;
			originalX = this.x;
		
		}
		
		public function updateOffset() : void {
			var p : Rectangle = this.getBounds(root);
			offsetX = x - p.x;
			offsetY = y - p.y;
		}
		
		public function finalizeMovement() : void {
			
			var moveX : Number = newPos.x - this.x;
			var moveY : Number = newPos.y - this.y;
			
			// if camera isn't static, move "everything" to make static not change position
			if (cameraFollowHorizontal) {
				//root.x += moveX;
				rootCameraRectangle.x += moveX;
			}
			
			if (cameraFollowVertical) {
				
				rootCameraRectangle.y += moveY;
					//root.y += moveY;
			}
			
			if (cameraFollowHorizontal || cameraFollowVertical) {
				root.scrollRect = rootCameraRectangle;
				
				/*trace(root.scrollRect.y);
				   trace(this.y);
				   trace(root.y);
				
				 trace("----");*/
				
				//trace(this.y - root.scrollRect.y - originalY + moveY);
				root.x = -(this.x - root.scrollRect.x - originalX + moveX);
				root.y = -(this.y - root.scrollRect.y - originalY + moveY);
			}
			
			/*trace("scrollrect X:" + root.scrollRect.x);
			 trace("scrollrect Y:" + root.scrollRect.y);*/
			root.cacheAsBitmap = false;
			//trace(root.scrollRect.x);
			
			this.x += moveX;
			this.y += moveY;
		
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
				trace("default");
			} else {
				trace("non-default");
			}
			
			// Create list containing the names of all labelled frames
			var labelNames : Vector.<String> = new Vector.<String>();
			
			for each (var f : FrameLabel in this.currentLabels) {
				labelNames.push(f.name);
			}
			
			var rotation : int;
			var mirror : Boolean;
			
			if (directions.length > 2) {
				rotation = (360 / directions.length);
				mirror = false;
			} else {
				mirror = true;
			}
			
			var defaultAnimationState : AnimationState = new AnimationState("");
			
			// Go through each action
			var iAction : int = 0;
			var iDirection : int;
			var stateName : String;
			for each (var action : String in actions) {
				iDirection = 0;
				for each (var direction : String in directionsVector) {
					stateName = action + "_" + direction;
					
					trace(stateName);
					
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
		
		public function setAnimationState() : void // TODO: Figure out how much of this can be generalized.
		{
			
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
				
				// Do mirroring
				var oldScaleX : Number = this.scaleX;
				
				if (s.mirror) {
					this.scaleX = -Math.abs(this.scaleX);
				} else {
					this.scaleX = Math.abs(this.scaleX);
				}

				// If mirroring took place, move the avatar to make up for the flip.
				if (oldScaleX != this.scaleX) {
					updateOffset();
					this.x -= 2 * ((this.width / 2) - offsetX);
					
				}
				
				if (this.rotation != s.rotation) {
					trace("Rotation difference: " + (this.rotation - s.rotation));
					var prePos : Rectangle = this.getBounds(root);
					
					this.rotation = s.rotation;
					
					var postPos : Rectangle = this.getBounds(root);
					
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
					
					applyDamage(enemy, xDir, yDir);
				}
				
			}
		
		}
		
		public function applyDamage(enemy : Enemy, xDir : int, yDir : int) : void {
		
			// Override for specific avatar
		
		}
		
		public function checkForKeys() : void {
			if (useKeys) {
				for each (var key : Key in StaticLists.keys) {
					
					var keyRect : Rectangle = key.getBounds(root);
					
					// Check for intersection
					// Remember: intersects() is much cheaper than intersection().
					if (newPos.intersects(keyRect)) {
						key.unLock();
					}
					
				}
			}
		}
		
		public function checkForTeleports() : void {
			
			if (useTeleports) {
				
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
						if (!tp && sceneNames.indexOf(teleportSource.targetName) >= 0) {
							
							// Empty the lists, reset camera, move to the scene.
							StaticLists.empty();
							root.x = 0;
							root.y = 0;
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
}