package {
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	class Missile extends DynamicObject {
		
		public var direction : Number = 0;
		public var speed : Number = 0;
		public var speedX : Number = 0;
		public var speedY : Number = 0;
		
		public var damage : Number = 1;
		
		override function setup() : void {

			speed = 4;
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
			
			finalizeMovement();

		}
		
		override public function effectSolid(solid:Solid, solidRect:Rectangle, intersectRect:Rectangle):void 
		{
			// When hitting a solid object, destroy missile.
			destroy();
		}
		
		public function move() : void {
			newPos.x += speedX;
			newPos.y += speedY;
		}
	
	}

}