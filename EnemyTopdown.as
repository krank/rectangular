package
{
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	public class EnemyTopdown extends Enemy
	{
		
		public var walkSpeed:Number;
		
		public var walkTimer:int;
		public var walkTimerMax:int;
		
		public var pauseTimer:int;
		public var pauseTimerMax:int;
		
		public var moveX:Number;
		public var moveY:Number;
		
		override function setup():void
		{
			walkSpeed = 0.5; // Pixels per frame
			
			walkTimerMax = (newPos.width + newPos.height) / 2 // Number of frames of movement
			
			// setting walkTimerMax to average of height and width means the enemy will move 
			// its walkSpeed times its size before changing direction. In this case, it will
			// walk 0.5x its size before pausing for a bit.
			
			pauseTimerMax = walkTimerMax / 2
		
		}
		
		function EnemyTopdown():void
		{
			selectNewDirection();
		}
		
		override public function onEnterFrame(e:Event):void
		{
			newPos = this.getBounds(root);
			
			move();
			var r:Rectangle = checkForSolids(true);
			
			if (r.width != 0 || r.height != 0)
			{
				selectNewDirection();
			}
			
			finalizeMovement();
		}
		
		public function move():void
		{
			
			if (walkTimer > 0)
			{
				walkTimer -= 1;
				
				newPos.x += moveX;
				newPos.y += moveY;
			}
			else if (pauseTimer > 0)
			{
				pauseTimer -= 1;
			}
			else
			{
				selectNewDirection();
			}
		
		}
		
		function selectNewDirection():void
		{
			walkTimer = walkTimerMax;
			pauseTimer = pauseTimerMax;
			
			var d:Number = Math.floor(Math.random() * 8) * 45; // randomize a 45 degree angle between 0 and 315
			var r:Number = d * Math.PI / 180; // Convert angle to radians
			
			// use trigonomy to create x and y movement per frame from angle & walk speed
			moveX = Math.cos(r) * walkSpeed;
			moveY = Math.sin(r) * walkSpeed;
		}
	
	}
}