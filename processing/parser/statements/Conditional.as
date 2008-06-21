package processing.parser.statements
{
	import processing.parser.*;

	public class Conditional implements IExecutable
	{
		public var condition:IExecutable;
		public var thenBlock:IExecutable;
		public var elseBlock:IExecutable;
	
		public function Conditional(c:IExecutable, t:IExecutable, e:IExecutable = null)
		{
			condition = c;
			thenBlock = t;
			elseBlock = e;
		}
	
		public function execute(context:EvaluatorContext):*
		{
			if (condition.execute(context))
				thenBlock.execute(context);
			else if (elseBlock)
				elseBlock.execute(context);
		}
	}
}
