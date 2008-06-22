package processing.api {
	import processing.api.*;
	import processing.parser.*;
	import processing.parser.statements.IExecutable;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.events.Event;

	public class Processing {
		public var graphics:PGraphics;
		public var context:ExecutionContext;
		public var sprite:Bitmap;

		public function Processing():void {
			// create evaluation context
			context = new ExecutionContext(
			    {
				Math: PMath,
				ArrayList: ArrayList,
				AniSprite: AniSprite,
				trace: trace
			    }, new ExecutionContext(PMath, new ExecutionContext(graphics)));
			    
			// create main graphics object
			graphics = new PGraphics(context);
			// create main sprite
			sprite = new Bitmap(graphics.bitmapData);
		}
		
		public function evaluate(c:String):* {
			// parse code
			var code:IExecutable = (new Parser()).parse(c);
			// execute code
			return code.execute(context);
		}

		// loop switch
		public var loop:Boolean = true;
		public var inSetup:Boolean = false;
		public var inDraw:Boolean = false;
		
		public function start():void {
			// set defaults
			graphics.stroke(0);
			graphics.fill(255);
			graphics.noSmooth();
		
			// setup function
			if (context.scope.setup)
			{
				inSetup = true;
				context.scope.setup();
			}
			inSetup = false;
			
			// draw function
			if (context.scope.draw)
			{
				context.scope.redraw();
			}

			// attach event listeners
			sprite.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			sprite.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			sprite.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			sprite.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			sprite.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			sprite.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		public function stop():void {
//[TODO] remove items
		}
		
		private var isMousePressed:Boolean = false;

		private function onMouseMove( e:MouseEvent )
		{
			context.scope.pmouseX = context.scope.mouseX;
			context.scope.pmouseY = context.scope.mouseY;
			context.scope.mouseX = sprite.mouseX;
			context.scope.mouseY = sprite.mouseY;

			if ( typeof context.scope.mouseMoved == "function" )
			{
				context.scope.mouseMoved();
			}
			if ( isMousePressed && typeof context.scope.mouseDragged == "function" )
			{
				context.scope.mouseDragged();
			}			
		}
		
		private function onMouseDown( e:MouseEvent )
		{
			isMousePressed = true;
		
			if ( typeof context.scope.mousePressed == "function" )
			{
				context.scope.mousePressed();
			}
			else
//[TODO] do this with var/function differences
			{
				context.scope.mousePressed = true;
			}
		}
		
		private function onMouseUp( e:MouseEvent )
		{
			isMousePressed = false;
		
			if ( typeof context.scope.mouseReleased == "function" )
			{
				context.scope.mouseReleased();
			}
			
			if ( typeof context.scope.mousePressed != "function" )
			{
				context.scope.mousePressed = false;
			}
		}
		
		private var isKeyDown:Boolean = false;
		
		private function onKeyDown( e:KeyboardEvent )
		{
			isKeyDown = true;

			context.scope.key = e.keyCode + 32;

			if ( e.shiftKey )
			{
				context.scope.key = String.fromCharCode(context.scope.key).toUpperCase().charCodeAt(0);
			}

			if ( typeof context.keyPressed == "function" )
			{
				context.scope.keyPressed();
			}
			else
			{
				context.scope.keyPressed = true;
			}
		}
		
		private function onKeyUp( e:KeyboardEvent )
		{
			isKeyDown = false;

			if ( typeof context.scope.keyPressed != "function" )
			{
				context.scope.keyPressed = false;
			}

			if ( typeof context.scope.keyReleased == "function" )
			{
				context.scope.keyReleased();
			}
		}

		private function onEnterFrame( e:Event )
		{
			if (loop && context.scope.draw)
			{
//[TODO] redraw isn't... right
				graphics.redraw();
			}
		}
	}
}
