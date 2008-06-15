package processing {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import processing.Context;
	import flash.events.MouseEvent;

	public class Processing {
		private var _canvas:Bitmap;
		public function get canvas():Bitmap {
			return _canvas;
		}
		
		private var _context:Context;
		public function get context():Context {
			return _context;
		}

		public function Processing():void {
			// create canvas bitmap
			_canvas = new Bitmap(new BitmapData(100, 100));
			
			// create processing context
			_context = new Context(this);
		}

		// loop switch
		public var loop:Boolean = true;
		public var inSetup:Boolean = false;
		public var inDraw:Boolean = false;
		
		public function start():void {
			// set default colors
			context.stroke(0);
			context.fill(255);
		
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
				loop ? context.loop() : context.redraw();
			}

			// attach event listeners
			canvas.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
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

		private function mouseMoveHandler( e:MouseEvent )
		{
			context.pmouseX = context.mouseX;
			context.pmouseY = context.mouseY;
			context.mouseX = canvas.mouseX;
			context.mouseY = canvas.mouseY;

			if ( context.mouseMoved )
			{
				context.mouseMoved();
			}
			if ( /*context.mousePressed && */context.mouseDragged )
			{
				context.mouseDragged();
			}			
		}
	}
}
