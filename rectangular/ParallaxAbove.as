package rectangular {
	
	// This class is used for objects that move faster than the camera.
	public class ParallaxAbove extends Parallax {
		
		// Override the Parallax class' setup method
		override protected function setup():void 
		{
			
			// ParallaxAbove objects should move 1.5x the speed of the camera.
			this.multiplier = 1.5;
			
		}
		
	}
	
}