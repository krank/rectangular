package {
	class Enemy extends DynamicObject {
		
		public var damage:Number = 1;
		
		public function Enemy() : void {
			StaticLists.enemies.push(this);
		}
		
	}
}