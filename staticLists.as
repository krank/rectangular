package {
	
	class StaticLists {
		public static var solids:Vector.<Solid> = new Vector.<Solid>();
		
		public static var teleportTargets:Vector.<TeleportTarget> = new Vector.<TeleportTarget>();
		public static var teleportSources:Vector.<TeleportSource> = new Vector.<TeleportSource>();
		
		public static function empty() {
			StaticLists.solids.splice(0, StaticLists.solids.length);
			
			StaticLists.teleportTargets.splice(0, StaticLists.teleportTargets.length);
			StaticLists.teleportSources.splice(0, StaticLists.teleportSources.length);
			
		}
		
	}
	
}