package {
	import flash.events.Event;	
	
	class Static extends PhysicalObject {
		
		private var pX:int;
		private var pY:int;
		
		override public function onCreate():void {
			// Save initial position
			pX = x;
			pY = y;
		}

		override public function onEnterFrame(event:Event):void {
			// Negate root's movement
			
			x = pX - root.x;
			y = pY - root.y;
		}

	}
	
}