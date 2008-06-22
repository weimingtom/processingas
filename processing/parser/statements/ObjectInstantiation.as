package processing.parser.statements
{
	import processing.parser.*;

	public class ObjectInstantiation implements IExecutable
	{
		public var method:IExecutable;
		public var args:Array;
	
		public function ObjectInstantiation(m:IExecutable, a:Array = undefined) {
			method = m;
			args = a;
		}
	
		public function execute(context:ExecutionContext):*
		{
			// parse class
			var objClass:* = method.execute(context);
			// iterate args statements
			var parsedArgs:Array = [];
			for each (var arg:IExecutable in args)
				parsedArgs.push(arg.execute(context));
			
			// create object instance
			switch (args.length)
			{
				case 0: return new objClass();
				case 1: return new objClass(parsedArgs[0]);
				case 2: return new objClass(parsedArgs[0], parsedArgs[1]);
				case 3: return new objClass(parsedArgs[0], parsedArgs[1], parsedArgs[2]);
				case 4: return new objClass(parsedArgs[0], parsedArgs[1], parsedArgs[2], parsedArgs[3]);
				case 5: return new objClass(parsedArgs[0], parsedArgs[1], parsedArgs[2], parsedArgs[3], parsedArgs[4]);
				case 6: return new objClass(parsedArgs[0], parsedArgs[1], parsedArgs[2], parsedArgs[3], parsedArgs[4], parsedArgs[5]);
				case 7: return new objClass(parsedArgs[0], parsedArgs[1], parsedArgs[2], parsedArgs[3], parsedArgs[4], parsedArgs[5], parsedArgs[6]);
				case 8: return new objClass(parsedArgs[0], parsedArgs[1], parsedArgs[2], parsedArgs[3], parsedArgs[4], parsedArgs[5], parsedArgs[6], parsedArgs[7]);
				case 9: return new objClass(parsedArgs[0], parsedArgs[1], parsedArgs[2], parsedArgs[3], parsedArgs[4], parsedArgs[5], parsedArgs[6], parsedArgs[7], parsedArgs[8]);
				default: throw new Error('Constructor called with too many arguments.');
			}
		}
	}
}
