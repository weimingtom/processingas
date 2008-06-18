package processing.parser.statements
{
	import processing.parser.*;

	public class VariableSet implements IExecutable
	{
		public var _identifier:String;
		public var _value:*;
	
		public function VariableSet(identifier:String, value:*)
		{
			_identifier = identifier;
			_value = value;
		}
	
		public function execute(context:EvaluatorContext):*
		{
			// evaluate statements
			var value = _value is IExecutable ? _value.execute(context) : _value;
			
			// set value
			return (context.findVariableContext(_identifier) || context).scope[_identifier] = value;
		}
	}
}
