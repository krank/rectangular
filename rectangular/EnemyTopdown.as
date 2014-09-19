package rectangular {
	
	import flash.events.Event;
	import flash.geom.Point;
	
	/* This class is used for enemies seen from a topdown perspective. They are
	 * unaffected by gravity. They walk around more or less randomly - they
	 * choose a direction, walk along it for a certain amount of time, then
	 * they pause for a bit, then choose a new direction. By default, they only
	 * use the same eight directions as the Walker class.
	 * They also change directions when colliding with a wall, and they
	 * normally deal 1 point of damage to avatars who collide with them.
	 * */
	public class EnemyTopdown extends Enemy {
		
		// Enemy walk speed
		public var walkSpeed : Number = 1;
		
		// Timers keeping track of walking and pausing times
		public var walkTimer : int = 0;
		public var walkTimerMax : int = 0;
		
		public var pauseTimer : int = 0;
		public var pauseTimerMax : int = 0;
		
		/* These are used to let the enemy remember how much it should move    
		 * along each axis each frame.
		 * */
		public var movementVector : Point = new Point();
		
		// Number of directions for movement
		public var movementDirections : int = 8
		
		// Vector containing names for diagonal directions.
		public var directionsDiagonal : Vector.<String> = new Vector.<String>();
		
		// Easily overridable method for simple settings
		override public function setup() : void {
			
			// Enemy walk speed in pixels per frame
			walkSpeed = 0.5;
			
			/* Number of frames of movement before pausing. In this case, 
			 * calculated based on enemy's size.
			 * */
			walkTimerMax = (newPos.width + newPos.height) / 2
			
			/* Number of frames of pausing before movement. In this case, half
			 * the number of frames it spends walking.
			 * */
			pauseTimerMax = walkTimerMax / 2

			// Amount of damage the enemy inflicts on avatars
			damage = 1;
			
			// The enemy's initial and maximum health
			healthMax = 1;
			
			// The enemy's initial action and direction, used for animation.
			animationAction = "walk";
			animationDirectionHorizontal = "up";
		
		}
		
		function EnemyTopdown() : void {
			
			/* Create the lists of actions and directions used by the
			 * animation system.
			 * */
			actions.push("idle", "walk", "hurt");
			directions.push("up", "right", "down", "left");
			directionsDiagonal.push("upright", "downright", "downleft", "upleft");
			
			// Generate animation states
			generateAnimationStates();
			generateAnimationStates(directionsDiagonal);
			
			// Generate initial direction
			changeDirection();
			
			// Set animation state based on default action and direction.
			setAnimationState();
		
		}
		
		override public function onEnterFrame(e : Event) : void {
			
			/* Saves the current bounds (x,y,width,height), in the form of a
			 * Rectangle instance, in the newPos variable. This is used later
			 * on to apply provisionary changes to the position of the object.
			 * When all variables (solid collisions, gravity) have been
			 * accounted for, the object's position is set to be the same as
			 * the newPos.
			 * */
			newPos = this.getBounds(root);
			
			// Apply movement
			move();
			
			// Check for solids
			checkForSolids();
			
			
			if (!isDead) {
				
				/* Determine the active animation state based on the current
				 * action and direction. These are, in turn, determined by 
				 * the methods above.
				 * */
				setAnimationState();
				
				// Realize the provisional movement
				finalizeMovement();
				
			}
		}
		
		/* Besides its normal functionality, collision with a solid should also
		 * mean changing directions.
		 * */
		override public function effectSolid(solid : Solid) : void {
			super.effectSolid(solid);
			
			changeDirection();
		}
		
		
		public function move() : void {
			
			// Check if the enemy is dead or hurt
			if (!isDead && !isHurt) {
				
				// Walk, if timer hasn't reached 0.
				if (walkTimer > 0) {
					
					// Subtract from timer
					walkTimer -= 1;
					
					// Apply the movement vector
					newPos.x += movementVector.x;
					newPos.y += movementVector.y;
					
					// Set the proper animation action
					animationAction = "walk";
					
				/* If the walk timer has reached zero, take a break until the 
				 * pause timer also reaches zero.
				 * */
				} else if (pauseTimer > 0) {
					
					// Subtract from timer
					pauseTimer -= 1;
					
					// Set the proper animation action
					animationAction = "idle";
					
				} else {
					// When both timers have reached 0, select a new direction
					changeDirection();
					
				}
			} else if (isDead) {
				/* if the enemy is dead, it should be destroyed. The destroy
				 * method originates from the PhysicalObject class.
				 * */
				destroy();
				
			} else {
				// if the enemy is hurt, use the appropriate action.
				animationAction = "hurt";
			}
		
		}
		
		function changeDirection() : void {
			
			// Reset walk and pause timers
			walkTimer = walkTimerMax;
			pauseTimer = pauseTimerMax;
			
			// Randomize a 45 degree angle between 0 and 315.
			var degrees : int = Math.floor(Math.random() * movementDirections) * (360 / movementDirections);
			
			// Save the degrees in case they are needed.
			animationDirectionDegrees = degrees;
			
			// Convert the angle to radians
			var radians : Number = degrees * Math.PI / 180;
			
			/* Use trigonomy to create x and y movement per frame from angle &
			 * walk speed. Walk speed is the hypotenuse, with the moveX and 
			 * moveY acting as the opposite and adjacent sides, respectively.
			 * */
			movementVector.x = Math.cos(radians) * walkSpeed;
			movementVector.y = Math.sin(radians) * walkSpeed;
			
			// Use degress to determine vertical animation direction
			if (degrees >= 315 || degrees <= 45) {
				animationDirectionVertical = "up";
				
			} else if (degrees >= 135 || degrees <= 225) {
				animationDirectionVertical = "down";
				
			} else {
				animationDirectionVertical = "";
				
			}
			
			// Use degress to determine horizontal animation direction
			if (degrees >= 45 || degrees <= 135) {
				animationDirectionHorizontal = "right";
				
			} else if (degrees >= 225 || degrees <= 315) {
				animationDirectionHorizontal = "left";
				
			} else {
				animationDirectionHorizontal = "";
				
			}
		
		}
	
	}
}