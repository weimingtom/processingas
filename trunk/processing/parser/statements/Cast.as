package processing.parser.statements
{
	import processing.parser.*;

	public class Cast implements IExecutable
	{
		public var type:*;
		public var expression:*;
	
		public function Cast(t:*, e:*) {
			type = t;
			expression = e;
		}
	
		public function execute(context:EvaluatorContext):*
		{
			// cast value
//[TODO] actually cast this
			return (expression is IExecutable) ? expression.execute(context) : expression;
		}
	}
}
