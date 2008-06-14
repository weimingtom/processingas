package processing {
	import com.gamemeal.html.Canvas;
	import processing.*;
	import asas.*;

	public class Processing {
		private var _canvas:Canvas;
		public function get canvas():Canvas {
			return _canvas;
		}
		
		private var _context:ProcessingContext;
		public function get context():ProcessingContext {
			return _context;
		}

		public function Processing():void {
			// create canvas object
//[TODO] not hard-code that?
			_canvas = new Canvas('processingCanvas', 200, 200);
			
			// create processing context
			_context = new ProcessingContext(this);
		}
		
		public function start():void {
			context.stroke(0);
			context.fill(255);
		
			if (context.setup)
			{
				context.inSetup = true;
				context.setup();
			}
			
			context.inSetup = false;
			
			if (context.draw)
			{
				if ( !context.doLoop )
				{
					context.redraw();
				}
				else
				{
					context.loop();
				}
			}
/*
			attach( curElement, "mousemove", function(e)
			{
				pmouseX = mouseX;
				pmouseY = mouseY;
				mouseX = e.clientX;
				mouseY = e.clientY;
	
				if ( mouseMoved )
				{
					mouseMoved();
				}			
	
				if ( mousePressed && mouseDragged )
				{
					mouseDragged();
				}			
			});
			
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
	}
}