package 
{
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	public class classWalker extends classPhysicalObject
	{
		
		// Settings for camera
		public var staticCamera:Boolean = true;
		
		// Keys to use for movement
		public var keyMoveUp:int = Keyboard.W;
		public var keyMoveDown:int = Keyboard.S;
		public var keyMoveLeft:int = Keyboard.A;
		public var keyMoveRight:int = Keyboard.D;
		
		public var walkSpeed:int = 3; // pixels per frame
		
		
		private var keys:Array = [];
		private var newPos:Rectangle;
		private var offsetX:int;
		private var offsetY:int;
		
		
		
		override public function onCreate():void {
			
			// Add event listeners for keyboard
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP,   onKeyUp  );
			
			// Set initial new, suggested position as equal to current position
			
			newPos = this.getBounds(root.stage);
			
			// Set offsets, in case walker has an anchor point that's not in the upper right corner
			offsetX = x - newPos.x;
			offsetY = y - newPos.y;
			
		}
		
		override public function onEnterFrame(event:Event) {
			
			
			getMoveRequest();
			
			// If gravity; apply gravity here?
			
			checkForSolids();
			
			finalizeMovement();
			
		}
		
		
		private function checkForSolids() : void {
			
			this.coord.text = String(newPos);
			
			for each (var solid:classSolid in staticLists.solids) {
				
				var solidRect:Rectangle = solid.getBounds(root.stage);
				
				// Check for intersection
				// Remember: intersects() is much cheaper than intersection().
				
				if (newPos.intersects(solidRect)) {
					
					// For the solids that actually intersect with the avatar, make a proper intersection rectangle
					
					var intersectRect:Rectangle = newPos.intersection(solidRect);
					
					// If the intersection rectangle is a square or wide, use vertical movement
					if (intersectRect.width >= intersectRect.height) {
						if (intersectRect.top == newPos.top) {
							newPos.y += intersectRect.height;
						} else if (intersectRect.bottom == newPos.bottom) {
							newPos.y -= intersectRect.height;
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
					
					
				}
				
				
			}
			
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
		
		private function finalizeMovement() : void {
			
			if (!staticCamera) {
				root.x -= newPos.x - this.x - offsetX;
				root.y -= newPos.y - this.y - offsetY;
			}
			
			this.x = newPos.x + offsetX;
			this.y = newPos.y + offsetY;
		}
		
		
		private function onKeyDown(e:KeyboardEvent) : void {
			keys[e.keyCode] = true;
		}
		
		private function onKeyUp(e:KeyboardEvent) {
			keys[e.keyCode] = false;
		}
		
	}
	
}