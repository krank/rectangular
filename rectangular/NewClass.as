package rectangular {
	
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	import flash.events.Event;

	public class Jumper extends DynamicObject {
		
		// Keys to use for movement
		public var keyMoveLeft : int = Keyboard.A;
		public var keyMoveRight : int = Keyboard.D;
		public var keyJump : int = Keyboard.SPACE;
		
		// Walking speed in pixels
		public var walkSpeed : int = 3;
		
		// Initial force of avatar's jumps in pixels
		public var jumpForce : Number = 15;
		
		// Initial force of enemy pushback
		public var enemyPushback : Number = 6;
		
		
		// Used to store whether or not object may initiate a jump
		private var mayJump : Boolean = false;
		
		// Used to store the currently pressed keys
		public var keys : Array = [];

		// Easily overridable method for simple settings
		override public function setup() : void {
			
			// The camera follows the jumper horizontaly, but not vertically.
			cameraFollowHorizontal = true;
			cameraFollowVertical = false;
			
			// Determine keys to use for moving and jumping.
			keyMoveLeft = Keyboard.A;
			keyMoveRight = Keyboard.D;
			keyJump = Keyboard.SPACE;
			
			// The jumper's walk speed, in pixels per frame
			walkSpeed = 3;
			
			// The initial force of the jumper's jumps, in pixels per frame
			jumpForce = 15;
			
			/* The horizontal pushback the jumper experiences when colliding
			 * with an enemy
			 * */
			enemyPushback = 6; // horisontal pushback from hitting enemies
			
			// The jumper's maximum and initial health
			healthMax = 5;

			// Set default animation action and direction
			animationAction = "idle";
			animationDirectionHorizontal = "right";
			
		}
		
		
		public function Jumper() {
			// Add event listeners for key events
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);

			/* Create the lists of actions and directions used by the
			 * animation system.
			 * */
			actions.push("idle", "walk", "jump", "hurt", "death");
			directions.push("right", "left");

			// Generate animation states
			generateAnimationStates();
			
			// Set animation state based on default action and direction.
			setAnimationState();
		}
		
		// This function runs once every frame.
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
			
			// Apply gravity
			applyGravity();
			
			// Apply horizontal and vertical physical forces
			applyForces();
			
			// Apply friction 
			applyFriction();
			
			/* Check for collisions with keys (for locks), solids, teleports
			 * and enemies.
			 * */
			checkForKeys();
			checkForSolids();
			checkForTeleports();
			checkForEnemies();

			/* If the avatar has landed on the ground after being hurt by an 
			 * enemy, end its Hurt status and stop playing the "hurt"
			 * animation.
			 * */
			if (isHurt && onGround) {
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
				
				/* Check for jumping. Jumping is initiated if the jumper is on
				 * the ground, the jump key is pressed and it has been released
				 * since the last jump.
				 * */
				if (keys[keyJump] && onGround && mayJump) {
					
					// Apply initial jump force to the vertical force
					verticalForce = -jumpForce;
					
					/* Remember that jumping will not be available again until 
					 * the mayJump variable has been set. Landing on the ground
					 * after the jump and still holding down the jump key is
					 * not enough.
					 * */
					mayJump = false;
					
				}
				
				/* If the jumper is on the ground and the jump key is not 
				 * pressed, reset mayJump.
				 * */
				if (!keys[keyJump] && onGround) {
					
					mayJump = true;
					
					// Also set action to idle.
					animationAction = "idle";
					
				}
				
				/* Horizontal movement - check left and right keys. Add or 
				 * subtract walk speed from the provisional movement
				 * rectangle as needed. Set horizontal direction and
				 * action for animation.
				 * */
				if (keys[keyMoveRight]) {
					newPos.x += walkSpeed;
					animationDirectionHorizontal = "right";
					animationAction = "walk";
				}
				if (keys[keyMoveLeft]) {
					newPos.x -= walkSpeed;
					animationDirectionHorizontal = "left";
					animationAction = "walk";
				}
				
				/* Simple logic: if the jumper isn't on the ground, it's either
				 * jumping or falling. The "jump" animation action covers both.
				 * */
				if (!onGround) {
					animationAction = "jump";
				}
			
			// If the jumper is hurt or dead, set the correct animation action.
			} else if (isDead) {
				animationAction = "death";
			} else {
				animationAction = "hurt";
			}
		
		}
		
		// This method is run whenever the jumper hits an enemy.
		override public function hitEnemy(enemy:Enemy):Vector.<int> {
			
			/* Run the dynamicObject's hitEnemy method. It will return the 
			 * direction the enemy, expressed as [xDir:int, yDir:int] where -1 
			 * means top/left, +1 means bottom/right.
			 * */
			var dirVector:Vector.<int> = super.hitEnemy(enemy);
			
			// Apply enemyPushback based on the x-direction of the enemy
			horizontalForce = dirVector[0] * enemyPushback;
			
			/* Set the animation direction of the jumper based on the enemy's 
			 * x-direction 
			 * */
			if (dirVector[0] < 1) {
				animationDirectionHorizontal = "right";
			} else {
				animationDirectionHorizontal = "left";
			}

			// Make the jumper jump involuntarily.
			verticalForce = -jumpForce;
			
			// Set hurt status
			isHurt = true;
			
			/* Subtract enemy's damage from health and update all relevant 
			 * health indicators.
			 * */
			health -= Math.max(0,enemy.damage);
			updateHealthIndicators();
			
			// See if the jumper should die.
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