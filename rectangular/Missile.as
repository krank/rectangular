package rectangular {
	
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import rectangular.Solid;
	
	// This is the base class for missiles.
	public class Missile extends DynamicObject {
		
		// The missile's speed in pixels per frame
		public var speed : Number = 7;
		
		// Used to save the missile's calculated speed in x and y directions.
		public var movementVector : Point = new Point();
		
		/* The amount of damage the missile will inflict on any object it hits
		 * (provided said object can be damaged, of course)
		 * */
		public var damage : Number = 1;
		
		// Easily overridable method for simple settings
		override public function setup() : void {
			
			// The missile's speed
			speed = 7;
			
			// The missile's damage
			damage = 1;
		
		}
		
		function Missile() : void {
			setup();
		}
		
		function setDirection(degrees : Number) {
			
			// Save direction.
			this.animationDirectionDegrees = degrees;
			
			// Calculate radians.
			var radians : Number = degrees * Math.PI / 180;
			
			// Calculate movement vector using trigonometry.
			movementVector.x = Math.cos(radians) * speed;
			movementVector.y = Math.sin(radians) * speed;
		
		}
		
		override public function onEnterFrame(event : Event) : void {
			
			/* Saves the current bounds (x,y,width,height), in the form of a
			 * Rectangle instance, in the newPos variable. This is used later
			 * on to apply provisionary changes to the position of the object.
			 * When all variables (solid collisions, gravity) have been
			 * accounted for, the object's position is set to be the same as
			 * the newPos.
			 * */
			newPos = this.getBounds(root);
			
			// Move the missile.
			move();
			
			// Check to see if the missile is colliding with any solids.
			checkForSolids();
			
			// Only continue if the missile hasn't been destroyed.
			if (root != null) {
				
				// Realize the provisional movement
				finalizeMovement();
				
				// If position is outside visible area, destroy the missile.
				if ((newPos.x < root.scrollRect.x - newPos.width * 3) || (newPos.x > root.scrollRect.right + newPos.width * 3)) {
					destroy();
				} else if ((newPos.y < root.scrollRect.y - newPos.height * 3) || (newPos.y > root.scrollRect.bottom + newPos.height * 3)) {
					destroy();
				}
			}
		
		}
		
		override public function effectSolid(solid : Solid) : void {
			// When hitting a solid object, destroy the missile.
			destroy();
		}
		
		public function move() : void {
			
			// Apply movement vector
			newPos.x += movementVector.x;
			newPos.y += movementVector.y;
		
		}
	
	}

}