package {
	import flash.display.Sprite;
	import processing.Processing;
	import processing.Context;
	import processing.parser.*;
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
			var evaluator:Evaluator = new Evaluator(p.context);
//			evaluator.evaluate();

//*****************************************************************************
// All Examples Written by Casey Reas and Ben Fry
// unless otherwise stated.

evaluator.evaluate(new Block(
	new Statement(evaluator.callMethod, ['size', [200, 200]]),
	new Statement(evaluator.callMethod, ['smooth']),
	new Statement(evaluator.callMethod, ['background', [0]]),
	new Statement(evaluator.callMethod, ['strokeWeight', [10]]),

	new Statement(evaluator.defineVar, [evaluator.INT, 'i']),
	new Statement(evaluator.setVar, ['i', 0]),
	new Statement(evaluator.loop, [
		new Statement(evaluator.expression, [new Statement(evaluator.getVar, ['i']), new Statement(evaluator.getVar, ['width']), evaluator.LT]),
		new Block(
			new Statement(evaluator.defineVar, [evaluator.FLOAT, 'r']),
			new Statement(evaluator.setVar, ['r', new Statement(evaluator.callMethod, ['random', [255]])]),
			new Statement(evaluator.defineVar, [evaluator.FLOAT, 'x']),
			new Statement(evaluator.setVar, ['x', new Statement(evaluator.callMethod, ['random', [0, new Statement(evaluator.getVar, ['width'])]])]),
			new Statement(evaluator.callMethod, ['stroke', [new Statement(evaluator.getVar, ['r']), 100]]),
			new Statement(evaluator.callMethod, ['line', [new Statement(evaluator.getVar, ['i']), 0, new Statement(evaluator.getVar, ['x']), new Statement(evaluator.getVar, ['height'])]]),
			new Statement(evaluator.setVar, ['i', new Statement(evaluator.expression, [new Statement(evaluator.getVar, ['i']), 1, evaluator.ADD])])
		)
	])
));

//c.i = 0;
//while (c.i < c.width) {
//  c.r = c.random(255);
//  c.x = c.random(0, c.width);
//  c.stroke(c.r, 100);
//  c.line(c.i, 0, c.x, c.height);
//  c.i++;
//}
//*****************************************************************************
			
			// start processing
			p.start();
		}
	}
}
