package rectangular {
	
	// This class is used for objects that move faster than the camera.
	public class ParallaxBelow extends Parallax {
		
		// Override the Parallax class' setup method
		override protected function setup():void 
		{

			// ParallaxBelow objects should move 0.5x the speed of the camera.
			this.multiplier = 0.5;
			
		}
		
	}
	
}