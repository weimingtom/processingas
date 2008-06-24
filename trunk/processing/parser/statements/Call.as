package processing.parser.statements
{
	import processing.parser.*;

	public class Call implements IExecutable
	{
		public var method:IExecutable;
		public var args:Array;
	
		public function Call(m:IExecutable, a:Array = null) {
			method = m;
			args = a;
		}
	
		public function execute(context:ExecutionContext):*
		{
			// iterate args statements
			var parsedArgs:Array = [];
			for each (var arg:IExecutable in args)
				parsedArgs.push(arg.execute(context));
			// apply function
			return method.execute(context).apply(context, parsedArgs);
		}
	}
}
