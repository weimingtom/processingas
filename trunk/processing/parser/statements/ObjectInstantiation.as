package processing.parser.statements
{
	import processing.parser.*;

	public class ObjectInstantiation implements IExecutable
	{
		public var _func:*;
		public var _args:Array;
	
		public function ObjectInstantiation(func:*, args:Array = undefined) {
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
			
			// create object instance
			switch (args.length)
			{
				case 0: return new func();
				case 1: return new func(args[0]);
				case 2: return new func(args[0], args[1]);
				case 3: return new func(args[0], args[1], args[2]);
				case 4: return new func(args[0], args[1], args[2], args[3]);
				case 5: return new func(args[0], args[1], args[2], args[3], args[4]);
				case 6: return new func(args[0], args[1], args[2], args[3], args[4], args[5]);
				case 7: return new func(args[0], args[1], args[2], args[3], args[4], args[5], args[6]);
				case 8: return new func(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7]);
				case 9: return new func(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8]);
				default: throw new Error('Constructor called with too many arguments.');
			}
		}
	}
}
