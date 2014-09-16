import rectangular.HealthIndicator;
package {
	
	class HealthScaleX extends HealthIndicator {
		
		override public function setHealth(health : Number, maxHealth : Number) : void {
			
			var scale : Number = Math.max(0, health / maxHealth);
			
			this.scaleX = scale;
			
		}
	
	}
}