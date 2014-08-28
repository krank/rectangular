package {
	
	import flash.display.MovieClip;
	import flash.display.Scene;
	
	public class Solid extends MovieClip {
		
		var scene:Scene;
		
		// Things done when the solid object is created
		public function Solid():void {
			// Add the solid to the static list of solids
			StaticLists.solids.push(this);
			
			scene = MovieClip(root).currentScene;

		}
		
		
		// Empty function used by solids inheriting from the base class
		public function onCreate() {
			
		}
		
	}
	
}