package 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	
	/* TODO:
	 * Gravity, weight
	 * All w/ weight != 0 will check for solids below?
	 */
	
	public class PhysicalObject extends MovieClip
	{

		function PhysicalObject():void {
			// Setup events for simple inheritance and use
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			this.addEventListener(Event.REMOVED, onRemove);

		}
		
		// Empty frame updater
		public function onEnterFrame(event:Event):void {
			
		}
		
		private function onRemove(event:Event):void {
			this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
	}
}