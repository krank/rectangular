package rectangular {
	
	/* This class is used to represent an animation state. Each state has an
	 * associated animation frame (referenced by label or number) and
	 * instructions to mirror or rotate it in order to get the desired result.
	 * */
	
	public class AnimationState {
		
		// One of these will be used to remember the animation frame.
		public var sourceFrameName : String;
		public var sourceFrameNumber : int; // Used mainly as fallback
		
		// Actions to take
		public var mirror : Boolean = false;
		public var rotation : int = 0; // should only ever be 0, 90, 180, 270
		
		public function AnimationState(sourceFrameName : String) : void {
			
			// Source frame number is usually only used as a fallback.
			if (sourceFrameName == "") {
				this.sourceFrameNumber = 0;
			}
			
			// Remember the source frame label
			this.sourceFrameName = sourceFrameName;
			
		}
		
		// Used to make a copy of this animation state.
		public function copy() {
			var n : AnimationState = new AnimationState(sourceFrameName);
			n.mirror = mirror;
			n.rotation = rotation;
			
			return n;
		}
	
	}

}