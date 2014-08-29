package {
	import flash.ui.Keyboard
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	class Jumper extends DynamicObject {
		
		// Keys to use for movement
		public var keyMoveLeft:int;
		public var keyMoveRight:int;
		public var keyJump:int;
		
		public var walkSpeed:int;
		public var jumpForce:Number;
		
		private var jumpKeyReset:Boolean;
		
		private var keys:Array = [];
		
		override function setup():void {
			
			cameraFollow = false;
			
			keyMoveLeft = Keyboard.A;
			keyMoveRight = Keyboard.D;
			keyJump = Keyboard.SPACE;
			
			walkSpeed = 3; // pixels per frame
			jumpForce = 15; // Initial force of jumps
			
			useTeleports = true;
			
			useGravity = true;
			
		}
		
		public function Jumper():void {
			
			// Add event listeners for keyboard
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP,   onKeyUp  );
			
		}
		
		override public function onEnterFrame(event:Event):void {
			
			newPos = this.getBounds(root);
			
			getMoveRequest();
			applyGravity();

			checkForSolids();
			checkForTeleports();
			
			finalizeMovement();
		}
		
		private function getMoveRequest() : void {
			trace(verticalForce);
			// Jumping
			if ( keys[keyJump] && onGround && jumpKeyReset) {
				verticalForce = -jumpForce;
				jumpKeyReset = false;
			}
			
			if (!keys[keyJump] && onGround) {
				jumpKeyReset = true;
			}
			
			// Horizontal movement
			if (keys[keyMoveRight]) {
				newPos.x += walkSpeed;
			}
			if (keys[keyMoveLeft]) {
				newPos.x -= walkSpeed;
			}
			
		}
		
		private function onKeyDown(e:KeyboardEvent) : void {
			keys[e.keyCode] = true;
		}
		
		private function onKeyUp(e:KeyboardEvent) {
			keys[e.keyCode] = false;
		}
		
	}
	
}