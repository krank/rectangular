package {
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class PhysicalObject extends MovieClip {
		
		function PhysicalObject() : void {
			// Setup events for simple inheritance and use
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
		
		}
		
		// Empty frame updater
		public function onEnterFrame(event : Event) : void {
		
		}
		
		private function onRemove(event : Event) : void {
			this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
	}
}