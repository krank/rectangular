package {
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	public class EnemyTopdown extends Enemy {
		
		public var walkSpeed : Number = 1;
		
		public var walkTimer : int = 0;
		public var walkTimerMax : int = 0;
		
		public var pauseTimer : int = 0;
		public var pauseTimerMax : int = 0;
		
		public var moveX : Number = 0;
		public var moveY : Number = 0;
		
		var directionsDiagonal : Vector.<String> = new Vector.<String>();
		
		override function setup() : void {
			walkSpeed = 0.5; // Pixels per frame
			
			walkTimerMax = (newPos.width + newPos.height) / 2 // Number of frames of movement
			
			// setting walkTimerMax to average of height and width means the enemy will move 
			// its walkSpeed times its size before changing direction. In this case, it will
			// walk 0.5x its size before pausing for a bit.
			
			pauseTimerMax = walkTimerMax / 2
			
			actions.push("idle", "walk", "hurt");
			directions.push("up", "right", "down", "left");
			directionsDiagonal.push("upright", "downright", "downleft", "upleft");
			
			animationAction = "idle";
			animationDirectionHorizontal = directions[0];
			
			damage = 1;
			healthMax = 1;
		
		}
		
		function EnemyTopdown() : void {
			
			generateAnimationStates();
			generateAnimationStates(directionsDiagonal);
			
			selectNewDirection();
			
			setAnimationState();
		}
		
		override public function onEnterFrame(e : Event) : void {
			newPos = this.getBounds(root);
			
			move();
			
			// Check for collisions with solids
			var r : Rectangle = checkForSolids(true);
			
			// if there's a collision, select a new direction
			if (r.width != 0 || r.height != 0) {
				selectNewDirection();
			}
			
			setAnimationState();
			finalizeMovement();
		}
		
		public function move() : void {
			
			if (!isDead && !isHurt) {
			
				// Walk, if timer hasn't reached 0.
				if (walkTimer > 0) {
					// Subtract from timer
					walkTimer -= 1;
					
					// Move the enemy
					newPos.x += moveX;
					newPos.y += moveY;
					
				// If the walk timer has reached zero, take a break
				} else if (pauseTimer > 0) {
					// Subtract from timer
					pauseTimer -= 1;
					
				} else {
					// When both timers have reached 0, select a new direction
					selectNewDirection();
					
				}
			} else if (isDead) {
				trace("DEAD");
				destroy();
			} else {
				animationAction = "hurt";
			}
		
		}
		
		function selectNewDirection() : void {
			// Reset walk and pause timers
			walkTimer = walkTimerMax;
			pauseTimer = pauseTimerMax;
			
			var d : int = Math.floor(Math.random() * 8) * 45; // randomize a 45 degree angle between 0 and 315
			var r : Number = d * Math.PI / 180; // Convert angle to radians
			
			// use trigonomy to create x and y movement per frame from angle & walk speed
			moveX = Math.cos(r) * walkSpeed;
			moveY = Math.sin(r) * walkSpeed;
			
			// use generated direction to select animation direction
			if (d == 315 || d == 0 || d == 45) {
				animationDirectionVertical = "up";
				
			} else if (d == 135 || d == 180 || d == 225) {
				animationDirectionVertical = "down";
				
			} else {
				animationDirectionVertical = "";
				
			}
			
			if (d == 45 || d == 90 || d == 135) {
				animationDirectionHorizontal = "right";
				
			} else if (d == 225 || d == 270 || d == 315) {
				animationDirectionHorizontal = "left";
				
			} else {
				animationDirectionHorizontal = "";
				
			}
		
		}
	
	}
}