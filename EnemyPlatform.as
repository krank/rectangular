package {
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	public class EnemyPlatform extends Enemy {
		
		public var walkSpeed : Number;
		
		public var moveDirection : int; // 1 = positive movement (right), -1 = negative movement (left). initial value.
		
		override function setup() : void {
			// Follow camera?
			cameraFollowHorizontal = false;
			cameraFollowVertical = false;
			
			useGravity = true;
			ppm = 15; // Pixels per meter
			gravAccel = 9.8; // meters per second (9.8 default = earth)
			
			moveDirection = 1;
			
			walkSpeed = 0.5;
			
			actions.push("walk", "jump", "hurt", "death");
			directions.push("right", "left");
			
			animationAction = "walk";
			animationDirectionHorizontal = "right";
			
		}
		
		public function EnemyPlatform() : void {
			generateAnimationStates();
			
			setAnimationState();
		}
		
		override public function onEnterFrame(e : Event) : void {
			newPos = this.getBounds(root);
			
			applyGravity();
			applyForces();
			
			move();
			
			if (!onGround) {
				animationAction = "jump";
			} else {
				animationAction = "walk";
			}
			
			var r : Rectangle = checkForSolids(true);
			
			if (r.width != 0) {
				changeDirection();
			}
			
			setAnimationState();
			finalizeMovement();
		}
		
		public function move() : void {
			newPos.x += walkSpeed * moveDirection;
		}
		
		public function changeDirection() {
			moveDirection = -moveDirection;
			
			if (moveDirection > 0) {
				animationDirectionHorizontal = "right";
			} else {
				animationDirectionHorizontal = "left";
			}
		}
	
	}

}