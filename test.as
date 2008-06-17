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
			
			// initialize parser objects
			var evaluator:Evaluator = new Evaluator();
			var context:EvaluatorContext = new EvaluatorContext(p.context);
			var parser:Parser = new Parser(evaluator);
			
			// debug parsing
//			parser.parse(processingText).debug(evaluator);

			// evaluate code
			evaluator.evaluate(parser.parse(processingText), context);
			// start the Processing API
			p.start();
		}
	}
}
