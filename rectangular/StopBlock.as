package rectangular {
	import flash.display.MovieClip;

	/* This is an extremely simple class, used to stop the playback of the
	 * current object without the user having to write a single line of code.
	 * */
	
	public class StopBlock extends MovieClip {
		
		public function StopBlock(){
			MovieClip(parent).stop();
		}
		
	}

}