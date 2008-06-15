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
			addChild(p.canvas);
			var c:Context = p.context;
			
			// evaluate code
//			var parser:Parser = new Parser();
//			parser.evaluate(processingText, p);

//*****************************************************************************
// All Examples Written by Casey Reas and Ben Fry
// unless otherwise stated.
c.setup = function () 
{
  c.size(200, 200); 
  c.noStroke();
  c.colorMode(c.RGB, 255, 255, 255, 100);
  c.rectMode(c.CENTER);
}

c.draw = function () 
{
  c.background(51); 
  c.fill(255, 80);
  c.rect(c.mouseX, height/2, c.mouseY/2+10, c.mouseY/2+10);
  c.fill(255, 80);
  c.rect(c.width-c.mouseX, c.height/2, ((c.height-c.mouseY)/2)+10, ((c.height-c.mouseY)/2)+10);
}
//*****************************************************************************
			
			// start processing
			p.start();
		}
	}
}
