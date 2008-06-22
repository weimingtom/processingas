package processing.api {
	import processing.api.*;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.events.Event;

	public class Processing {
		private var _sprite:Bitmap;
		public function get sprite():Bitmap {
			return _sprite;
		}
		
		private var _context:Context;
		public function get context():Context {
			return _context;
		}

		public function Processing():void {
			// create sprite bitmap
			_sprite = new Bitmap(new BitmapData(100, 100));
			
			// create processing context
			_context = new Context(this);
		}

		// loop switch
		public var loop:Boolean = true;
		public var inSetup:Boolean = false;
		public var inDraw:Boolean = false;
		
		public function start():void {
			// set defaults
			context.stroke(0);
			context.fill(255);
			context.noSmooth();
			
			context.trace = trace;
		
			// setup function
			if (context.setup)
			{
				inSetup = true;
				context.setup();
			}
			inSetup = false;
			
			// draw function
			if (context.draw)
			{
				context.redraw();
			}

			// attach event listeners
			sprite.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			sprite.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			sprite.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			sprite.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			sprite.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			sprite.addEventListener(Event.ENTER_FRAME, onEnterFrame);
/*
			
			attach( curElement, "mousedown", function(e)
			{
				mousePressed = true;
	
				if ( typeof mousePressed == "function" )
				{
					mousePressed();
				}
				else
				{
					mousePressed = true;
				}
			});
				
			attach( curElement, "mouseup", function(e)
			{
				mousePressed = false;
	
				if ( typeof mousePressed != "function" )
				{
					mousePressed = false;
				}
	
				if ( mouseReleased )
				{
					mouseReleased();
				}
			});
	
			attach( document, "keydown", function(e)
			{
				keyPressed = true;
	
				var key = e.keyCode + 32;
	
				if ( e.shiftKey )
				{
					key = String.fromCharCode(key).toUpperCase().charCodeAt(0);
				}
	
				if ( typeof keyPressed == "function" )
				{
					keyPressed();
				}
				else
				{
					keyPressed = true;
				}
			});
	
			attach(document, "keyup", function(e) {
				keyPressed = false;
	
				if ( typeof keyPressed != "function" )
				{
					keyPressed = false;
				}
	
				if ( keyReleased )
				{
					keyReleased();
				}
			});
			
			function attach(elem, type, fn)
			{
				if ( elem.addEventListener )
					elem.addEventListener( type, fn, false );
				else
					elem.attachEvent( "on" + type, fn );
			}
*/
		}
		
		public function stop():void {
//[TODO] remove items
		}
		
		private var isMousePressed:Boolean = false;

		private function onMouseMove( e:MouseEvent )
		{
			context.pmouseX = context.mouseX;
			context.pmouseY = context.mouseY;
			context.mouseX = sprite.mouseX;
			context.mouseY = sprite.mouseY;

			if ( typeof context.mouseMoved == "function" )
			{
				context.mouseMoved();
			}
			if ( isMousePressed && typeof context.mouseDragged == "function" )
			{
				context.mouseDragged();
			}			
		}
		
		private function onMouseDown( e:MouseEvent )
		{
			isMousePressed = true;
		
			if ( typeof context.mousePressed == "function" )
			{
				context.mousePressed();
			}
			else
//[TODO] do this with var/function differences
			{
				context.mousePressed = true;
			}
		}
		
		private function onMouseUp( e:MouseEvent )
		{
			isMousePressed = false;
		
			if ( typeof context.mouseReleased == "function" )
			{
				context.mouseReleased();
			}
			
			if ( typeof context.mousePressed != "function" )
			{
				context.mousePressed = false;
			}
		}
		
		private var isKeyDown:Boolean = false;
		
		private function onKeyDown( e:KeyboardEvent )
		{
			isKeyDown = true;

			context.key = e.keyCode + 32;

			if ( e.shiftKey )
			{
				context.key = String.fromCharCode(context.key).toUpperCase().charCodeAt(0);
			}

			if ( typeof context.keyPressed == "function" )
			{
				context.keyPressed();
			}
			else
			{
				context.keyPressed = true;
			}
		}
		
		private function onKeyUp( e:KeyboardEvent )
		{
			isKeyDown = false;

			if ( typeof context.keyPressed != "function" )
			{
				context.keyPressed = false;
			}

			if ( typeof context.keyReleased == "function" )
			{
				context.keyReleased();
			}
		}

		private function onEnterFrame( e:Event )
		{
			if (loop && context.draw)
			{
//[TODO] redraw isn't... right
				context.redraw();
			}
		}
	}
}
