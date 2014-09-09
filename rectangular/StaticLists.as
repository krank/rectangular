package rectangular {
	
	import rectangular.Enemy;
	import rectangular.Solid;
	
	/* This class mainly facilitates communication between other classes.
	 *
	 * Many classes have constructors which add the created instance to one of
	 * these objects. For instance, all instances of Solid add themselves to
	 * the solids list here.
	 *
	 * This means avatars (Jumpers, Walkers), enemies and others can easily
	 * go through all items of a specific type, checkioong for collisions.
	 *
	 * The static keyword means the lists are connected to the class itself and
	 * that the class doesn't need to be instanced.
	 * */
	
	class StaticLists {
		
		public static var solids : Vector.<Solid> = new Vector.<Solid>();
		
		public static var enemies : Vector.<Enemy> = new Vector.<Enemy>();
		
		public static var parallax : Vector.<Parallax> = new Vector.<Parallax>();
		
		public static var healthIndicators : Vector.<HealthIndicator> = new Vector.<HealthIndicator>();
		
		public static var teleportTargets : Vector.<TeleportTarget> = new Vector.<TeleportTarget>();
		public static var teleportSources : Vector.<TeleportSource> = new Vector.<TeleportSource>();
		
		public static var keys : Vector.<Key> = new Vector.<Key>();
		public static var locks : Vector.<Lock> = new Vector.<Lock>();
		
		public static var sceneNames : Vector.<String> = new Vector.<String>();
		
		/* This function empties all lists except sceneNames.
		 *
		 * This is needed because all lists except sceneNames collect things
		 * that are tied specifically to a a single scene and should be removed
		 * from the lists when the scene is changed. Otherwise, a Jumper might
		 * risk colliding with an object that no longer exists, resulting in
		 * nasty errors.
		 * */
		
		public static function empty() {
			
			/* The splice() method removes all items from the lists, from
			 * index 0 to index "length" - i.e. all indices.
			 * */
			
			StaticLists.solids.splice(0, StaticLists.solids.length);
			
			StaticLists.enemies.splice(0, StaticLists.enemies.length);
			
			StaticLists.parallax.splice(0, StaticLists.parallax.length);
			
			StaticLists.healthIndicators.splice(0, StaticLists.healthIndicators.length);
			
			StaticLists.teleportTargets.splice(0, StaticLists.teleportTargets.length);
			StaticLists.teleportSources.splice(0, StaticLists.teleportSources.length);
			
			StaticLists.keys.splice(0, StaticLists.keys.length);
			StaticLists.locks.splice(0, StaticLists.locks.length);
		
		}
	
	}

}