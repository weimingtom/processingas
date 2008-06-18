package processing.parser.statements
{
	import processing.parser.*;

	public class Call implements IExecutable
	{
		public var _func:*;
		public var _args:Array;
	
		public function Call(func:*, args:Array = undefined) {
			_func = func;
			_args = args;
		}
	
		public function execute(context:EvaluatorContext):*
		{
			// evaluate statements
			var func = _func is IExecutable ? _func.execute(context) : _func;
			// iterate args for statements
			var args:Array = [];
			for each (var arg:* in _args)
				args.push(arg is IExecutable ? arg.execute(context) : arg);
		
			// apply function
			return func.apply(context, args);
		}
	}
}
