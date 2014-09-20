package rectangular {
	
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	import flash.ui.Keyboard;
	import flash.utils.getQualifiedClassName;
	
	/* This class provides a variation on the normal Walker class. It adds
	 * timers and mechanisms for firing missiles of the class specified by
	 * missileClass. missileClass should be set to the class name set inside
	 * Flash.
	 * The simplest implementation would be to create a symbol in the library,
	 * giving it the class name PlayerBullet and base class
	 * rectangular.MissilePlayer.
	 * */
	public class WalkerShooter extends rectangular.Walker {
		
		// The timer used to determine how often the walker is able to fire.
		private var shootTimer : int = 0;
		private var shootTimerMax : int = 20;
		
		/* The timer used to determine how long the "*shoot" animation state
		 * is shown.
		 * */
		private var shootAnimTimer : int = 0;
		private var shootAnimTimerMax : int = 15;
		
		// The keycode of the key used to shoot things.
		public var keyShoot : int;
		
		// The class of the bullets to be fired
		public var missileClass : Class;
		
		/* Stores the current movement action, used as the base for the shoot
		 * animation action name.
		 * */
		public var currentMovementAction : String;
		
		// Easily overridable method for simple settings
		override public function setup() : void {
			
			// Do the usual setup() for Walkers
			super.setup();
			
			// Set the firing button.
			keyShoot = Keyboard.SHIFT;
			
			// Set the bullet class.
			missileClass = PlayerBullet;
			
			// Set max values of the timers.
			shootAnimTimerMax = 15;
			shootTimerMax = 20;
		}
		
		function WalkerShooter() : void {
			
			/* Empty the ordinary actions list - the action names it contained
			 * have already been generated in the original jumper's constructor
			 * - and fill it up with the new ones, beginning with the usual
			 * default of "idle".
			 * */
			actions.slice(0, actions.length);
			actions.push("idle", "idleshoot", "walkshoot");
			
			// Generate these new animation states.
			generateAnimationStates();
			generateAnimationStates(this.directionsDiagonal);
		
		}
		
		override public function onEnterFrame(event : Event) : void {
			
			// Do the normal Jumper's onEnterFrame things
			super.onEnterFrame(event);
			
			if (keys[keyShoot] && shootTimer == 0) {
				
				// Save the current action name
				currentMovementAction = animationAction;
				
				// Setup both timers
				shootTimer = shootTimerMax;
				shootAnimTimer = shootAnimTimerMax;
				
				// If missileCLass class exists, create a new bullet from it.
				if (ApplicationDomain.currentDomain.hasDefinition(getQualifiedClassName(missileClass))) {
					
					var newMissile : MissilePlayer = new missileClass();
					
					// Add the bullet to the jumper's parent.
					parent.addChild(newMissile);
					
					// Set the new bullet's initial position
					newMissile.y = newPos.top + newPos.height / 2;
					
					if (animationDirectionHorizontal == "right") {
						newMissile.x = newPos.right;
					} else if (animationDirectionHorizontal == "left") {
						newMissile.x = newPos.left;
					} else {
						newMissile.x = newPos.x + newPos.width / 2;
					}
					
					if (animationDirectionVertical == "up") {
						newMissile.y = newPos.top;
					} else if (animationDirectionVertical == "down") {
						newMissile.y = newPos.bottom;
					} else {
						newMissile.y = newPos.y + newPos.height / 2;
					}
					
					// Create animation direction string
					var animDir : String = animationDirectionVertical + animationDirectionHorizontal;
					
					/* Set different directions for the missile depending on
					 * the animation direction string.
					 * */
					switch (animDir) {
						case "up":
							newMissile.setDirection(270);
							newMissile.rotation = 270;
							break;
						case "down":
							newMissile.setDirection(90);
							newMissile.rotation = 90;
							break;
						case "left":
							newMissile.setDirection(180);
							newMissile.rotation = 180;
							break;
						case "right":
							newMissile.setDirection(0);
							newMissile.rotation = 0;
							break;
						case "downright":
							newMissile.setDirection(45);
							newMissile.rotation = 45;
							break;
						case "downleft":
							newMissile.setDirection(135);
							newMissile.rotation = 135;
							break;
						case "upleft":
							newMissile.setDirection(225);
							newMissile.rotation = 225;
							break;
						case "upright":
							newMissile.setDirection(315);
							newMissile.rotation = 315;
							break;
					}
					
				}
				
			}
			
			// If the shootTimer is in effect, count it down
			if (shootTimer > 0) {
				shootTimer -= 1;
			}
			
			// If the shootAnimTimer is in effect, count it down
			if (shootAnimTimer > 0) {
				shootAnimTimer -= 1;
				animationAction = animationAction + "shoot";
				setAnimationState();
			}
		}
	
	}

}