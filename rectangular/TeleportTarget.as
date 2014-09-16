package rectangular {

	import rectangular.StaticLists;
	import flash.display.MovieClip;
	import flash.display.Scene;
	
	/* This class is used to represent teleportation targets - objects that
	 * serve as anchors for teleportation. Their position is used to determine
	 * the new position of the teleported object.
	 * */
	
	public class TeleportTarget extends MovieClip {
		
		var scene:Scene;

		function TeleportTarget() : void {
			
			/* Push a reference to this indicator into the static list of 
			 * teleport targets
			 * */
			StaticLists.teleportTargets.push(this);
			
		}
		
	}
	
	
}