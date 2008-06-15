package {
	import flash.display.Sprite;
	import processing.Processing;
	import processing.Context;
	import processing.Parser;
	import mx.core.ByteArrayAsset;
	import flash.utils.ByteArray;
	
	[SWF(width="200", height="200", frameRate="60", backgroundColor="#ffffff")]
	
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
			addChild(p.sprite);
			var c:Context = p.context;
			
			// evaluate code
//			var parser:Parser = new Parser();
//			parser.evaluate(processingText, p);

//*****************************************************************************
// All Examples Written by Casey Reas and Ben Fry
// unless otherwise stated.
var max_distance;

c.setup = function () {
  c.size(200, 200); 
  c.smooth();
  c.noStroke();
  max_distance = c.dist(0, 0, c.width, c.height);
}

c.draw = function() 
{
  c.background(51);

  for(var i = 0; i <= c.width; i += 20) {
    for(var j = 0; j <= c.width; j += 20) {
      var size = c.dist(c.mouseX, c.mouseY, i, j);
      size = size/max_distance * 66;
      c.ellipse(i, j, size, size);
    }
  }
}
//*****************************************************************************
			
			// start processing
			p.start();
		}
	}
}
