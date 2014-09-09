package rectangular {
	
	import flash.display.MovieClip;
	import rectangular.Solid;
	import rectangular.StaticLists;
	
	/* Instances of this class will function as solid objects.
	 * 
	 * Walkers, jumpers, enemies, bullets and others who care about whether or
	 * not they risk colliding, or are colliding alrerady, with a solid object
	 * in the scene will look through the list of Solid instances that is
	 * available in the StaticLists class and decide what to do.
	 * 
	 * The Solid class extends the MovieClass, which means others can get its
	 * coordinates and size without us having to worry about inventing methods
	 * to that effect. It's all built into the MovieClip.
	 * 
	 * The only real difference between a MovieClip and a Solid is that Solids
	 * add themselves to the StaticLists.solids list when they are created.
	 * 
	 * */
	
	public class Solid extends MovieClip {
		
		public function Solid() : void {
			
			// Add the solid to the static list of solids
			StaticLists.solids.push(this);
			
		}
	
	}

}