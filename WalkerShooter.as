package {
import flash.events.Event;
import flash.system.ApplicationDomain;
import flash.ui.Keyboard;
import flash.utils.getQualifiedClassName;
	
	class WalkerShooter extends Walker {
		
		private var shootTimer : int = 0;
		private var shootTimerMax : int = 20;
		
		private var shootAnimTimer : int = 0;
		private var shootAnimTimerMax : int = 15;
		
		public var keyShoot : int;
		
		public var missileClass : Class;
		
		override internal function setup():void {
			super.setup();
			
			keyShoot = Keyboard.SHIFT;
			
			missileClass = PlayerBullet;
			
		}
		function WalkerShooter() : void {
			
			actions.slice(0, actions.length);
			actions.push("idle", "idleshoot");
			
			generateAnimationStates();
			
			actions.slice(0, actions.length);
			actions.push("idle", "walk", "walkshoot");
			
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
			}
			if (keys[keyShoot] && shootTimer == 0) {
				shootTimer = shootTimerMax;
				shootAnimTimer = shootAnimTimerMax;
				
				if (ApplicationDomain.currentDomain.hasDefinition(getQualifiedClassName(missileClass))) {
					
					var newMissile : PlayerMissile = new missileClass();
					
					// Set the new bullet's 
					newMissile.y = newPos.top + newPos.height / 2;
					
					parent.addChild(newMissile);
					
					
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
					
					var animDir:String = animationDirectionVertical + animationDirectionHorizontal;
					
					switch(animDir) {
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
		}
		
	}
	
}