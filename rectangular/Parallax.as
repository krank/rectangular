package rectangular {
	
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/* This class enables objects to move relative to the camera. This enables
	 * classic parallax scrolling where objects in the background move slower
	 * and things in the foreground move faster, creating a kind of primitive
	 * pseudo-3d effect. This is also used as the base for the Static class,
	 * which is used for objects that do not move at all.
	 * */
	
	public class Parallax extends MovieClip {
		
		// Used to store the object's origin
		protected var originPoint:Point;
		
		/* Used to store the object's multiplier - how fast or slow it moves
		 * relative to the camera. <1 means it moves slower, >1 means it moves
		 * faster. 1.0 are static objects.
		 * */
		protected var multiplier : Number = 0.5;
		
		// Easily overridden setup method
		protected function setup() : void {
			multiplier = 0.5;
		}
		
		// Constructor
		public function Parallax() : void {

			// Save initial position
			originPoint = new Point(x, y);
			
			// Load settings
			setup();
			
			// Add self to parallax list
			StaticLists.parallax.push(this);
		
		}
		
		// Updates the object's position
		public function update(relativeRoot : Point) {
			// Set the object's x and y related to the root object.
			this.x = (relativeRoot.x + originPoint.x) * multiplier;
			this.y = (relativeRoot.y + originPoint.y) * multiplier;
		}
	
	}

}