package {
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	class EnemyPlatformTurner extends EnemyPlatform {
		
		override public function effectSolid(solid:Solid, solidRect:Rectangle, intersectRect:Rectangle):void {
			
			if (moveDirection == 1) {
				if (!solidRect.containsPoint(newPos.bottomRight)) {
					changeDirection()
				}
			} else {
				if (!solidRect.containsPoint(new Point(newPos.left, newPos.right))) {
					changeDirection();
				}
			}
			
		}
		
	}
	
}