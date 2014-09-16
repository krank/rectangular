import rectangular.DynamicObject;
import rectangular.Enemy;
package {
	import flash.display.FrameLabel;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	public class Walker extends DynamicObject {
		
		// Keys to use for movement
		public var keyMoveUp : int;
		public var keyMoveDown : int;
		public var keyMoveLeft : int;
		public var keyMoveRight : int;
		
		public var walkSpeed : Number;
		public var walkSpeedDiagonal : Number;
		
		public var enemyPushback : Number;
		
		public var keys : Array = [];
		
		private var isHurt : Boolean = false;
		private var isDead : Boolean = false;
		
		var directionsDiagonal : Vector.<String> = new Vector.<String>();
		
		override function setup() : void {
			
			cameraFollowHorizontal = true;
			cameraFollowVertical = true;
			
			keyMoveUp = Keyboard.W;
			keyMoveDown = Keyboard.S;
			keyMoveLeft = Keyboard.A;
			keyMoveRight = Keyboard.D;
			
			walkSpeed = 3; // pixels per frame
			
			enemyPushback = 12;
			
			useTeleports = true;
			useKeys = true;
			
			actions.push("idle", "walk", "hurt", "death");
			directions.push("up", "right", "down", "left");
			directionsDiagonal.push("upright", "downright", "downleft", "upleft");
			
			animationAction = "idle";
			animationDirectionHorizontal = directions[0];
		
		}
		
		public function Walker() : void {
			
			// Add event listeners for keyboard
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			
			generateAnimationStates();
			generateAnimationStates(directionsDiagonal);
			
			setAnimationState();
			
			// Use the Pythagorean theorem to calculate diagonal movement
			walkSpeedDiagonal = Number(Math.sqrt(Math.pow(walkSpeed, 2) / 2).toFixed(2));
			//walkSpeedDiagonal = 2.1;
			
			
			
		}
		
		override public function onEnterFrame(event : Event) : void {
			
			newPos = this.getBounds(root);
			
			getMoveRequest();
			
			checkForEnemies();
			
			applyForces();
			
			applyFriction();
			
			checkForSolids();
			checkForTeleports();
			checkForKeys();

			setAnimationState();
			
			finalizeMovement();
			

			if (isHurt && Math.abs(verticalForce) < enemyPushback / 10 && Math.abs(horizontalForce) < enemyPushback / 10) {
				isHurt = false;
			}

		}
		
		private function getMoveRequest() : void {
			
			if (!isHurt && !isDead) {
				
				animationAction = "idle";
				
				// Vertical movement
				
				// DOWN
				if (keys[keyMoveDown] && (keys[keyMoveLeft] || keys[keyMoveRight])) {
					newPos.y += walkSpeedDiagonal;
					animationAction = "walk";
					animationDirectionVertical = "down";
					
				} else if (keys[keyMoveDown] && (!keys[keyMoveLeft] && !keys[keyMoveRight])) {
					newPos.y += walkSpeed;
					animationAction = "walk";
					animationDirectionVertical = "down";
					animationDirectionHorizontal = "";
				}
				
				// UP
				if (keys[keyMoveUp] && (keys[keyMoveLeft] || keys[keyMoveRight])) {
					newPos.y -= walkSpeedDiagonal;
					animationAction = "walk";
					animationDirectionVertical = "up";
					
				} else if (keys[keyMoveUp] && (!keys[keyMoveLeft] && !keys[keyMoveRight])) {
					newPos.y -= walkSpeed;
					animationAction = "walk";
					animationDirectionVertical = "up";
					animationDirectionHorizontal = "";
				}
				
				// Horizontal movement
				
				// RIGHT
				if (keys[keyMoveRight] && (keys[keyMoveUp] || keys[keyMoveDown])) {
					newPos.x += walkSpeedDiagonal;
					animationAction = "walk";
					animationDirectionHorizontal = "right";
					
				} else if (keys[keyMoveRight] && (!keys[keyMoveUp] && !keys[keyMoveDown])) {
					newPos.x += walkSpeed;
					animationAction = "walk";
					animationDirectionHorizontal = "right";
					animationDirectionVertical = "";
				}
				
				// LEFT
				if (keys[keyMoveLeft] && (keys[keyMoveUp] || keys[keyMoveDown])) {
					newPos.x -= walkSpeedDiagonal;
					animationAction = "walk";
					animationDirectionHorizontal = "left";
					
				} else if (keys[keyMoveLeft] && (!keys[keyMoveUp] && !keys[keyMoveDown])) {
					newPos.x -= walkSpeed;
					animationAction = "walk";
					animationDirectionHorizontal = "left";
					animationDirectionVertical = "";
					
				}
				
			} else if (isDead) {
				animationAction = "death";
			} else {
				animationAction = "hurt";
			}
		
		}
		
		override public function hitEnemy(enemy : Enemy) : void {
			var dirVector:Vector.<int> = super.hitEnemy(enemy);
			
			horizontalForce = -dirVector[0] * enemyPushback;
			verticalForce = -dirVector[1] * enemyPushback;
			
			isHurt = true;
			
			// Separate these into "hurt(damage)" method?
			health -= Math.max(0,enemy.damage);
			updateHealthIndicators();
			
			if (health == 0) {
				isDead = true;
			}
		}
		
		private function onKeyDown(e : KeyboardEvent) : void {
			keys[e.keyCode] = true;
		}
		
		private function onKeyUp(e : KeyboardEvent) {
			keys[e.keyCode] = false;
		}
	
	}

}