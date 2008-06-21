package processing.parser.statements
{
	import processing.parser.*;

	public class Cast implements IExecutable
	{
		public var type:*;
		public var expression:IExecutable;
	
		public function Cast(t:*, e:IExecutable) {
			type = t;
			expression = e;
		}
	
		public function execute(context:EvaluatorContext):*
		{
			// cast value
//[TODO] actually cast this
			return expression.execute(context);
		}
	}
}
