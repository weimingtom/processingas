package processing.parser.statements
{
	import processing.parser.*;

	public class VariableGet implements IExecutable
	{
		public var _identifier:String;
	
//[TODO] should identifier be a Reference object?
		public function VariableGet(identifier:String)
		{
			_identifier = identifier;
		}
	
		public function execute(context:EvaluatorContext):*
		{
			// return value
			var varContext:EvaluatorContext = context.findVariableContext(_identifier);
			return varContext ? varContext.scope[_identifier] : undefined;
		}
	}
}
