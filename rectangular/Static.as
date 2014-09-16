package rectangular {
	
	// This class is used for objects that move with the camera
	public class Static extends Parallax {
		
		// Override the Parallax class' setup method
		override public function setup():void {
			
			// Static objects should move 1x the speed of the camera.
			multiplier = 1.0;
			
		}

	}
	
}