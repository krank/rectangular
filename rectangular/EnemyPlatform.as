package rectangular {
	
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	/* This class represents enemies who walk along platforms. They are
	 * affected by gravity and turn when they collide with walls. Normally,
	 * they deal 1 point of damage to avatars who collide with them.
	 * */
	
	public class EnemyPlatform extends Enemy {
		
		// Enemy walk speed
		public var walkSpeed : Number = 0.5;
		
		// Current enemy walking direction. 1 means right, -1 left.
		public var moveDirection : int = 1;
		
		// Easily overridable method for simple settings
		override public function setup() : void {
			
			// Enemy should be affected by gravity
			useGravity = true;
			
			// Variables for use in calculation of gravity acceleration
			pixelsPerMeter = 15;
			gravityAccelerationReal = 9.8;
			
			// Initial direction of movement
			moveDirection = 1;
			
			// Walk speed
			walkSpeed = 0.5;
			
			// Amount of damage the enemy inflicts on avatars
			damage = 1;
			
			// The enemy's initial and maximum health
			healthMax = 1;
		
		}
		
		public function EnemyPlatform() : void {
			
			/* Create the lists of actions and directions used by the
			 * animation system.
			 * */
			actions.push("walk", "jump", "hurt");
			directions.push("right", "left");
			
			animationAction = "walk";
			animationDirectionHorizontal = "right";
			
			// Generate animation states
			generateAnimationStates();
			
			// Set animation state based on default action and direction.
			setAnimationState();
		}
		
		// This method runs once every frame.
		override public function onEnterFrame(e : Event) : void {
			
			/* Saves the current bounds (x,y,width,height), in the form of a
			 * Rectangle instance, in the newPos variable. This is used later
			 * on to apply provisionary changes to the position of the object.
			 * When all variables (solid collisions, gravity) have been
			 * accounted for, the object's position is set to be the same as
			 * the newPos.
			 * */
			newPos = this.getBounds(root);
			
			// Apply gravity
			applyGravity();
			
			// Apply horizontal and vertical physical forces
			applyForces();
			
			// Apply movement
			move();
			
			// Check for solids
			checkForSolids();
			
			// See if object actually moved
			if (this.getBounds(root).x == newPos.x) {
				
				/* if it did not, it probably hit a solid and was pushed back.
				 * Which, in turn, means it's time to change directions.
				 * */
				changeDirection();
				
			}
			
			/* Determine the active animation state based on the current
			 * action and direction. These are, in turn, determined by 
			 * the methods above.
			 * */
			setAnimationState();
			
			// Realize the provisional movement
			finalizeMovement();
			
		}
		
		public function move() : void {
			
			// Check if the enemy is dead or hurt
			if (!isDead && !isHurt) {
				
				/* if it is not, then walk in the direction indicated by the
				 * moveDirection variable.
				 * */
				
				newPos.x += walkSpeed * moveDirection;
				
				/* Determine animation action based on whether the enemy is on
				 * the ground or not.
				 * */
				if (!onGround) {
					animationAction = "jump";
				} else {
					animationAction = "walk";
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
		
		// Method used to change the enemy's direction
		public function changeDirection() {
			
			// Negate current direction
			moveDirection = -moveDirection;
			
			/* Use new direction integer value to determine the correct
			 * animation direction.
			 * */
			if (moveDirection > 0) {
				animationDirectionHorizontal = "right";
			} else {
				animationDirectionHorizontal = "left";
			}
			
		}
	
	}

}