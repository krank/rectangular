package {
	import flash.events.Event;	
	class Parallax extends PhysicalObject {
		
		private var pX:int;
		private var pY:int;
		
		public var multiplier:Number;
		
		override public function onCreate():void {
			// Save initial position
			pX = x;
			pY = y;
			setParallaxMultiplier();
		}

		override public function onEnterFrame(event:Event):void {
			// Negate root's movement
			
			x = pX - (root.x * multiplier);
			y = pY - (root.y * multiplier);
			
		}
		
		// Empty Parallax setter, to be overridden by each parallax subclass
		public function setParallaxMultiplier():void {

		}
		
	}
	
}