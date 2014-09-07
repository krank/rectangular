package {
	import flash.display.MovieClip;
	
	class StaticLists {
		public static var solids : Vector.<Solid> = new Vector.<Solid>();
		
		public static var enemies : Vector.<Enemy> = new Vector.<Enemy>();
		
		public static var parallax : Vector.<Parallax> = new Vector.<Parallax>();
		
		public static var teleportTargets : Vector.<TeleportTarget> = new Vector.<TeleportTarget>();
		public static var teleportSources : Vector.<TeleportSource> = new Vector.<TeleportSource>();
		
		public static var keys : Vector.<Key> = new Vector.<Key>();
		public static var locks : Vector.<Lock> = new Vector.<Lock>();
		
		public static var sceneNames : Vector.<String> = new Vector.<String>();
		
		public static function empty() {
			
			StaticLists.solids.splice(0, StaticLists.solids.length);
			
			StaticLists.teleportTargets.splice(0, StaticLists.teleportTargets.length);
			StaticLists.teleportSources.splice(0, StaticLists.teleportSources.length);
			
			StaticLists.enemies.splice(0, StaticLists.enemies.length);
			StaticLists.keys.splice(0, StaticLists.keys.length);
			StaticLists.locks.splice(0, StaticLists.locks.length);
		
		}
	
	}

}