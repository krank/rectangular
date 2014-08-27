package {
	
	import flash.display.MovieClip;
	
	public class classSolid extends MovieClip {
		
		
		// Things done when the solid object is created
		public function classSolid():void {
			// Add the solid to the static list of solids
			staticLists.solids.push(this);
		}
		
		
		// Empty function used by solids inheriting from the base class
		public function onCreate() {
			
		}
		
	}
	
}