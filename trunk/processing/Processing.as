package processing {
	import processing.api.PApplet;
	import processing.parser.Parser;
	import processing.parser.statements.IExecutable;
	import flash.display.Loader;
	import flash.events.Event;

	public class Processing {
		public var applet:PApplet;

		public function Processing():void {
			// create applet
			applet = new PApplet();
		}
		
		public function evaluate(c:String):* {
			// parse code
			var code:IExecutable = (new Parser()).parse(c);
			// execute code
			return code.execute(applet.context);
		}
		
		public function start():void {
			// start applet
			applet.start();
		}
		
		public function stop():void {
			// stop applet
			applet.stop();
		}
	}
}
