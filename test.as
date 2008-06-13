package {
	import flash.display.Sprite;
	import processing.Processing;
	import mx.core.ByteArrayAsset;
	import flash.utils.ByteArray;
	
	[SWF(width="200", height="200", frameRate="24", backgroundColor="#ffffff")]
	
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
			// run code
			p.run(processingText);
		}
	}
}