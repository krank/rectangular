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
			
			useGravity = false;
			
		}
		
		public function Walker():void {
			
			// Add event listeners for keyboard
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP,   onKeyUp  );
			
		}

		override public function onEnterFrame(event:Event):void {
			
			newPos = this.getBounds(root);
			
			getMoveRequest();
			
			// If gravity; apply gravity here?
			
			checkForSolids();
			
			//checkForTeleports();
			
			finalizeMovement();
			
		}
		
		/*

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
		}*/

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