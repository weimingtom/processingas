package processing.parser.statements
{
	import processing.parser.*;

	public class Return extends Error implements IExecutable
	{
		public var value:*;
	
		public function Return(v:*) {
			super('Invalid return');
			
			value = v;
		}
	
		public function execute(context:ExecutionContext):*
		{
			// throw this return
			throw this;
		}
	}
}
