package processing.parser.statements
{
	import processing.parser.*;

	public class Literal implements IExecutable
	{
		public var value:*;
	
		public function Literal(v:*) {
			value = v;
		}
	
		public function execute(context:ExecutionContext):*
		{
			// return literal
			return value;
		}
	}
}
