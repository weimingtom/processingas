package processing.parser {
	import processing.parser.*;
	import processing.parser.statements.*;

	public class Evaluator {
		public function Evaluator():void {
		}

//[TODO] what parameters should this take?
		public function evaluate(c:String, x:EvaluatorContext = null, p:Parser = null):* {
			// parse code
			var code:IExecutable = (p || new Parser()).parse(c);

			// execute code
			return code.execute(x || EvaluatorContext.getDefault());
		}
	}
}
