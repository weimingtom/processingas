package {
	import flash.display.Sprite;
	import processing.Processing;
	import processing.api.PMath;
	import flash.external.ExternalInterface;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.utils.describeType;
	import flash.display.StageQuality;
	
	[SWF(width="0", height="0", frameRate="60", backgroundColor="#ffffff")]
	
        public class processing extends Sprite {
		public var p:Processing;

		public function processing():void {
			// initialize preloader
			preloader = new Loader();
			preloader.contentLoaderInfo.addEventListener(Event.COMPLETE, preloaderHandler);
		
			// set stage mode
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			// add callbacks
			ExternalInterface.addCallback('start', start);
			ExternalInterface.addCallback('stop', stop);
			ExternalInterface.addCallback('run', run);
			
			// call load handler
			ExternalInterface.call('ProcessingAS.onLoad');
		}
		
		public function start():void {
			// check if we need to reset
			if (p)
				stop();
			// create processing object
			p = new Processing();

			// attach sprite to stage
			addChild(p.applet);
			p.applet.graphics.addEventListener(flash.events.Event.RESIZE, resizeHandler);
			
			// externalize objects
			externalize(p.applet.graphics);
			externalize(PMath);
			
			// reset stage variables
			stage.frameRate = 60;
			stage.quality = StageQuality.LOW;

			// call start handler
			ExternalInterface.call('ProcessingAS.onStart');
		}
		
		public function stop():void {
			// stop scripts
			p.stop();
			
			// remove sprites
			removeChild(p.applet);
			p.applet.graphics.removeEventListener(flash.events.Event.RESIZE, resizeHandler);
			
			// delete processing object
			p = null;
			
			// call stop handler
			ExternalInterface.call('ProcessingAS.onStop');
		}
		
		public function run(script:String, images:Array = null):void {
			// start script
			start();
			
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
			// evaluate code
			p.evaluate(script);
			// start the Processing API
			p.start();
		}
		
		public function resizeHandler(e:Event):void {
			// dispatch resize handler
			ExternalInterface.call('ProcessingAS.onResize', p.applet.graphics.width, p.applet.graphics.height);
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
			preloader.load(new URLRequest(preloadStack[preloadStack.length - 1][1]));
		}
		
		private function preloaderHandler(e:Event):void {
			// pop stack and save preloaded image
			var path:Array = preloadStack.pop();
			var image:BitmapData = new BitmapData(preloader.content.width, preloader.content.height);
			image.draw(preloader.content);
			p.applet.loadImage(path[0], image);
			
			// preload next image
			preloadImages();
		}
		
		private function externalize(obj:Object):void {
			// add callbacks
			var description:XML = describeType(obj);
			for each (var method:String in description..method.(@declaredBy==description.@name).@name)
				ExternalInterface.addCallback(method, obj[method]);
		}
	}
}
