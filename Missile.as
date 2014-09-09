import rectangular.DynamicObject;
package {
	import rectangular.Solid;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	class Missile extends DynamicObject {
		
		public var direction : Number = 0;
		public var speed : Number = 0;
		public var speedX : Number = 0;
		public var speedY : Number = 0;
		
		public var damage : Number = 1;
		
		override function setup() : void {
			
			speed = 7;
			damage = 1;
			
			setDirection(45);
		
		}
		
		function Missile() : void {
			setup();
		}
		
		function setDirection(degrees : Number) {
			this.direction = degrees;
			
			var radians : Number = degrees * Math.PI / 180;
			
			speedX = Math.cos(radians) * speed;
			speedY = Math.sin(radians) * speed;
		
		}
		
		override public function onEnterFrame(event : Event) : void {
			newPos = this.getBounds(root);
			
			move();
			
			checkForSolids();
			
			// Only continue if the missile hasn't been destroyed.
			if (root != null) {
				finalizeMovement();
				
				// If position is outside visible area, destroy missile
				if ((newPos.x < root.scrollRect.x - newPos.width * 3) || (newPos.x > root.scrollRect.right + newPos.width * 3)) {
					destroy();
				} else if ((newPos.y < root.scrollRect.y - newPos.height * 3) || (newPos.y > root.scrollRect.bottom + newPos.height * 3)) {
					destroy();
				}
			}
		
		}
		
		override public function effectSolid(solid : Solid, solidRect : Rectangle, intersectRect : Rectangle) : void {
			// When hitting a solid object, destroy missile.
			destroy();
		}
		
		public function move() : void {
			newPos.x += speedX;
			newPos.y += speedY;
		}
	
	}

}