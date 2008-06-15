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
var e1, e2, e3, e4, e5;

c.setup = function () 
{
  c.size(200, 200);
  c.smooth();
  c.noStroke();
  e1 = new Eye( 50,  16,  80);
  e2 = new Eye( 64,  85,  40);  
  e3 = new Eye( 90, 200, 120);
  e4 = new Eye(150,  44,  40); 
  e5 = new Eye(175, 120,  80);
}

c.draw = function () 
{
  c.background(102);
 
  e1.update(c.mouseX, c.mouseY);
  e2.update(c.mouseX, c.mouseY);
  e3.update(c.mouseX, c.mouseY);
  e4.update(c.mouseX, c.mouseY);
  e5.update(c.mouseX, c.mouseY);

  e1.display();
  e2.display();
  e3.display();
  e4.display();
  e5.display();
}

function Eye(x, y, s)
{
  var ex, ey;
  var size;
  var angle = 0.0;
  
    ex = x;
    ey = y;
    size = s;

  this.update = function (mx, my) {
    angle = c.atan2(my-ey, mx-ex);
  }
  
  this.display = function () {
    c.pushMatrix();
    c.translate(ex, ey);
    c.fill(255);
    c.ellipse(0, 0, size, size);
    c.rotate(angle);
    c.fill(153);
    c.ellipse(size/4, 0, size/2, size/2);
    c.popMatrix();
  }
}
//*****************************************************************************
			
			// start processing
			p.start();
		}
	}
}
