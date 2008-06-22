package processing.parser.statements
{
	import processing.parser.*;

	public class Return implements IExecutable
	{
		public var value:*;
	
		public function Return(v:*) {
			value = v;
		}
	
		public function execute(context:ExecutionContext):*
		{
			// throw this return
			throw this;
		}
	}
}
