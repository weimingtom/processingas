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
	
		public function execute(context:ExecutionContext):*
		{
			// cast value
			var value:* = expression.execute(context);
			switch (type) {
			    case TokenType.INT:		return int(value);
			    case TokenType.FLOAT:	return Number(value);
			    case TokenType.BOOLEAN:	return Boolean(value);
			    case TokenType.CHAR:	return value is String ? value.charCodeAt(0) : value;
//[TODO] cast objects? arrays?
			    default:			return value;
			}
		}
	}
}
