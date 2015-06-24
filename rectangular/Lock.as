package rectangular {
	import rectangular.StaticLists;
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	
	public class Lock extends MovieClip
	{
		
		protected var lockName:String; // The name of this lock
		
		public function Lock():void
		{
			
			// Generate lockName
			lockName = this.name.substr(0, this.name.indexOf("_"))
			
			// Add this lock to the list of all locks
			StaticLists.locks.push(this);
			
			// Check so lock has the required frame labels
			
			if (this.currentLabels.length > 0)
			{
				var hasLocked:Boolean = false;
				var hasUnlocked:Boolean = false;
				
				for each (var f:FrameLabel in this.currentLabels)
				{
					if (f.name == "locked")
					{
						hasLocked = true;
						this.gotoAndStop("locked");
					}
					if (f.name == "unlocked")
					{
						hasUnlocked = true;
					}
				}
				
			}
			// Give warning if the lock doesn't have both required frame labels
			if (!(hasLocked && hasUnlocked))
			{
				trace("Lock instance " + this.name + " does not have both 'locked' and 'unlocked' frames");
			}
			
			// Stop lock from fluctuating between locked and unlocked states
			this.stop();
		}
		
		public function unLock()
		{
			this.gotoAndStop("unlocked");
		}
		
		public function matchName(name : String) : Boolean {
			return name == this.lockName;
		}
	
	}

}