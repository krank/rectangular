package
{
	
	class AnimationState
	{
		
		public var sourceFrameName:String;
		public var sourceFrameNumber:int; // Used as fallback
		public var mirror:Boolean;
		public var rotation:int; // should only ever be 0, 90, 180, 270
		
		public function AnimationState(sourceFrameName:String):void
		{
			if (sourceFrameName == "")
			{
				this.sourceFrameNumber = 0;
			}
			
			this.sourceFrameName = sourceFrameName;
		}
		
		public function copy() {
			var n:AnimationState = new AnimationState(sourceFrameName);
			n.mirror = mirror;
			n.rotation = rotation;
			return n;
		}
	
	}

}