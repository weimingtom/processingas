package processing.parser.statements
{
	import processing.parser.*;

	public class VariableDefinition implements IExecutable
	{
		public var _identifier:String;
		public var _type:*;
		public var _isArray:Boolean;
	
		public function VariableDefinition(identifier:String, type:*, isArray:Boolean = false) {
			_identifier = identifier;
			_type = type;
			_isArray = isArray;
		}
	
		public function execute(context:EvaluatorContext):*
		{
//[TODO] do something with type/array
			context.scope[_identifier] = undefined;
		}
	}
}
