package rectangular {
	
	import rectangular.DynamicObject;
	import rectangular.StaticLists;
	
	/* This is the base class for all enemies, whether they are platformers or
	 * topdowners.
	 * 
	 * Walkers, jumpers and others who care about whether or not they risk
	 * colliding, or are colliding alrerady, with an enemy in the scene will
	 * through the list of instances of Enemy or any subclass thereof in the
	 * static StaticLists.enemies list.
	 * 
	 * The Enemy class extends DynamicObject, which means the designer of an
	 * Enemy subclass has access to a rich array of tools for creating 
	 * dynamic actors in any given scene.
	 * 
	 * */
	
	class Enemy extends DynamicObject {
		
		// All enemies damage Jumpers and Walkers. This determines how much.
		public var damage : int = 1;
		
		// These are used to keep track of the enemy's current status.
		public var isDead : Boolean = false;
		public var isHurt : Boolean = false;
		
		
		/* The setup() method is used to let designers easily tinker with
		 * specific, commonly used settings.
		 * 
		 * It is usually overridden by subclasses. These values should be considered
		 * reasonable defaults. 
		 * */
		public function setup() : void {
			
			// The camera almost never follow enemies.
			cameraFollowHorizontal = false;
			cameraFollowVertical = false;
			
			// Most enemies  die on the first hit.
			healthMax = 1;
			
			// Most enemies give 1 damage to avatars.
			damage = 1;
			
		}
		
		public function Enemy() : void {
			
			// Add the instance to the static list of enemies.
			StaticLists.enemies.push(this);
			
			// Set enemy instance's current health to maximum.
			health = healthMax;
			
		}
		
		
		// This method is used to apply damage to the enemy
		public function hurt(damage : int) : void {
			
			/* Subtract incoming damage from enemy's health, but don't allow
			 * health to slip below 0.
			 * */
			health = Math.max(0, health - damage);
			
			/* Update any health indicators that happen to share the name of
			 * this enemy.
			 * */
			updateHealthIndicators();
			
			// Set hurt status, for animation state purposes.
			isHurt = true;
			
			/* Set dead status, if applicable. Let each subclass determine what
			 * death means for the enemy instance.
			 * */
			
			if (health == 0) {
				isDead = true;
			}
		
		}
	
	}
}