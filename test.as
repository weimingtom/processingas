package {
	import flash.display.Sprite;
	import processing.Processing;
	import processing.Context;
	import processing.parser.*;
	import mx.core.ByteArrayAsset;
	import flash.utils.ByteArray;
	import flash.external.ExternalInterface;
	
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
			
			// try some parsin'
			var evaluator:Evaluator = new Evaluator(p.context);
			var parser:Parser = new Parser(evaluator);
parser.parse(processingText).debug(evaluator);
			evaluator.evaluate(parser.parse(processingText));
			
			// evaluate code
//			var parser:Parser = new Parser();
//			parser.evaluate(processingText, p);
//			evaluator.evaluate();

//*****************************************************************************
// All Examples Written by Casey Reas and Ben Fry
// unless otherwise stated.
/*
var code:Block = new Block(
	//new Statement(evaluator.defineFunction, ['setup', new Block(
		new Statement(evaluator.callMethod, ['size', [200, 200]]),
		new Statement(evaluator.callMethod, ['smooth']),
		new Statement(evaluator.callMethod, ['background', [0]]),
		new Statement(evaluator.callMethod, ['strokeWeight', [10]])
	//)]),
,
//	new Statement(evaluator.defineFunction, ['draw', new Block(
		new Statement(evaluator.defineVar, ['i', evaluator.INT]),
		new Statement(evaluator.setVar, ['i', 0]),
		new Statement(evaluator.loop, [
			new Statement(evaluator.expression, [new Statement(evaluator.getVar, ['i']), new Statement(evaluator.getVar, ['width']), evaluator.LT]),
			new Block(
				new Statement(evaluator.defineVar, ['r', evaluator.FLOAT]),
				new Statement(evaluator.setVar, ['r', new Statement(evaluator.callMethod, ['random', [255]])]),
				new Statement(evaluator.defineVar, ['x', evaluator.FLOAT]),
				new Statement(evaluator.setVar, ['x', new Statement(evaluator.callMethod, ['random', [0, new Statement(evaluator.getVar, ['width'])]])]),
				new Statement(evaluator.callMethod, ['stroke', [new Statement(evaluator.getVar, ['r']), 100]]),
				new Statement(evaluator.callMethod, ['line', [new Statement(evaluator.getVar, ['i']), 0, new Statement(evaluator.getVar, ['x']), new Statement(evaluator.getVar, ['height'])]]),
				new Statement(evaluator.setVar, ['i', new Statement(evaluator.expression, [new Statement(evaluator.getVar, ['i']), 1, evaluator.ADD])])
			)
		])
//	)])
);
*/
//evaluator.evaluate(code);
/*
// All Examples Written by Casey Reas and Ben Fry
// unless otherwise stated.
c.setup = function () {
	c.size(200, 200);
	c.smooth();
	c.background(0);
	c.strokeWeight(10);
}

c.draw = function () {
	for(var i = 0; i < c.width; i++) {
	  var r = c.random(255);
	  var x = c.random(0, c.width);
	  c.stroke(r, 100);
	  c.line(i, 0, x, c.height);
	}
} */
//*****************************************************************************
			
			// start processing
			p.start();
		}
	}
}
