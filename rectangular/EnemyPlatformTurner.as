package rectangular {

	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/* This is a subclass of EnemyPlatform. The main difference is that enemies
	 * based on this class turn when they reach the edge of a solid, which 
	 * means they don't fall off.
	 * */
	public class EnemyPlatformTurner extends EnemyPlatform {

		/* The effectSolid method is called whenever the enemy collides with
		 * an object belonging to the Solid class
		 * */
		override protected function effectSolid(solidBounds : Rectangle) : void 
		{
			/* Do all the normal things DynamicObject descendants to when 
			 * colliding with a Solid
			 * */
			super.effectSolid(solidBounds);
			
			/* If the enemy is currently moving to the right, and the solid 
			 * doesn't contain its lower right corner, then it is about to walk
			 * off the edge - so change direction.
			 * 
			 * If the enemy is currently moving to the left, and the solid
			 * doesn't contain its lower left corner, then it is about to walk
			 * off the edge - so change direction.
			 * */
			if (moveDirection == 1) {
				
				if (!solidBounds.containsPoint(newPos.bottomRight)) {
					changeDirection();
				}
			} else {
				if (!solidBounds.containsPoint(new Point(newPos.left, newPos.bottom))) {
					changeDirection();
				}
			}
		
		}
	
	}

}