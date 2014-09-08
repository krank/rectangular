package {
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.ui.Keyboard;
	import flash.system.ApplicationDomain;
	import flash.utils.getQualifiedClassName;
	
	class JumperShooter extends Jumper {
		
		private var shootTimer : int = 0;
		private var shootTimerMax : int = 20;
		
		private var shootAnimTimer : int = 0;
		private var shootAnimTimerMax : int = 15;
		
		public var keyShoot : int;
		
		public var missileClass : Class;

		override internal function setup():void 
		{
			super.setup();
			
			keyShoot = Keyboard.SHIFT;
			
			missileClass = PlayerBullet;
			
		}
		
		function JumperShooter() : void {
			
			actions.slice(0, actions.length);
			actions.push("idle", "idleshoot");
			
			generateAnimationStates();
			

			actions.slice(0, actions.length);
			actions.push("idle", "walk", "walkshoot");
			
			generateAnimationStates();
			
			
			actions.slice(0, actions.length);
			actions.push("idle", "walk", "jump", "jumpshoot");
			
			generateAnimationStates();
			
		}
		
		override public function onEnterFrame(event:Event):void 
		{
			super.onEnterFrame(event);
			
			if (shootTimer > 0) {
				shootTimer -= 1;
			}
			
			if (shootAnimTimer > 0) {
				shootAnimTimer -= 1;
				animationAction = animationAction + "shoot";
				setAnimationState();
			}
			
			if (keys[Keyboard.SHIFT] && shootTimer == 0) {
				
				animationAction = animationAction + "shoot";
				shootTimer = shootTimerMax;
				shootAnimTimer = shootAnimTimerMax;

				// If specified bullet class exists, create a new bullet from it
				if (ApplicationDomain.currentDomain.hasDefinition(getQualifiedClassName( missileClass ))) {

					var newMissile:PlayerMissile = new missileClass();
					
					// Set the new bullet's 
					newMissile.y = newPos.top + newPos.height / 2;

					parent.addChild(newMissile);
					
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
			
			
			
		}
		
	}
}