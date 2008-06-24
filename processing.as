package {
	import flash.display.Sprite;
	import processing.Processing;
	import flash.external.ExternalInterface;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.*;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.net.URLRequest;
	
	[SWF(width="0", height="0", frameRate="60", backgroundColor="#ffffff")]
	
        public class processing extends Sprite {
		public var p:Processing;

		public function processing():void {
			// initialize preloader
			preloader = new Loader();
			preloader.contentLoaderInfo.addEventListener(Event.COMPLETE, preloaderHandler);
		
			// set stage mode
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			// initialize program
			ExternalInterface.addCallback('loadScript', loadScript);
			ExternalInterface.call('ProcessingAS.init');
		}
		
		public function loadScript(script:String, images:Array = null):void {
			// check if we need to reset
			if (p)
				reset();
			// create processing object
			p = new Processing();
			
			// save current script
			this.script = script;
			
			// start method
			if (images && images.length) {
				// preload images
				preloadStack = images;
				preloadImages();
			} else {
				// start immediately
				startScript();
			}
		}
		
		private var script:String = '';
		
		private function startScript():void {
		
			// attach sprite to stage
			addChild(p.applet);
			p.applet.graphics.addEventListener(flash.events.Event.RESIZE, resizeHandler);
			
			// evaluate code
			p.evaluate(script);
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
		
		private var preloadStack:Array = [];
		private var preloader:Loader;
		
		public function preloadImages():void {
			// check that there is an image to be loaded
			if (!preloadStack.length) {
				// done preloading
				startScript();
				return;
			}
		
			// load image path
			preloader.load(new URLRequest(preloadStack[preloadStack.length - 1]));
		}
		
		private function preloaderHandler(e:Event):void {
			// pop stack and save preloaded image
			var path:String = preloadStack.pop();
			var image:BitmapData = new BitmapData(preloader.content.width, preloader.content.height);
			image.draw(preloader.content);
			p.applet.loadImage(path, image);
			
			// preload next image
			preloadImages();
		}
		
		private function alert(e:*):void {
			ExternalInterface.call('alert', e);
		}
	}
}
