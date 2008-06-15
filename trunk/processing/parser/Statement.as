package processing.parser {
	import processing.parser.Evaluator;

	public class Statement {
		public var func:String = '';
		public var args:Array = [];

		public function Statement(f:String, a:Array = undefined):void {
			func = f;
			args = a ? a : [];
		}

		public function execute(evaluator:Evaluator):* {
			return evaluator[func].apply(evaluator, args);
		}
	}
}
