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
			var ref:Reference = reference.reduce(context);
			// set value
			return ref.base[ref.identifier] = value.execute(context);
		}
	}
}
