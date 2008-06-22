package processing.parser.statements
{
	import processing.parser.*;

	public class VariableDefinition implements IExecutable
	{
		public var identifier:String;
		public var type:*;
		public var isArray:Boolean;
	
		public function VariableDefinition(i:String, t:*, a:Boolean = false) {
			identifier = i;
			type = t;
			isArray = a;
		}
	
		public function execute(context:ExecutionContext):*
		{
//[TODO] do something with type/array
			// define variable (by default, 0)
			context.scope[identifier] = 0;
		}
	}
}
