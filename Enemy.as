package {
	class Enemy extends DynamicObject {
		
		public function Enemy() : void {
			StaticLists.enemies.push(this);
		}
		
	}
}