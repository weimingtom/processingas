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
	new Statement('callMethod', ['size', [200, 200]]),
	new Statement('callMethod', ['smooth']),
	new Statement('callMethod', ['background', [0]]),
	new Statement('callMethod', ['strokeWeight', [10]]),

	new Statement('defineVar', [evaluator.INT, 'i', 0]),
	new Statement('loop', [
		new Statement('expression', [new Statement('getValue', ['i']), new Statement('getValue', ['width']), evaluator.LT]),
		new Block(
			new Statement('defineVar', [evaluator.FLOAT, 'r', new Statement('callMethod', ['random', [255]])]),
			new Statement('defineVar', [evaluator.FLOAT, 'x', new Statement('callMethod', ['random', [0, new Statement('getValue', ['width'])]])]),
			new Statement('callMethod', ['stroke', [new Statement('getValue', ['r']), 100]]),
			new Statement('callMethod', ['line', [new Statement('getValue', ['i']), 0, new Statement('getValue', ['x']), new Statement('getValue', ['height'])]]),
			new Statement('setValue', ['i', new Statement('expression', [new Statement('getValue', ['i']), 1, evaluator.ADD])])
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
