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
			root.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			root.addEventListener(Event.REMOVED_FROM_STAGE, onRemove);

		}
		
		// Empty frame updater
		public function onEnterFrame(event:Event):void {
			
		}
		
		private function onRemove(event:Event):void {
			root.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
	}
}