package {
	import flash.display.Sprite;
	import processing.api.*;
	import processing.parser.*;
	import processing.parser.statements.IExecutable;
	import mx.core.ByteArrayAsset;
	import flash.utils.ByteArray;
	import flash.external.ExternalInterface;
	import mx.utils.ObjectUtil;
	
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

			// debug parsing
//			var parser:Parser = new Parser();
//			var code:IExecutable = parser.parse(processingText);
//			trace(ObjectUtil.toString(code));
			
			// initialize parser objects
			var evaluator:Evaluator = new Evaluator();
			var context:EvaluatorContext = new EvaluatorContext(p.context);

			// evaluate code
			evaluator.evaluate(processingText, context);
/*
// All Examples Written by Casey Reas and Ben Fry
// unless otherwise stated.
var theta, c = p.context;

function branch(h) {
  // Each branch will be 2/3rds the size of the previous one
  h *= 0.66;
  
  // All recursive functions must have an exit condition!!!!
  // Here, ours is when the length of the branch is 2 pixels or less
  if (h > 2) {
    c.pushMatrix();    // Save the current state of transformation (i.e. where are we now)
    c.rotate(theta);   // Rotate by theta
    c.line(0,0,0,-h);  // Draw the branch
    c.translate(0,-h); // Move to the end of the branch
    branch(h);
    c.popMatrix();     // Whenever we get back here, we "pop" in order to restore the previous matrix state
    
    // Repeat the same thing, only branch off to the "left" this time!
    c.pushMatrix();
    c.rotate(-theta);
    c.line(0,0,0,-h);
    c.translate(0,-h);
    branch(h);
    c.popMatrix();
  }
}

c.setup = function () {
  c.size(200,200);
  c.smooth();
}

c.draw = function () {
  c.background(0);
  c.frameRate(30);
  c.stroke(255);
  // Let's pick an angle 0 to 90 degrees based on the mouse position
  var a = (c.mouseX / c.width) * 90;
  // Convert it to radians
  theta = c.radians(a);
  // Start the tree from the bottom of the screen
  c.translate(c.width/2,c.height);
  // Draw a line 60 pixels
  c.line(0,0,0,-60);
  // Move to the end of that line
  c.translate(0,-60);
  // Start the recursive branching!
  branch(60);
}


*/

			// start the Processing API
			p.start();
		}
	}
}
