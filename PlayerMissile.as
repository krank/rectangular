package {
	import flash.events.Event;
	class PlayerMissile extends Missile {
		
		override public function onEnterFrame(event:Event):void 
		{
			super.onEnterFrame(event);
			
			checkForEnemies();
			
		}
		
		override public function hitEnemy(enemy:Enemy, xDir:int, yDir:int):void 
		{
			
			enemy.hurt(damage);
			destroy();
		}
		
		
	}
	
}