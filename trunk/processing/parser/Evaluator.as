package processing.parser {
	import processing.parser.*;

	public class Evaluator {
		// constants
		private var context:Object = {};

		public function Evaluator(c:Object):void {
//[TODO] do a real context...
			context = c;
		}

//[TODO] what parameter should this take?
		public function evaluate(code:*):* {
			return code.execute(this);
		}
		
		//--------------------------------------------------------------
		// execution methods
		//--------------------------------------------------------------
		
//[TODO] should literals be wrapped in Statement functions?
//        - would simplify parsing 
//        - would compilicate everything else
//        - will getVar ever be called with a Statement? makes case that String shouldn't be supported...

		public function callMethod(func:*, args:Array = undefined) {
			// evaluate statements
			if (func instanceof Statement)
				func = func.execute(this);
			// parse args for statements
			var parsedArgs:Array = [];
			for each (var i:* in args)
				parsedArgs.push(i instanceof Statement ? i.execute(this) : i);

			// apply function
			return func.apply(context, parsedArgs);
		}

		public function defineVar(name:String, type:TokenType) {
//[TODO] do something with type
			context[name] = undefined;
		}

		public function defineFunction(name:String, block:Block) {
			var evaluator:Evaluator = this;
			context[name] = function () {
				return block.execute(evaluator);
			}
		}

		public function loop(cond:*, block:Block) {
			while (cond is Statement ? cond.execute(this) : cond)
				block.execute(this);
		}

		public function expression(a:*, b:*, type:TokenType) {
			// evaluate statements
			if (a instanceof Statement)
				a = a.execute(this);
			if (b instanceof Statement)
				b = b.execute(this);

			// execute expression
			switch (type) {
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
			    case TokenType.GE:			return a > b;
			    case TokenType.GT:			return a >= b;
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
			    default: throw new Error('Unrecognized expression operator.');
			}
		}

		public function getVar(varName:String) {
			return context[varName];
		}

		public function setVar(varName:String, value:*) {
			// parse statements
			if (value instanceof Statement)
				value = value.execute(this);
			return (context[varName] = value);
		}
	}
}
