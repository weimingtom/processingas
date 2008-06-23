package {
	import flash.display.Sprite;
	import processing.Processing;
	import flash.external.ExternalInterface;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	[SWF(width="0", height="0", frameRate="60", backgroundColor="#ffffff")]
	
        public class processing extends Sprite {
		public var p:Processing;

		public function processing():void {
			// set stage mode
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			// initialize program
			ExternalInterface.addCallback('loadScript', loadScript);
			ExternalInterface.addCallback('preload', preload);
			ExternalInterface.call('ProcessingAS.init');
		}
		
		public function preload(... images):void {
			// preload images
			for each (var image in images)
				preloadImage(image);
			preloadCount += images.length;
		}
		
		private var preloadCount:int = 0;
		
		public function preloadImage(path:String, closure:Function):void {
			// preload image object
			var ldr:Loader = new Loader();
			var urlReq:URLRequest = new URLRequest(path);
			ldr.addEventListener(Event.COMPLETE, function (e:Event):void {
				// save preloaded image
				var image:BitmapData = new BitmapData(ldr.content.width, ldr.content.height);
				image.draw(ldr.content);
				p.applet.loadImage(path, image);
				
				// decrease preload count
				if (--preloadCount == 0)
					ExternalInterface.call('ProcessingAS.preloadHandler');
			});
			ldr.load(urlReq);
		}
		
		public function loadScript(code:String):void {
			// check if we need to reset
			if (p)
				reset();
				
			// create processing object
			p = new Processing();
		
			// attach sprite to stage
			addChild(p.applet);
			p.applet.graphics.addEventListener(flash.events.Event.RESIZE, resizeHandler);
			
			// evaluate code
			p.evaluate(code);
			// start the Processing API
			p.start();
		}
		
		public function reset():void {
			// stop scripts
			p.stop();
			
			// remove sprites
			removeChild(p.applet);
			p.applet.graphics.removeEventListener(flash.events.Event.RESIZE, resizeHandler);
			
			// reset stage framerate
			stage.frameRate = 60;
		}
		
		public function resizeHandler(e:Event):void {
			// dispatch resize handler
			ExternalInterface.call('ProcessingAS.resize', p.applet.graphics.width, p.applet.graphics.height);
			// move sprite
			x = -(p.applet.graphics.width / 2);
			y = -(p.applet.graphics.height / 2);
		}
	}
}
