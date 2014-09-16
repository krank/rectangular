package rectangular {
	
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import rectangular.Lock;
	import rectangular.StaticLists;
	
	/* This class is used to represent 'keys' - trigger object which change the
	 * animation state of another, connected, object.
	 * */
	
	public class Key extends MovieClip {
		
		// The name shared by the lock(s) to be unlocked by this key
		public var lockName : String;
		
		// whether or not this key has a 'Locked' frame
		private var hasLocked : Boolean = false;
		
		// whether or not this key has an 'Unlocked' frame
		private var hasUnlocked : Boolean = false;
		
		public function Key() : void {
			/* Generate the name of the lock. The key's name should be
			 * "lockname_uniquename" where the uniquename is unique for this
			 * key.
			 * */
			
			lockName = this.name.substr(0, this.name.indexOf("_"))
			
			// Push a reference to this indicator into the static list of keys.
			StaticLists.keys.push(this);
			
			/* Check so key has frame labels for "unlocked" and "locked"
			 * states. "locked" is used as initial visual state. "unlocked" is
			 * triggered when key is picked up.
			 * */
			
			// Check to see if there are any labels at all
			if (this.currentLabels.length > 0) {
				
				// Go through all the labels
				for each (var f : FrameLabel in this.currentLabels) {
					
					/* If the name of the current frame is "locked", remember
					 * that it exists and go to it.
					 * */
					if (f.name == "locked") {
						hasLocked = true;
						this.gotoAndStop("locked");
						
					}
					
					// if the name is "unlocked", remember that it exists.
					if (f.name == "unlocked") {
						hasUnlocked = true;
						
					}
					
				}
				
			}
			
		}
		
		// This method unlocks all locks matching the key.
		public function unLock() : void {
			
			// Find all applicable locks and unlock them if they are found
			for each (var lock : Lock in StaticLists.locks) {
				if (lock.lockName == this.lockName) {
					lock.unLock();
				}
			}
			
			// Regardless, use this key's "unlock" frame, if it exists
			if (hasUnlocked) {
				this.gotoAndStop("unlocked");
			}
		
		}
	
	}

}