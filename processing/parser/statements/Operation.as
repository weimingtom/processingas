package processing.parser.statements
{
	import processing.parser.*;

	public class Operation implements IExecutable
	{
		public var _a:*;
		public var _b:*;
		public var _type:TokenType;
	
		public function Operation(a:*, b:*, type:TokenType)
		{
			_a = a;
			_b = b;
			_type = type;
		}
	
		public function execute(context:EvaluatorContext):*
		{
			// evaluate statements
			var a = _a is IExecutable ? _a.execute(context) : _a;
			var b = _b is IExecutable ? _b.execute(context) : _b;

			// execute expression
			switch (_type) {
			    case TokenType.OR:			return a || b;
			    case TokenType.AND:		return a && b;
			    case TokenType.BITWISE_OR:		return a | b;
			    case TokenType.BITWISE_XOR:	return a ^ b;
			    case TokenType.BITWISE_AND:	return a & b;
			    case TokenType.EQ:			return a == b;
			    case TokenType.NE:			return a != b;
			    case TokenType.STRICT_EQ:		return a === b;
			    case TokenType.STRICT_NE:		return a !== b;
			    case TokenType.LT:			return a < b;
			    case TokenType.LE:			return a <= b;
			    case TokenType.GT:			return a > b;
			    case TokenType.GE:			return a >= b;
			    case TokenType.IN:			return a in b;
			    case TokenType.INSTANCEOF:		return a instanceof b;
			    case TokenType.LSH:		return a << b;
			    case TokenType.RSH:		return a >> b;
			    case TokenType.URSH:		return a >>> b;
			    case TokenType.PLUS:		return a + b;
			    case TokenType.MINUS:		return a - b;
			    case TokenType.MUL:		return a * b;
			    case TokenType.DIV:		return a / b;
			    case TokenType.MOD:		return a % b;
			    case TokenType.DOT:		return a[b];
			    default: throw new Error('Unrecognized expression operator.');
			}
		}
	}
}
