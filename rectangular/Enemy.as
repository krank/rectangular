package rectangular {
	
	import flash.events.Event;
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
	
	public class Enemy extends DynamicObject {
		
		// All enemies damage Jumpers and Walkers. This determines how much.
		public var damage : int = 1;

		/* All enemies have a "hurt" timer, which determines how long they are
		 * incapacitated for when they are hurt.
		 * */
		public var hurtTimer : int = 0;
		public var hurtTimerMax : int = 30;
		
		/* The setup() method is used to let designers easily tinker with
		 * specific, commonly used settings.
		 * It is usually overridden by subclasses. These values should be 
		 * considered reasonable defaults. 
		 * */
		override protected function setup() : void {
			
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
		
		override protected function onEnterFrame(event:Event) : void {
			
			if (hurtTimer > 0) {
				hurtTimer -= 1;
				isHurt = true;
			} else {
				isHurt = false;
			}
			
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
			
			// Set up hurt timer
			hurtTimer = hurtTimerMax;
			
			/* Set dead status, if applicable. Let each subclass determine what
			 * death means for the enemy instance.
			 * */
			
			if (health == 0) {
				isDead = true;
			}
		
		}
	
	}
}