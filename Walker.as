package 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Scene;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.events.Event;
	import flash.utils.getTimer;
	import flash.display.MovieClip;
	
	public class Walker extends PhysicalObject
	{
		
		// Settings for camera
		public var staticCamera:Boolean = false;
		
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
		
		private var scene:Scene;
		
		private var sceneNames:Vector.<String> = new Vector.<String>();
		
		
		
		override public function onCreate():void {
			
			// Add event listeners for keyboard
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP,   onKeyUp  );
			
			// Set initial new, suggested position as equal to current position
			
			newPos = this.getBounds(root);
			
			// Set offsets, in case walker has an anchor point that's not in the upper right corner
			offsetX = x - newPos.x;
			offsetY = y - newPos.y;
			
			
			// Find scene, regardless of how deep in the structure the avatar movieclip is
			scene = MovieClip(root).currentScene;
			
			for each (var s:Scene in MovieClip(root).scenes) {
				sceneNames.push(s.name);
			}
			
			// Make sure the root stage doesnt focus on anything.
			// Required if entering scene from a SceneButton click.
			root.stage.focus = null;

		}
		
		override public function onEnterFrame(event:Event):void {
			
			newPos = this.getBounds(root);
			
			getMoveRequest();
			
			// If gravity; apply gravity here?
			
			checkForSolids();
			
			checkForTeleports();
			
			finalizeMovement();
			
		}
		
		
		private function checkForSolids() : void {
			
			for each (var solid:Solid in StaticLists.solids) {
				
				var solidRect:Rectangle = solid.getBounds(root);
				
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
		
		private function checkForTeleports() : void {
			
			// Go through all teleport sources in the scene, check for collision with newPos
			for each (var teleportSource:TeleportSource in StaticLists.teleportSources) {
				if (newPos.intersects(teleportSource.getBounds(root.stage))) {
					
					var tp:Boolean = false;
					
					// Go through all teleport target symbols in the scene, see if one matches the source's target
					for each (var target:TeleportTarget in StaticLists.teleportTargets) {
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
					} else {
						// If neither target symbol or scene exists, print error to console
						trace("Unable to find teleport target " + teleportSource.targetName);
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
			
			// if camera isn't static, move "everything" to make static not change position
			if (!staticCamera) {
				root.x -= newPos.x - this.x + offsetX;
				root.y -= newPos.y - this.y + offsetY;
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