package processing.parser.statements
{
	import processing.parser.*;

	public class VariableDefinition implements IExecutable
	{
		public var identifier:String;
		public var type:Type;
	
		public function VariableDefinition(i:String, t:Type) {
			identifier = i;
			type = t;
		}
	
		public function execute(context:ExecutionContext):*
		{
//[TODO] do something with type
			// define variable (by default, 0)
			context.scope[identifier] = 0;
		}
	}
}
