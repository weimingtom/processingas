package processing.parser.statements
{
	import processing.parser.*;

	public class ThisReference implements IExecutable
	{
		public function ThisReference()
		{
		}
	
		public function execute(context:ExecutionContext):*
		{
			// climb context inheritance to find defined thisObject
			for (var c:ExecutionContext = context;
			    c && !c.thisObject;
			    c = c.parent);
			return c ? c.thisObject : undefined;
		}
	}
}
