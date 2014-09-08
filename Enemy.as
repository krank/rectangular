package {
	class Enemy extends DynamicObject {
		
		public var damage:int = 1;
		
		public var isDead : Boolean = false;
		public var isHurt : Boolean = false;
		
		override internal function setup():void 
		{
			healthMax = 1;
		}
		
		public function Enemy() : void {
			StaticLists.enemies.push(this);
			health = healthMax;
		}
		
		public function hurt(damage : int) : void {
			health -= Math.max(0, damage);
			updateHealthIndicators();
			
			isHurt = true;
			if (health == 0) {
				isDead = true;
			}
			
		}
		
	}
}