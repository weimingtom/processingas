package processing.parser.statements
{
	import processing.parser.*;

	public class Loop implements IExecutable
	{
		public var _condition:*;
		public var _body:Block;
	
		public function Loop(condition:*, body:Block)
		{
			_condition = condition;
			_body = body;
		}
	
		public function execute(context:EvaluatorContext):*
		{
			while (_condition is IExecutable ? _condition.execute(context) : _condition)
				_body.execute(context);
		}
	}
}
