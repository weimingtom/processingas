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
	
		public function execute(context:ExecutionContext):*
		{
			while (condition.execute(context)) {
				try {
					// execute body
					body.execute(context);
				} catch (b:Break) {
					// decrease level and rethrow if necessary
					if (--b.level)
						throw b;
					// else break loop
					break;
				} catch (c:Continue) {
					// decrease level and rethrow if necessary
					if (--c.level)
						throw c;
					// else continue loop
					continue;
				}
			}
		}
	}
}
