package rectangular {
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	/* This class represents an avatar viewed from a topdown perspective.
	 * It can move in eight different directions and has support for eight
	 * corresponding animation directions. It cannot jump, however.
	 * */
	public class Walker extends DynamicObject {
		
		// Keys to use for movement
		public var keyMoveUp : int = Keyboard.W;
		public var keyMoveDown : int = Keyboard.S;
		public var keyMoveLeft : int = Keyboard.A;
		public var keyMoveRight : int = Keyboard.D;
		
		// Walking speed in pixels
		public var walkSpeed : Number = 3;
		
		// Diagonal walking speed
		public var walkSpeedDiagonal : Number;
		
		// Initial force of enemy pushback
		public var enemyPushback : Number = 10;
		
		// Used to store the currently pressed keys
		public var keys : Array = [];
		
		// Used to store the names of the diagonal directions
		var directionsDiagonal : Vector.<String> = new Vector.<String>();
		
		// Easily overridable method for simple settings
		override public function setup() : void {
			
			// The camera follows the walker both horizontally and vertically.
			cameraFollowHorizontal = true;
			cameraFollowVertical = true;
			
			// Determine keys to use for movement
			keyMoveUp = Keyboard.W;
			keyMoveDown = Keyboard.S;
			keyMoveLeft = Keyboard.A;
			keyMoveRight = Keyboard.D;
			
			// The walker's walk speed, in pixels per frame
			walkSpeed = 3;
			
			/* The horizontal pushback the walker experiences when colliding
			 * with an enemy
			 * */
			enemyPushback = 10;
			
			// Set default animation action and direction
			animationAction = "idle";
			animationDirectionHorizontal = "up";
		
		}
		
		public function Walker() : void {
			
			// Add event listeners for keyboard
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			
			/* Create the lists of actions and directions used by the
			 * animation system.
			 * */
			actions.push("idle", "walk", "hurt", "death");
			directions.push("up", "right", "down", "left");
			directionsDiagonal.push("upright", "downright", "downleft", "upleft");
			
			// Generate animation states, both regular and diagonal
			generateAnimationStates();
			generateAnimationStates(directionsDiagonal);
			
			// Set animation state based on default action and direction.
			setAnimationState();
			
			// Use the Pythagorean theorem to calculate diagonal movement
			walkSpeedDiagonal = Number(Math.sqrt(Math.pow(walkSpeed, 2) / 2).toFixed(2));
		
		}
		
		override public function onEnterFrame(event : Event) : void {
			
			/* Saves the current bounds (x,y,width,height), in the form of a
			 * Rectangle instance, in the newPos variable. This is used later
			 * on to apply provisionary changes to the position of the object.
			 * When all variables (solid collisions, gravity) have been
			 * accounted for, the object's position is set to be the same as
			 * the newPos.
			 * */
			newPos = this.getBounds(root);
			
			// See if the user requests any movement by pressing keys
			getMoveRequest();
			
			// Apply horizontal and vertical physical forces
			applyForces();
			
			// Apply friction 
			applyFriction();
			
			/* Check for collisions with keys (for locks), solids, teleports
			 * and enemies.
			 * */
			checkForSolids();
			checkForTeleports();
			checkForKeys();
			checkForEnemies();
			
			// If avatar is hurt and has been pushed back enough, give back control
			if (isHurt && Math.abs(verticalForce) < enemyPushback / 10 && Math.abs(horizontalForce) < enemyPushback / 10) {
				isHurt = false;
			}
			
			/* Determine the active animation state based on the current
			 * action and direction. These are, in turn, determined by
			 * the methods above, mostly the getMoveRequest.
			 * */
			setAnimationState();
			
			// Apply movement, including camera
			finalizeMovement();
		
		}
		
		/* This method is used to catch the user's keypresses and transform
		 * them into movement of the provisional movement rectangle and the
		 * camera.
		 * */
		private function getMoveRequest() : void {
			
			// May only move if not hurt or dead
			if (!isHurt && !isDead) {
				
				/* If no other action is specified, default animation action
				 * should be 'idle'.
				 * */
				animationAction = "idle";
				
				/* A not on movement code below: there are two possible speeds.
				 * One is used when the walker travels in 90 degree angles (up,
				 * down, left, right). The other is used for diagonal movement.
				 * They are different because the walker should travel the same
				 * amount of pixels in total regardless of direction, but
				 * values are always added to or subtracted from the x and y
				 * axis. If the same walkSpeed was applied in both cases,
				 * diagonal movement would be faster.
				 *
				 * Second note: horizontal and vertical animation direction are
				 * determined separately. Therefore, vertical movement
				 * direction must be emptied when moving morizontally only, and
				 * vice versa.
				 * */
				
				// Check if 'down' key is pressed
				if (keys[keyMoveDown]) {
					animationAction = "walk";
					animationDirectionVertical = "down";
					
					/* Check if 'left' or 'right' keys are also pressed
					 * (diagonal movement).
					 * */
					if (keys[keyMoveLeft] || keys[keyMoveRight]) {
						newPos.y += walkSpeedDiagonal;
						
					} else {
						newPos.y += walkSpeed;
						// Clear horizontal animation direction
						animationDirectionHorizontal = "";
						
					}
				}
				
				// Check if 'up' key is pressed
				if (keys[keyMoveUp]) {
					animationAction = "walk";
					animationDirectionVertical = "up";
					
					/* Check if 'left' or 'right' keys are also pressed
					 * (diagonal movement).
					 * */
					if (keys[keyMoveLeft] || keys[keyMoveRight]) {
						newPos.y -= walkSpeedDiagonal;
						
					} else {
						newPos.y -= walkSpeed;
						// Clear horizontal animation direction
						animationDirectionHorizontal = "";
						
					}
				}
				
				// Check if the 'right' key is pressed
				if (keys[keyMoveRight]) {
					animationAction = "walk";
					animationDirectionHorizontal = "right";
					
					/* Check if the 'up' or 'down' keys are also pressed
					 * (diagonal movement).
					 * */
					if (keys[keyMoveUp] || keys[keyMoveDown]) {
						newPos.x += walkSpeedDiagonal;
						
					} else {
						newPos.x += walkSpeed;
						// Clear vertical animation direction
						animationDirectionVertical = "";
						
					}
					
				}
				
				// Check if the 'left' key is pressed
				if (keys[keyMoveLeft]) {
					animationAction = "walk";
					animationDirectionHorizontal = "left";
					
					/* Check if the 'up' or 'down' keys are also pressed
					 * (diagonal movement).
					 * */
					if (keys[keyMoveUp] || keys[keyMoveDown]) {
						newPos.x -= walkSpeedDiagonal;
						
					} else {
						newPos.x -= walkSpeed;
						// Clear vertical animation direction
						animationDirectionVertical = "";
						
					}
					
				}
				
					// If the walker is hurt or dead, set the correct animation action.
			} else if (isDead) {
				animationAction = "death";
			} else {
				animationAction = "hurt";
			}
		
		}
		
		// This method is run whenever the walker hits an enemy.
		override public function hitEnemy(enemy : Enemy) : Vector.<int> {
			
			/* Run the dynamicObject's hitEnemy method. It will return the
			 * direction the enemy, expressed as [xDir:int, yDir:int] where -1
			 * means top/left, +1 means bottom/right.
			 * */
			var dirVector : Vector.<int> = super.hitEnemy(enemy);
			
			// Apply enemyPushback based on the direction of the enemy
			horizontalForce = -dirVector[0] * enemyPushback;
			verticalForce = -dirVector[1] * enemyPushback;
			
			// Set hurt status
			isHurt = true;
			
			/* Subtract enemy's damage from health and update all relevant
			 * health indicators.
			 * */
			health -= Math.max(0, enemy.damage);
			updateHealthIndicators();
			
			// See if the walker should die.
			if (health == 0) {
				isDead = true;
			}
			
			return null;
		}
		
		/* These methods are run whenever a key is pressed or released.
		 * It saves the state of the key in the keys[] array. true means the
		 * key is currently pressed, false that it is not.
		 * */
		private function onKeyDown(e : KeyboardEvent) : void {
			keys[e.keyCode] = true;
		}
		
		private function onKeyUp(e : KeyboardEvent) {
			keys[e.keyCode] = false;
		}
	
	}

}