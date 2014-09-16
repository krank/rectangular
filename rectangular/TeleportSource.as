package rectangular {
	
	import rectangular.StaticLists;
	import flash.display.MovieClip;
	import flash.display.Scene;
	
	/* This class is used to represent teleportation sources - objects with
	 * which another object (avatar, enemy) can collide with in order to be
	 * transported to another scene or a different position in the current
	 * scene.
	 * */
	
	public class TeleportSource extends MovieClip {
		
		// Used to remember the name of the teleportation target
		public var targetName:String = "";

		function TeleportSource() : void {
			
			/* Get the target name from the name of this indicator. The name of
			 * the indicator should be "targetname_uniquename" where the 
			 * uniquename is unique to this specific indicator.
			 * */
			targetName = this.name.substr(0,this.name.indexOf("_"))
			
			/* Push a reference to this indicator into the static list of 
			 * teleport sources.
			 * */
			StaticLists.teleportSources.push(this);
			
		}
		
	}
	
	
}