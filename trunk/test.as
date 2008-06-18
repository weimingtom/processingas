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
			// start the Processing API
			p.start();
		}
	}
}
