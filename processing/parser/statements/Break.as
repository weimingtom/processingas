package processing.parser.statements
{
	import processing.parser.*;

	public class Break implements IExecutable
	{
		public var level:int = 1;
	
		public function Break(l:int = 1) {
			level = l;
		}
	
		public function execute(context:EvaluatorContext):*
		{
			// throw exception
			throw new Break(level);
		}
	}
}
