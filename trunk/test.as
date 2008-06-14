package {
	import flash.display.Sprite;
	import processing.Processing;
	import processing.Parser;
	import mx.core.ByteArrayAsset;
	import flash.utils.ByteArray;
	
	[SWF(width="200", height="200", frameRate="24", backgroundColor="#ffffff")]
	
        public class test extends Sprite {
		[Bindable]
		[Embed(source="test.processing", mimeType="application/octet-stream")]
		private var ProcessingText:Class;

		public function test():void {
			// load processing.js
			var processingTextAsset:ByteArrayAsset = ByteArrayAsset(new ProcessingText());
			var processingText:String = processingTextAsset.readUTFBytes(processingTextAsset.length);

			// create processing object
			var p:Processing = new Processing();
			addChild(p.canvas);
			
			// evaluate code
//			var parser:Parser = new Parser();
//			parser.evaluate(processingText, p);

//******************************************************************************
// All Examples Written by Casey Reas and Ben Fry
// unless otherwise stated.
p.context.size(200, 200);
p.context.smooth();
p.context.background(0);
p.context.strokeWeight(10);

for(var i = 0; i < p.context.width; i++) {
  var r = p.context.random(255);
  var x = p.context.random(0, p.context.width);
  p.context.stroke(r, 100);
  p.context.line(i, 0, x, p.context.height);
}
//******************************************************************************
			
			// start processing
//			p.start();
		}
	}
}