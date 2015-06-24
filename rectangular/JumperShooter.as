package rectangular {
	
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	import flash.ui.Keyboard;
	import flash.utils.getQualifiedClassName;
	
	/* This class provides a variation on the normal Jumper class. It adds
	 * timers and mechanisms for firing missiles of the class specified by
	 * missileClass. missileCLass should be set to the class name set inside
	 * Flash.
	 * The simplest implementation would be to create a symbol in the library,
	 * giving it the class name PlayerBullet and base class
	 * rectangular.MissilePlayer.
	 * */
	public class JumperShooter extends Jumper {
		
		// The timer used to determine how often the jumper is able to fire.
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
		override protected function setup() : void {
			
			// Do the usual setup() for Jumpers.
			super.setup();
			
			// Set the firing button.
			keyShoot = Keyboard.SHIFT;
			
			// Set the bullet class.
			missileClass = PlayerBullet;
			
			// Set max values of the timers.
			shootAnimTimerMax = 15;
			shootTimerMax = 20;
		
		}
		
		function JumperShooter() : void {
			
			/* Empty the ordinary actions list - the action names it contained
			 * have already been generated in the original jumper's constructor
			 * - and fill it up with the new ones, beginning with the usual
			 * default of "idle".
			 * */
			actions.splice(0, actions.length);
			actions.push("idle", "idleshoot", "walkshoot", "jumpshoot");
			
			// Generate these new animation states.
			generateAnimationStates();
		
		}
		
		override protected function onEnterFrame(event : Event) : void {
			
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
					
					// Set the new bullet's position and scale.
					newMissile.y = newPos.top + newPos.height / 2;
					
					if (animationDirectionHorizontal == "right") {
						newMissile.x = newPos.right;
						newMissile.setDirection(0);
					} else {
						newMissile.x = newPos.left;
						newMissile.setDirection(180);
						newMissile.scaleX *= -1;
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