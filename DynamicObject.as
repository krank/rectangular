package
{
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.display.Scene;
	import flash.display.MovieClip;
	
	class DynamicObject extends PhysicalObject
	{
		
		/* Dynamic objects contain generalized code for gravity
		 * and collisions with other objects.
		 * ie. solids, water, teleport
		 */
		
		public var cameraFollow:Boolean = false;
		public var useTeleports:Boolean = false;
		public var useKeys:Boolean = false;
		
		public var newPos:Rectangle;
		public var offsetX:Number;
		public var offsetY:Number;
		
		public var gravityAcceleration:Number;
		public var ppm:int = 6;
		public var gravAccel:Number = 9.8;
		public var useGravity:Boolean = false;
		
		public var onGround:Boolean = false;
		
		public var verticalForce:Number = 0;
		public var horizontalForce:Number = 0;

		public var scene:Scene;
		
		public var sceneNames:Vector.<String> = new Vector.<String>();
		
		function setup():void
		{
			cameraFollow = false; // Follow camera?
			
			useGravity = true;
			ppm = 15; // Pixels per meter
			gravAccel = 9.8; // meters per second (9.8 default = earth)
		}
		
		function DynamicObject():void
		{
			
			// Set initial new, suggested position as equal to current position
			newPos = this.getBounds(root);
			
			setup();
			
			if (useGravity)
			{
				var fps:Number = root.stage.frameRate;
				
				fps = 60;
				
				gravityAcceleration = gravAccel / fps * ppm;
			}
			
			// Set offsets, in case object has an anchor point that's not in the upper right corner
			offsetX = x - newPos.x;
			offsetY = y - newPos.y;
			
			// Find scene, regardless of how deep in the structure the object is
			scene = MovieClip(root).currentScene;
			
			if (StaticLists.sceneNames.length == 0)
			{
				for each (var s:Scene in MovieClip(root).scenes)
				{
					StaticLists.sceneNames.push(s.name);
				}
			}
			// Make sure the root stage doesnt focus on anything.
			// Required if entering scene from a SceneButton click.
			root.stage.focus = null;
		
		}
		
		public function finalizeMovement():void
		{
			
			// if camera isn't static, move "everything" to make static not change position
			if (cameraFollow)
			{
				root.x -= newPos.x - this.x + offsetX;
				root.y -= newPos.y - this.y + offsetY;
			}
			
			this.x = newPos.x + offsetX;
			this.y = newPos.y + offsetY;
		}
		
		override public function onEnterFrame(event:Event):void
		{
			
			newPos = this.getBounds(root);
			
			applyGravity();
			applyForces();
			
			checkForTeleports();
			checkForKeys();
			checkForSolids();
			
			finalizeMovement();
		
		}
		
		public function applyGravity():void
		{
			if (useGravity)
			{
				verticalForce += gravityAcceleration;
			}
		}
		
		public function applyInertia():void
		{
			if (!useGravity)
			{
				if (verticalForce > 0) {
					verticalForce -= 1;
				} else if (verticalForce < 0) {
					verticalForce += 1;
				}
			}
			if (!useGravity || onGround) {
				if (horizontalForce > 0) {
					horizontalForce -= 1;
				} else if (horizontalForce < 0) {
					horizontalForce += 1;
				}
			}
		}
		
		public function applyForces():void
		{
			newPos.x += horizontalForce;
			newPos.y += verticalForce;
		}
		
		public function checkForSolids(returnDifference:Boolean = false):Rectangle
		{
			
			if (returnDifference)
			{
				var newPosBefore:Rectangle = newPos.clone();
			}
			
			onGround = false;
			
			for each (var solid:Solid in StaticLists.solids)
			{
				
				var solidRect:Rectangle = solid.getBounds(root);
				
				// Check for intersection
				// Remember: intersects() is much cheaper than intersection().
				if (newPos.intersects(solidRect))
				{
					
					// For the solids that actually intersect with the avatar, make a proper intersection rectangle
					
					var intersectRect:Rectangle = newPos.intersection(solidRect);
					
					// If the intersection rectangle is a square or wide, use vertical movement
					if (intersectRect.width >= intersectRect.height)
					{
						if (intersectRect.top == newPos.top)
						{
							newPos.y += intersectRect.height;
							
							// if gravity is in effect, intersecting with a box above means
							// hitting one's head on something during a jump.
							if (useGravity)
							{
								verticalForce = 0;
							}
						}
						else if (intersectRect.bottom == newPos.bottom)
						{
							newPos.y -= intersectRect.height;
							
							// If gravity is in effect, intersecting with a box below means
							// standing on the ground.
							if (useGravity)
							{
								verticalForce = 0;
								onGround = true;
							}
							
						}
					}
					
					// If the intersection rectangle is a square or high, use horizontal movement
					if (intersectRect.width <= intersectRect.height)
					{
						if (intersectRect.left == newPos.left)
						{
							newPos.x += intersectRect.width;
						}
						else if (intersectRect.right == newPos.right)
						{
							newPos.x -= intersectRect.width;
						}
					}
					
					// Send the solid and the intersection rectangle to the effectSolid method
					effectSolid(solid, solidRect, intersectRect);
					
				}
				
			}
			
			if (returnDifference)
			{
				return new Rectangle(0, 0, newPosBefore.x - newPos.x, newPosBefore.y - newPos.y);
			}
			else
			{
				return null;
			}
		}
		
		public function effectSolid(solid:Solid, solidRect:Rectangle, intersectRect:Rectangle):void {
			// Empty method, used to extend the effect Solids have on the object
		}
		
		public function checkForEnemies():void
		{
			for each (var enemy:Enemy in StaticLists.enemies)
			{
				
				var enemyRect:Rectangle = enemy.getBounds(root);
				
				var xDir:int = 0;
				var yDir:int = 0;
				
				if (newPos.intersects(enemyRect))
				{
					
					var intersectRect:Rectangle = newPos.intersection(enemyRect);
					
					// If the intersection rectangle is a square or wide, use vertical movement
					if (intersectRect.width >= intersectRect.height)
					{
						if (intersectRect.top == newPos.top)
						{
							yDir = -1;
						}
						else if (intersectRect.bottom == newPos.bottom)
						{
							yDir = 1;
							
						}
					}
					
					// If the intersection rectangle is a square or high, use horizontal movement
					if (intersectRect.width <= intersectRect.height)
					{
						if (intersectRect.left == newPos.left)
						{
							xDir = -1;
						}
						else if (intersectRect.right == newPos.right)
						{
							xDir = 1;
						}
					}
					
					applyDamage(enemy, xDir, yDir);
				}
				
			}
		
		}
		
		public function applyDamage(enemy:Enemy, xDir:int, yDir:int) : void {
			
			// Override for specific avatar
			
		}
		
		public function checkForKeys():void
		{
			if (useKeys)
			{
				for each (var key:Key in StaticLists.keys)
				{
					
					var keyRect:Rectangle = key.getBounds(root);
					
					// Check for intersection
					// Remember: intersects() is much cheaper than intersection().
					if (newPos.intersects(keyRect))
					{
						key.unLock();
						
					}
					
				}
			}
		}
		
		public function checkForTeleports():void
		{
			
			if (useTeleports)
			{
				
				// Go through all teleport sources in the scene, check for collision with newPos
				for each (var teleportSource:TeleportSource in StaticLists.teleportSources)
				{
					if (newPos.intersects(teleportSource.getBounds(root.stage)))
					{
						
						var tp:Boolean = false;
						
						// Go through all teleport target symbols in the scene, see if one matches the source's target
						for each (var target:TeleportTarget in StaticLists.teleportTargets)
						{
							if (target.name == teleportSource.targetName)
							{
								
								// The walker's new position should be centered on the target
								newPos.x = target.x + (target.width / 2) - (newPos.width / 2)
								newPos.y = target.y + (target.width / 2) - (newPos.width / 2)
								
								tp = true;
							}
						}
						
						// if no target was found (no teleport took place), see if there's a scene with the proper name
						if (!tp && sceneNames.indexOf(teleportSource.targetName) >= 0)
						{
							
							// Empty the lists, reset camera, move to the scene.
							StaticLists.empty();
							root.x = 0;
							root.y = 0;
							MovieClip(root).gotoAndStop(1, teleportSource.targetName);
							
							break; // Don't go through the rest of the teleport sources
						}
						else if (!tp)
						{
							// If neither target symbol or scene exists, print error to console
							trace("Unable to find teleport target " + teleportSource.targetName);
						}
					}
				}
			}
		}
	}
}