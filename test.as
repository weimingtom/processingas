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
			
			// evaluate code
			p.evaluate(processingText);
			// start the Processing API
			p.start();

			// debug parsing
//			var parser:Parser = new Parser();
//			var code:IExecutable = parser.parse(processingText);
//			trace(ObjectUtil.toString(code));
		}
	}
}
