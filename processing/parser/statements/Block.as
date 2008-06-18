package processing.parser.statements
{
	import processing.parser.*;

	dynamic public class Block extends Array implements IExecutable
	{
		public function Block(... statements):void
		{
			for each (var statement:IExecutable in statements)
				push(statement);
		}
		
		public function append(block:Block)
		{
			// perform permanent concatenation
			for each (var statement:IExecutable in block)
				push(statement);
			return length;
		}

		public function execute(context:EvaluatorContext)
		{
			// iterate block
			var retValue:*;
			for each (var statement:* in this)
				retValue = (statement is IExecutable) ? statement.execute(context) : statement;
			return retValue;
		}
	}
}
