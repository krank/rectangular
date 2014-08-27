package 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	
	/* TODO:
	 * Gravity, weight
	 * All w/ weight != 0 will check for solids below?
	 */
	
	public class classPhysicalObject extends MovieClip
	{
		function classPhysicalObject():void {
			
			// Setup events for simple inheritance and use
			onCreate();
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
		}
		
		// Empty constructor
		public function onCreate():void {
			
		}
		
		// Empty frame updater
		public function onEnterFrame(event:Event) {
			
		}
	}
}