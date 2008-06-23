package processing.parser.statements
{
	import processing.parser.*;

	public class Continue extends Error implements IExecutable
	{
		public var level:int = 1;
	
		public function Continue(l:int = 1) {
			super('Invalid continue');
		
			level = l;
		}
	
		public function execute(context:ExecutionContext):*
		{
			// throw exception
			throw new Continue(level);
		}
	}
}
