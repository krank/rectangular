package rectangular {
	
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	/* This is a simple class used to create buttons that switch scenes when
	 * pressed.
	 * */
	public class SceneButton extends SimpleButton {
		
		// Used to remember the name of the target scene.
		protected var targetName : String = "";
		
		public function SceneButton() : void {
			
			/* Use an event listener to connect the mouse up event with the
			 * onClick method.
			 * */
			this.addEventListener(MouseEvent.MOUSE_UP, onClick);
			
			/* Get the target name from the name of this button instance.
			 * The name of the instance should be "targetname_uniquename" where
			 * the uniquename is unique to this specific instance.
			 * */
			targetName = this.name.substr(0, this.name.indexOf("_"))
		
		}
		
		private function onClick(e : Event) : void {
			
			// Empty all lists.
			StaticLists.empty();
			
			// Reset root position.
			root.x = 0;
			root.y = 0;
			
			// Reset the root camera rectangle.
			root.scrollRect = new Rectangle(0, 0, root.stage.stageWidth, root.stage.stageHeight);
			
			// Remove the event listener.		
			this.removeEventListener(MouseEvent.MOUSE_UP, onClick);
			
			// Go to the indicated scene.
			MovieClip(root).gotoAndPlay(1, targetName);
		}
	
	}

}