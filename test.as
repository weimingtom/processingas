package {
	import flash.display.Sprite;
	import processing.Processing;
	import processing.parser.Parser;
	import processing.parser.statements.IExecutable;
	import mx.core.ByteArrayAsset;
	import flash.utils.ByteArray;
	import flash.external.ExternalInterface;
	import mx.utils.ObjectUtil;
	import flash.display.StageScaleMode;
	
	[SWF(width="200", height="200", frameRate="60", backgroundColor="#ffffff")]
	
        public class test extends Sprite {
		[Bindable]
		[Embed(source="test.processing", mimeType="application/octet-stream")]
		private var ProcessingText:Class;
		
		[Bindable]
		[Embed(source="ystone08.jpg", mimeType="image/jpeg")]
		private var ProcessingImage:Class;
		
		private var p:Processing;

		public function test():void {
			// create processing object
			p = new Processing();
			stage.addChild(p.applet);
			
			// preload images
			p.applet.loadImage('ystone08.jpg', (new ProcessingImage).bitmapData);
			
			// load processing.js
			var processingTextAsset:ByteArrayAsset = ByteArrayAsset(new ProcessingText());
			var processingText:String = processingTextAsset.readUTFBytes(processingTextAsset.length);
		
			var debug:Boolean = false;
			
			if (!debug) {
				// evaluate code
				p.evaluate(processingText);
				// start the Processing API
				p.start();
			} else {
				// debug parsing
				var parser:Parser = new Parser();
				var code:IExecutable = parser.parse(processingText);
				trace(ObjectUtil.toString(code));
			}
		}
	}
}
