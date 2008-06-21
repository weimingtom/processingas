package processing.parser.statements
{
	import processing.parser.*;

	public class Assignment implements IExecutable
	{
		public var reference:Reference;
		public var value:IExecutable;
	
		public function Assignment(r:Reference, v:IExecutable)
		{
			reference = r;
			value = v;
		}
	
		public function execute(context:EvaluatorContext):*
		{
			// reduce reference
			var ref:Array = reference.reduce(context);
			// set value
			return ref[1][ref[0]] = value.execute(context);
		}
	}
}
