package rectangular {
	
	import flash.events.Event;
	
	/* This is an example of how to extend the Missile class. It provides a
	 * basic system for damaging enemies.
	 * */
	public class MissilePlayer extends Missile {
		
		override protected function onEnterFrame(event : Event) : void {
			super.onEnterFrame(event);
			
			// Check for enemies
			checkForEnemies();
		
		}
		
		override protected function hitEnemy(enemy:Enemy):Vector.<int> {
			
			// Hurt the enemy using this missile's damage value
			enemy.hurt(damage);
			
			// Destroy the missile
			destroy();
			
			return null;
		}
	
	}

}