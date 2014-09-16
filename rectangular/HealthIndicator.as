package rectangular {
	
	import rectangular.StaticLists;
	import flash.display.MovieClip;
	
	/* This is the base class for all health indicators. It keeps track of 
	 * which object's health the indicator measures and includes an empty
	 * generic method to update the indicator's display.
	 * */
	
	public class HealthIndicator extends MovieClip {
		
		// Used to remember the name of the object whose indicator this is.
		public var targetName : String = "";
		
		
		public function HealthIndicator() : void {
			
			/* Get the target name from the name of this indicator. The name of
			 * the indicator should be "targetname_uniquename" where the 
			 * uniquename is unique to this specific indicator.
			 * */
			targetName = this.name.substr(0, this.name.indexOf("_"))
			
			/* Push a reference to this indicator into the static list of 
			 * health indicators.
			 * */
			StaticLists.healthIndicators.push(this);
			
		}
		
		public function setHealth(health:Number, maxHealth:Number) : void {
			// Empty; depends on implementation
		}
		
	}
	
	
}