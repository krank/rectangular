package rectangular {
	
	/* This class extends the generic HealthIndicator class, providing a
	 * working example on how iondicators can work. It overrides the setHealth
	 * method, making the indicator's X-scale vary depending on the health 
	 * values given.
	 * */
	public class HealthScaleX extends HealthIndicator {
		
		override public function setHealth(health : Number, maxHealth : Number) : void {
			
			/* Calculate a number between 0 and 1 based on the ratio between 
			 * health and maxHealth. Uses Math.max to make sure the ratio is 
			 * never below 0 even if the values themselves might suggest such
			 * a ratio.
			 * */
			var scale : Number = Math.max(0, health / maxHealth);
			
			// Apply the ratio.
			this.scaleX = scale;
		
		}
	
	}
}