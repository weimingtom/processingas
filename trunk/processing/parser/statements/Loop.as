package processing.parser.statements
{
	import processing.parser.*;

	public class Loop implements IExecutable
	{
		public var condition:IExecutable;
		public var body:IExecutable;
	
		public function Loop(c:IExecutable, b:IExecutable)
		{
			condition = c;
			body = b;
		}
	
		public function execute(context:EvaluatorContext):*
		{
			while (condition.execute(context))
				body.execute(context);
		}
	}
}
