package processing.parser.statements
{
	import processing.parser.*;

	public class FunctionDefinition implements IExecutable
	{
		public var _identifier:String;
		public var _type:*;
		public var _params:Array;
		public var _body:Block;
	
		public function FunctionDefinition(identifier:String, type:*, params:Array, body:Block) {
			_identifier = identifier;
			_type = type;
			_params = params;
			_body = body;
		}
		
		public function execute(context:EvaluatorContext):*
		{
//[TODO] do something with type
			context.scope[_identifier] = function (... args)
			{
				// check that this be called as a function
//[TODO] that

				// create new evaluator context
				var funcContext:EvaluatorContext = new EvaluatorContext({}, context);

				// parse args
				for (var i in args) {
//[TODO] what happens when args/params differ?
					(new VariableDefinition(_params[i][0], _params[i][1])).execute(funcContext);
					(new Assignment(new Reference(_params[i][0]), args[i])).execute(funcContext);
				}
				
				// evaluate body
				return _body.execute(funcContext);
			}
		}
	}
}
