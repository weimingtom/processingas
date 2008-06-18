package processing.parser.statements
{
	import processing.parser.*;

	public class Conditional implements IExecutable
	{
		public var _condition:*;
		public var _thenBlock:Block;
		public var _elseBlock:Block;
	
		public function Conditional(condition:*, thenBlock:Block, elseBlock:Block = null)
		{
			_condition = condition;
			_thenBlock = thenBlock;
			_elseBlock = elseBlock;
		}
	
		public function execute(context:EvaluatorContext):*
		{
			if (_condition is IExecutable ? _condition.execute(context) : _condition)
				_thenBlock.execute(context);
			else if (_elseBlock)
				_elseBlock.execute(context);
		}
	}
}
