package {
	import flash.display.FrameLabel;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	class Jumper extends DynamicObject {
		
		// Keys to use for movement
		public var keyMoveLeft : int;
		public var keyMoveRight : int;
		public var keyJump : int;
		
		public var walkSpeed : int;
		public var jumpForce : Number;
		public var enemyPushback : Number;
		
		private var jumpKeyReset : Boolean;
		
		private var keys : Array = [];
		private var isHurt : Boolean = false;
		
		override function setup() : void {
			
			cameraFollowHorizontal = true;
			cameraFollowVertical = false;
			
			keyMoveLeft = Keyboard.A;
			keyMoveRight = Keyboard.D;
			keyJump = Keyboard.SPACE;
			
			walkSpeed = 3; // pixels per frame
			jumpForce = 15; // Initial force of jumps
			enemyPushback = 6; // horisontal pushback from hitting enemies
			
			useTeleports = true;
			
			useGravity = true;
			useKeys = true;
			
			actions.push("idle", "walk", "jump", "hurt", "death");
			directions.push("right", "left");
			
			animationAction = "idle";
			animationDirectionHorizontal = "right";

		}
		
		public function Jumper() : void {
			
			// Add event listeners for keyboard
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			
			generateAnimationStates();
			
			setAnimationState();
			
		}
		
		override public function onEnterFrame(event : Event) : void {
			
			newPos = this.getBounds(root);
			
			getMoveRequest();
			applyGravity();
			
			checkForEnemies();
			applyInertia();
			applyForces();
			
			checkForKeys();
			checkForSolids();
			checkForTeleports();
			
			setAnimationState();
			
			finalizeMovement();
			
			if (isHurt && onGround) {
				isHurt = false;
			}
			
			
		
		}
		
		private function getMoveRequest() : void {
			// May only move if not hurt
			if (!isHurt) {
				
				// Jumping
				if (keys[keyJump] && onGround && jumpKeyReset) {
					verticalForce = -jumpForce;
					jumpKeyReset = false;
				}
				
				if (!keys[keyJump] && onGround) {
					jumpKeyReset = true;
					animationAction = "idle";
				}
				
				// Horizontal movement
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
				
				if (!onGround) {
					animationAction = "jump";
				}
				
			} else {
				animationAction = "hurt";
			}
		
		}
		
		override public function applyDamage(enemy : Enemy, xDir : int, yDir : int) : void {
			
			if (enemy.x >= newPos.x) {
				// Enemy is to the right
				horizontalForce = -enemyPushback;
				animationDirectionHorizontal = "right";
			} else {
				// Enemy is to the left
				horizontalForce = enemyPushback;
				animationDirectionHorizontal = "left";
			}
			
			verticalForce = -jumpForce;
			
			isHurt = true;
		}

		private function onKeyDown(e : KeyboardEvent) : void {
			keys[e.keyCode] = true;
		}
		
		private function onKeyUp(e : KeyboardEvent) {
			keys[e.keyCode] = false;
		}
	
	}

}