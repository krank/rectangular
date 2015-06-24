package rectangular {
	
	import flash.geom.Rectangle;
	
	public class Ramp extends Solid {
		
		// direction. 1 = left to right, -1 right to left
		public var direction : int = 1;
		
		public function Ramp() {
			this.isRamp = true;
		}
		
		override public function getSolidBounds(posX : Number) : Rectangle {
			var bounds : Rectangle = this.getBounds(root);
			
			var maxHeight = this.height;
			var minHeight = 0;
			
			// Clamp & subtract
			
			var posX = Math.max(0, Math.min(posX - bounds.left, bounds.width));
			
			// Calculate new bounds height
			if (direction > 0) {
				var newBoundsHeight = (posX / this.width) * this.height;
			} else {
				var newBoundsHeight = (1 - (posX / this.width)) * this.height;
			}
			
			// Move bounds to compensate and apply new height
			bounds.y += bounds.height - newBoundsHeight;
			bounds.height = newBoundsHeight;
			
			// Return resulting bounds
			return bounds;
			
		}
	}
}