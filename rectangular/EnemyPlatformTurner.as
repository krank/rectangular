package rectangular {

	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/* This is a subclass of EnemyPlatform. The main difference is that enemies
	 * based on this class turn when they reach the edge of a solid, which 
	 * means they don't fall off.
	 * */
	public class EnemyPlatformTurner extends EnemyPlatform {

		override public function effectSolid(solid:Solid):void 
		{
			super.effectSolid(solid);
			
			var solidRect : Rectangle = solid.getBounds(root);
			
			if (moveDirection == 1) {
				
				if (!solidRect.containsPoint(newPos.bottomRight)) {
					
					changeDirection();
					trace(moveDirection);
				}
			} else {
				if (!solidRect.containsPoint(new Point(newPos.left, newPos.right))) {
					changeDirection();
					trace("hey?");
				}
			}
		
		}
	
	}

}