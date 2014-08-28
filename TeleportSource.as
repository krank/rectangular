package {
	import flash.display.MovieClip;
	import flash.display.Scene;
	
	class TeleportSource extends MovieClip {
		
		public var targetName:String = ""; // Instance names should be targetName.unique
		
		var scene:Scene;
		
		function TeleportSource() : void {
			
			// Generate name of teleport target
			
			targetName = this.name.substr(0,this.name.indexOf("_"))
			
			StaticLists.teleportSources.push(this);
			
			scene = MovieClip(root).currentScene;
		}
		
	}
	
	
}