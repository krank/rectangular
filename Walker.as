package {
	import flash.display.FrameLabel;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	public class Walker extends DynamicObject {
		
		// Keys to use for movement
		public var keyMoveUp : int;
		public var keyMoveDown : int;
		public var keyMoveLeft : int;
		public var keyMoveRight : int;
		
		public var walkSpeed : int;
		
		public var enemyPushback : int;
		
		private var keys : Array = [];
		
		private var isHurt : Boolean = false;
		
		override function setup() : void {
			
			cameraFollowHorizontal = true;
			cameraFollowVertical = true;
			
			keyMoveUp = Keyboard.W;
			keyMoveDown = Keyboard.S;
			keyMoveLeft = Keyboard.A;
			keyMoveRight = Keyboard.D;
			
			walkSpeed = 3; // pixels per frame
			enemyPushback = 12;
			
			useTeleports = true;
			useKeys = true;
			
			actions.push("idle", "walk", "hurt", "death");
			directions.push("top", "right", "down", "left");
			
			animationAction = "idle";
			animationDirectionHorizontal = actions[0];
		
		}
		
		public function Walker() : void {
			
			// Add event listeners for keyboard
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		
			generateAnimationStates();
			
			setAnimationState();
			
		}
		
		override public function onEnterFrame(event : Event) : void {
			
			newPos = this.getBounds(root);
			
			getMoveRequest();
			
			checkForEnemies();
			
			applyForces();
			
			applyInertia();
			
			checkForSolids();
			checkForTeleports();
			checkForKeys();
			
			finalizeMovement();
			
			if (isHurt && Math.abs(verticalForce) < enemyPushback / 10 && Math.abs(horizontalForce) < enemyPushback / 10) {
				isHurt = false;
			}
			
			setAnimationState();
		
		}
		
		private function getMoveRequest() : void {
			
			if (!isHurt) {
				
				animationAction = "idle";
				
				// Vertical movement
				if (keys[keyMoveDown]) {
					newPos.y += walkSpeed;
					animationAction = "walk";
					animationDirectionVertical = "down";
				}
				if (keys[keyMoveUp]) {
					newPos.y -= walkSpeed;
					animationAction = "walk";
					animationDirectionVertical = "up";
				}
				
				// Horizontal movement
				if (keys[keyMoveRight]) {
					newPos.x += walkSpeed;
					animationAction = "walk";
					animationDirectionHorizontal = "right";
				}
				if (keys[keyMoveLeft]) {
					newPos.x -= walkSpeed;
					animationAction = "walk";
					animationDirectionHorizontal = "left";
				}
				
			}
		
		}
		
		override public function applyDamage(enemy : Enemy, xDir : int, yDir : int) : void {
			horizontalForce = -xDir * enemyPushback;
			verticalForce = -yDir * enemyPushback;
			
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