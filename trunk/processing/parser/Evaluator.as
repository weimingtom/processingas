package processing.parser {
	import processing.parser.*;

	public class Evaluator {
		public function Evaluator():void {
		}

//[TODO] what parameters should this take?
		public function evaluate(code:*, x:EvaluatorContext = null):* {
			// execute code
			return code.execute(x || new EvaluatorContext());
		}
		
		//--------------------------------------------------------------
		// execution methods
		//--------------------------------------------------------------
		
//[TODO] should literals be wrapped in Statement functions?
//        - would simplify parsing 
//        - would compilicate everything else
//        - will getVar ever be called with a Statement? makes case that String shouldn't be supported...

		public function callMethod(context:EvaluatorContext, func:*, args:Array = undefined) {
			// evaluate statements
			if (func instanceof Statement)
				func = func.execute(context);
			// parse args for statements
			var parsedArgs:Array = [];
			for each (var i:* in args)
				parsedArgs.push(i instanceof Statement ? i.execute(context) : i);

			// apply function
			return func.apply(context, parsedArgs);
		}

		public function defineVar(context:EvaluatorContext, name:String, type:TokenType) {
//[TODO] do something with type
			context.scope[name] = undefined;
		}

		public function defineFunction(context:EvaluatorContext, name:String, type:TokenType, params:Array, body:Block) {
//[TODO] do something with type
			context.scope[name] = function (... args) {
				// create new evaluator context
				var funcContext:EvaluatorContext = new EvaluatorContext({}, context);

				// parse args
				for (var i in args) {
//[TODO] what happens when args/params differ?
					defineVar(funcContext, params[i][0], params[i][1]);
					setVar(funcContext, params[i][0], args[i]);
				}
				
				// evaluate body
				return body.execute(funcContext);
			}
		}

		public function loop(context:EvaluatorContext, condition:*, body:Block) {
			while (condition is Statement ? condition.execute(context) : condition)
				body.execute(context);
		}
		
		public function conditional(context:EvaluatorContext, condition:*, thenBlock:Block, elseBlock:Block = null) {
			if (condition is Statement ? condition.execute(context) : condition)
				thenBlock.execute(context);
			else if (elseBlock)
				elseBlock.execute(context);
		}

		public function expression(context:EvaluatorContext, a:*, b:*, type:TokenType) {
			// evaluate statements
			if (a instanceof Statement)
				a = a.execute(context);
			if (b instanceof Statement)
				b = b.execute(context);

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

//[TODO] varName will absolutely have to be a reference object in the future
		public function getVar(context:EvaluatorContext, varName:String) {
			for (var c:EvaluatorContext = context; !c.scope.hasOwnProperty(varName) && c.parent; c = c.parent);
			return (c.scope.hasOwnProperty(varName) ? c : context).scope[varName];
		}

		public function setVar(context:EvaluatorContext, varName:String, value:*) {
			// parse statements
			if (value instanceof Statement)
				value = value.execute(context);
			for (var c:EvaluatorContext = context; !c.scope.hasOwnProperty(varName) && c.parent; c = c.parent);
			return ((c.scope.hasOwnProperty(varName) ? c : context).scope[varName] = value);
		}
	}
}
