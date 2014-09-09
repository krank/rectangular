
package {
	import rectangular.StaticLists;
	import flash.display.MovieClip;
	import flash.display.Scene;
	
	class TeleportTarget extends MovieClip {
		
		var scene:Scene;

		function TeleportTarget() : void {
			StaticLists.teleportTargets.push(this);
			
			scene = MovieClip(root).currentScene;
		}
		
	}
	
	
}