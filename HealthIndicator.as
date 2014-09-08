package {
	import flash.display.MovieClip;
	
	class HealthIndicator extends MovieClip {
		
		public var targetName : String = "";
		
		public function HealthIndicator() : void {
			targetName = this.name.substr(0, this.name.indexOf("_"))
			
			StaticLists.healthIndicators.push(this);
			
		}
		
		public function setHealth(health:Number, maxHealth:Number) : void {
			// Empty; depends on implementation
		}
		
	}
	
	
}