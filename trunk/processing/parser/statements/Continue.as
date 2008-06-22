package processing.parser.statements
{
	import processing.parser.*;

	public class Continue implements IExecutable
	{
		public var level:int = 1;
	
		public function Continue(l:int = 1) {
			level = l;
		}
	
		public function execute(context:EvaluatorContext):*
		{
			// throw exception
			throw new Continue(level);
		}
	}
}
