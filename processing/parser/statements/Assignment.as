package processing.parser.statements
{
	import processing.parser.*;

	public class Assignment implements IExecutable
	{
		public var reference:Reference;
		public var value:*;
	
		public function Assignment(r:Reference, v:*)
		{
			reference = r;
			value = v;
		}
	
		public function execute(context:EvaluatorContext):*
		{
			// reduce reference
			var ref:Reference = reference.reduce(context);
			// evaluate value
			var val = value is IExecutable ? value.execute(context) : value;
			
			// set value
			return ref.base[ref.identifier] = val;
		}
	}
}
