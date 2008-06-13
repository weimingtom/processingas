package {
	import flash.display.Sprite;
	import com.gamemeal.html.Canvas;
	import processing.Processing;
	import mx.core.ByteArrayAsset;
	import flash.utils.ByteArray;
	import flash.utils.*;
	
	[SWF(width="200", height="200", frameRate="24", backgroundColor="#ffffff")]
	
        public class test extends Sprite {
		[Bindable]
		[Embed(source="test.processing", mimeType="application/octet-stream")]
		private var ProcessingText:Class;

		public function test():void {
			// load processing.js
			var processingTextAsset:ByteArrayAsset = ByteArrayAsset(new ProcessingText());
			var processingText:String = processingTextAsset.readUTFBytes(processingTextAsset.length);
			
			var canvas:Canvas = new Canvas("myCanvas",160,160);
			addChild(canvas);
			
			Processing(canvas, processingText);
		}
	}
}