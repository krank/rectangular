import rectangular.StaticLists;
package {
	import flash.display.Scene;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.MovieClip;
	
	class SceneButton extends SimpleButton {
		
		public var targetName:String = "";
		
		public function SceneButton():void {
			this.addEventListener(MouseEvent.MOUSE_UP, onClick);
			
			targetName = this.name.substr(0, this.name.indexOf("_"))
			
			if (StaticLists.sceneNames.length == 0) {
				for each (var s : Scene in MovieClip(root).scenes) {
					StaticLists.sceneNames.push(s.name);
				}
			}
		}
		
		private function onClick(e:Event):void {
			StaticLists.empty();
			root.x = 0;
			root.y = 0;
			
			// Fix: reset root's scrollRect
			
			this.removeEventListener(MouseEvent.MOUSE_UP, onClick);
			MovieClip(root).gotoAndPlay(1, this.targetName);
		}

		
	}
	
	
}