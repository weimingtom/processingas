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
		
		public function run(code):void {
			// run the specified code
			_context.init(code);
		}
	}
}