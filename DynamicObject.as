package {
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.display.Scene;
	import flash.display.MovieClip;
	
	class DynamicObject extends PhysicalObject {
		
		/* Dynamic objects contain generalized code for gravity
		 * and collisions with other objects.
		 * ie. solids, water, teleport
		 */
		
		public var cameraFollow:Boolean;
		
		public var newPos:Rectangle;
		public var offsetX:int;
		public var offsetY:int;
		
		public var gravityAcceleration:Number;
		public var ppm:int;
		public var gravAccel:Number;
		public var useGravity:Boolean;
		
		public var verticalForce:Number = 0;
		
		public var scene:Scene;
		
		public var sceneNames:Vector.<String> = new Vector.<String>();
		
		function setup():void {
			cameraFollow = false; // Follow camera?
			
			useGravity = true;
			ppm = 15; // Pixels per meter
			gravAccel = 9.8; // meters per second (9.8 default = earth)
		}
		
		function DynamicObject():void {

			setup();
			
			if (useGravity) {
				var fps:Number = root.stage.frameRate;
				
				gravityAcceleration = gravAccel / fps * ppm;
			}
			
			// Set initial new, suggested position as equal to current position
			newPos = this.getBounds(root);
			
			// Set offsets, in case object has an anchor point that's not in the upper right corner
			offsetX = x - newPos.x;
			offsetY = y - newPos.y;
			
			// Find scene, regardless of how deep in the structure the object is
			scene = MovieClip(root).currentScene;
			
			if (StaticLists.sceneNames.length == 0) {
				for each (var s:Scene in MovieClip(root).scenes) {
					StaticLists.sceneNames.push(s.name);
				}
			}
			// Make sure the root stage doesnt focus on anything.
			// Required if entering scene from a SceneButton click.
			root.stage.focus = null;
			
		}
		
		public function finalizeMovement() : void {
			
			// if camera isn't static, move "everything" to make static not change position
			if (cameraFollow) {
				root.x -= newPos.x - this.x + offsetX;
				root.y -= newPos.y - this.y + offsetY;
			}
			
			this.x = newPos.x + offsetX;
			this.y = newPos.y + offsetY;
		}
		
		override public function onEnterFrame(event:Event):void {
			
			newPos = this.getBounds(root);
			
			if (useGravity) {
				verticalForce += gravityAcceleration;
				
				newPos.y += verticalForce;
			}
			
			checkForSolids();
			finalizeMovement();
			
		}
		
		public function checkForSolids() : void {
			
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
							
							if (useGravity) {
								verticalForce = 0;
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
					
					
				}
				
			}

		}
	}
	
}