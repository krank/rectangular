package {
	import rectangular.StaticLists;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	class Parallax extends MovieClip {
		
		public var pX : Number;
		public var pY : Number;
		
		public var multiplier : Number;
		
		public static var offsetX = 0;
		public static var offsetY = 0;
		
		public function setup() : void {
			multiplier = 0.5;
		}
		
		public function Parallax() : void {
			// Save initial position
			pX = x;
			pY = y;
			
			setup();
			
			// Add self to parallax list
			StaticLists.parallax.push(this);
		
		}
		
		public function fix(relativeRoot : Point) {
			this.x = (relativeRoot.x + pX) * multiplier;
			this.y = (relativeRoot.y + pY) * multiplier;

		}
	
	}

}