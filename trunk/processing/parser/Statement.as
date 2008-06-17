package processing.parser {
	import processing.parser.Evaluator;

	public class Statement {
		public var func:Function;
		public var args:Array = [];

		public function Statement(f:Function, a:Array = undefined):void {
			func = f;
			args = a ? a : [];
		}

		public function execute(context:EvaluatorContext):* {
			return func.apply(null, [context].concat(args));
		}
		
		public function debug(evaluator:Evaluator, indent = 0):void {
			var name = '', ind = '';
			for each (var i in ['callMethod', 'createInstance', 'defineVar', 'defineFunction', 'defineClass',
			    'loop', 'conditional', 'useScope', 'expression', 'getVar', 'setVar'])
				if (func == evaluator[i])
					name = i;
			for (var l = 0; l < indent; l++)
				ind += '\t';
		
			trace(ind + name + '(');
			for (var i:* in args)
				if (args[i] is Block || args[i] is Statement)
					args[i].debug(evaluator, indent + 1);
				else if (args[i] is Array)
					for (var j in args[i])
						if (args[i][j] is Block || args[i][j] is Statement){
							trace(ind + '\targument[' + i + '][' + j + ']:');
							args[i][j].debug(evaluator, indent + 1);
						} else
							trace(ind + '\targument[' + i + '][' + j + ']: "' + args[i][j] + '"');
				else
					trace(ind + '\targument[' + i + ']: "' + args[i] + '"');
			trace(ind + ')');
		}
	}
}
