package processing.parser.statements
{
	import processing.parser.*;

	public class ThisReference implements IExecutable
	{
		public function ThisReference()
		{
		}
	
		public function execute(context:EvaluatorContext):*
		{
			// climb context inheritance to find defined thisObject
			for (var c:EvaluatorContext = context;
			    c && !c.thisObject;
			    c = c.parent);
			return c ? c.thisObject : undefined;
		}
	}
}