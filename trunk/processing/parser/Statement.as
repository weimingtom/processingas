package processing.parser {
	import processing.parser.Evaluator;

	public class Statement {
		public var func:Function;
		public var args:Array = [];

		public function Statement(f:Function, a:Array = undefined):void {
			func = f;
			args = a ? a : [];
		}

		public function execute(evaluator:Evaluator):* {
			return func.apply(evaluator, args);
		}
	}
}
