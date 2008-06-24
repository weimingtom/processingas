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
	
		public function execute(context:ExecutionContext):*
		{
			if (condition.execute(context))
				return thenBlock.execute(context);
			else if (elseBlock)
				return elseBlock.execute(context);
		}
	}
}
