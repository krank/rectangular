package rectangular {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	/* This is the base class for all objects that need to run code every
	 * frame. It is by default only subclassed by the DynamicObject class,
	 * which adds further functionality. 
	 * */
	
	public class GameObject extends flash.display.MovieClip {
		
		/* When instanced, the object will connect the ENTER_FRAME and
		 * REMOVED_FROM_STAGE events to methods OnEnterFrame and OnRemove,
		 * respectively. 
		 * */
		function GameObject() : void {
			
			// Setup events for simple inheritance and use
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
		
		}
		
		/* Once each frame, OnEnterFrame() will be run. It is
		 * usually overridden by subclasses and is empty by default.
		 * */
		protected function onEnterFrame(event : Event) : void {
		
		}
		
		/* onRemove() is run when the object is destroyed or removed from
		 * the stage. It removes the connection between ENTER_FRAME and 
		 * onEnterFrame, to make sure there are no calls to the now non-
		 * existant object's methods.
		 * */
		protected function onRemove(event : Event) : void {
			this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		/* onDestroy() is called whenever the object needs to be removed from
		 * the stage. It triggers the REMOVED_FROM_STAGE event automatically.
		 * */
		protected function destroy() {
			
			// Check so object actually has a parent.
			if (parent != null) {
				parent.removeChild(this);
			}
		}
	}
}