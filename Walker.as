package 
{
	import flash.display.Scene;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.events.Event;
	import flash.display.MovieClip;
	
	public class Walker extends DynamicObject
	{
		
		// Keys to use for movement
		public var keyMoveUp:int;
		public var keyMoveDown:int;
		public var keyMoveLeft:int;
		public var keyMoveRight:int;
		
		public var walkSpeed:int;
		
		private var keys:Array = [];
		
		override function setup():void {
			
			cameraFollow = false;
			
			keyMoveUp = Keyboard.W;
			keyMoveDown = Keyboard.S;
			keyMoveLeft = Keyboard.A;
			keyMoveRight = Keyboard.D;
			
			walkSpeed = 3; // pixels per frame
			
			useTeleports = true;
			
		}
		
		public function Walker():void {
			
			// Add event listeners for keyboard
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP,   onKeyUp  );
			
		}

		override public function onEnterFrame(event:Event):void {
			
			newPos = this.getBounds(root);
			applyGravity();
			getMoveRequest();

			checkForSolids();
			checkForTeleports();
			
			finalizeMovement();
		}

		private function getMoveRequest() : void {
			
			// Vertical movement
			if ( keys[keyMoveDown] ) {
				newPos.y += walkSpeed;
			}
			if ( keys[keyMoveUp] ) {
				newPos.y -= walkSpeed;
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