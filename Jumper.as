package
{
	import flash.display.FrameLabel;
	import flash.ui.Keyboard
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	class Jumper extends DynamicObject
	{
		
		// Keys to use for movement
		public var keyMoveLeft:int;
		public var keyMoveRight:int;
		public var keyJump:int;
		
		public var walkSpeed:int;
		public var jumpForce:Number;
		public var enemyPushback:Number;
		
		private var jumpKeyReset:Boolean;
		
		private var keys:Array = [];
		private var isHurt:Boolean = false;
		
		public var labelNames:Vector.<String> = new Vector.<String>();
		
		public var animationStates:Object = new Object();
		public var animationCurrentState:String;
		
		public var animationDirection:String = "right";
		public var animationAction:String = "idle"
		
		override function setup():void
		{
			
			cameraFollowHorizontal = true;
			cameraFollowVertical = false;
			
			keyMoveLeft = Keyboard.A;
			keyMoveRight = Keyboard.D;
			keyJump = Keyboard.SPACE;
			
			walkSpeed = 3; // pixels per frame
			jumpForce = 15; // Initial force of jumps
			enemyPushback = 6; // horisontal pushback from hitting enemies
			
			useTeleports = true;
			
			useGravity = true;
			useKeys = true;
		
		}
		
		public function Jumper():void
		{
			
			// Add event listeners for keyboard
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			
			setAnimationState();
		}
		
		override public function onEnterFrame(event:Event):void
		{
			
			newPos = this.getBounds(root);
			
			getMoveRequest();
			applyGravity();
			
			checkForEnemies();
			applyInertia();
			applyForces();
			
			checkForKeys();
			checkForSolids();
			checkForTeleports();
			
			finalizeMovement();
			
			if (isHurt && onGround)
			{
				isHurt = false;
			}
			
			setAnimationState();
		
		}
		
		private function getMoveRequest():void
		{
			// May only move if not hurt
			if (!isHurt)
			{
				
				// Jumping
				if (keys[keyJump] && onGround && jumpKeyReset)
				{
					verticalForce = -jumpForce;
					jumpKeyReset = false;
				}
				
				if (!keys[keyJump] && onGround)
				{
					jumpKeyReset = true;
					animationAction = "idle";
				}
				
				// Horizontal movement
				if (keys[keyMoveRight])
				{
					newPos.x += walkSpeed;
					animationDirection = "right";
					animationAction = "walk";
				}
				if (keys[keyMoveLeft])
				{
					newPos.x -= walkSpeed;
					animationDirection = "left";
					animationAction = "walk";
				}
				
				if (!onGround)
				{
					animationAction = "jump";
				}
				
			}
			else
			{
				animationAction = "hurt";
			}
		
		}
		
		override public function applyDamage(enemy:Enemy, xDir:int, yDir:int):void
		{
			
			if (enemy.x >= newPos.x)
			{
				// Enemy is to the right
				horizontalForce = -enemyPushback;
				animationDirection = "right";
			}
			else
			{
				// Enemy is to the left
				horizontalForce = enemyPushback;
				animationDirection = "left";
			}
			
			verticalForce = -jumpForce;
			
			isHurt = true;
		}
		
		override public function generateAnimationStates():void // TODO: Figure out how much of this can be generalized.
		{
			
			// Create list containing the names of all labelled frames
			var labelNames:Vector.<String> = new Vector.<String>();
			
			for each (var f:FrameLabel in this.currentLabels)
			{
				labelNames.push(f.name);
			}
			
			// Create list containing order of priority for action animations
			// 'idle' is the base; 'walk' defaults to idle, 'jump' defaults to walk etc.
			var order:Vector.<String> = new Vector.<String>();
			
			order.push("idle", "walk", "jump", "hurt", "death");
			
			// Go through each action
			var i:int = 0;
			for each (var action:String in order)
			{
				
				if (labelNames.indexOf(action + "_right") >= 0)
				{
					// If the action's 'right' frame exists, create new AnimationState object containing it.
					animationStates[action + "_right"] = new AnimationState(action + "_right");
					
				}
				else if (i == 0)
				{
					// If the 'right' frame does not exist and the action's the first one in the list (no default)
					// then create an 'empty' animation state, in effect defaulting to frame 1.
					animationStates[action + "_right"] = new AnimationState("");
					
				}
				else
				{
					// Otherwise, fall back on the previous action's 'right' frame.
					animationStates[action + "_right"] = AnimationState(animationStates[order[i - 1] + "_right"]).copy();
					
				}
				
				if (labelNames.indexOf(action + "_left") >= 0)
				{
					// If the action's 'left' frame exists, create new AnimationState object containing it.
					animationStates[action + "_left"] = new AnimationState(action + "_left");
					
				}
				else
				{
					// Otherwise, fall back on copying and mirroring the action's 'right' frame.
					animationStates[action + "_left"] = AnimationState(animationStates[action + "_right"]).copy();
					animationStates[action + "_left"].mirror = true;
				}
				
				i++;
			}
		
		}
		
		public function setAnimationState():void // TODO: Figure out how much of this can be generalized.
		{
			
			// Create 'state' string from action + direction
			var state:String = animationAction + "_" + animationDirection;
			
			// Check to see if the state has changed
			if (state != animationCurrentState)
			{
				
				// Save the new state string
				animationCurrentState = state;
				
				// Get the AnimationState to use.
				var s:AnimationState = AnimationState(animationStates[state]);
				
				// If the AnimationState is null, no AnimationState corresponding to the 
				// state string has been implemented.
				// Create a new, empty animation state and give an error.
				if (s == null)
				{
					s = AnimationState(animationStates["idle_right"]);
					trace("Animation state " + state + " not implemented yet");
				}
				
				// Goto either the named frame or to the specified frame number.
				if (s.sourceFrameName != "")
				{
					this.gotoAndStop(s.sourceFrameName);
				}
				else
				{
					this.gotoAndStop(s.sourceFrameNumber);
				}
				
				// Do mirroring
				var oldScaleX:int = this.scaleX;
				
				if (s.mirror)
				{
					this.scaleX = -1;
				}
				else
				{
					this.scaleX = 1;
				}
				
				// If mirroring took place, move the avatar to make up for the flip.
				if (oldScaleX != this.scaleX)
				{
					updateOffset();
					this.x -= 2 * ((this.width / 2) - offsetX);
				}
			}
		}
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			keys[e.keyCode] = true;
		}
		
		private function onKeyUp(e:KeyboardEvent)
		{
			keys[e.keyCode] = false;
		}
	
	}

}