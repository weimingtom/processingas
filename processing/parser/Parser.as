package processing.parser {
	import processing.parser.*;
	import processing.parser.statements.*;
	
	public class Parser {
		public var tokenizer:Tokenizer;
//[TODO] no parser contexts; but maybe add a Block.definitions array?
//		public var context:ParserContext;
	
		public function Parser() {
			// create tokenizer
			tokenizer = new Tokenizer();
		}
		
		public function parse(code:String):Block {
			// initialize tokenizer
			tokenizer.load(code);
			
			// parse script
			var script:Block = parseBlock();
			if (!tokenizer.done)
				throw new TokenizerSyntaxError('Syntax error', tokenizer);
			return script;
		}
		
		private function parseBlock(stopAt:TokenType = null):Block {
			// parse code block
			var block:Block = new Block();
//[TODO] right_curly should be a stopAt
			while (!tokenizer.done && (!stopAt || !tokenizer.peek().match(stopAt)))
				block.append(parseStatement());
			return block;			
		}

//[TODO] could parseStatement be made to only match certain "types"?
		private function parseStatement():Block {
			// parse current statement line
			var block:Block = new Block();

			// peek to see what kind of statement this is
			var token:Token = tokenizer.peek();
//trace('Currently parsing in Statement: ' + TokenType.getConstant(token.type));
			switch (token.type)
			{				
			    // if block
			    case TokenType.IF:
				// get condition
				tokenizer.get();
				tokenizer.match(TokenType.LEFT_PAREN, true);
				var condition:IExecutable = parseExpression();
				tokenizer.match(TokenType.RIGHT_PAREN, true);
				// get then block
				if (tokenizer.match(TokenType.LEFT_CURLY)) {
					var thenBlock:Block = parseBlock(TokenType.RIGHT_CURLY);
					tokenizer.match(TokenType.RIGHT_CURLY, true);
				} else
					var thenBlock:Block = parseStatement();
				// get else block
				if (tokenizer.match(TokenType.ELSE)) {
					if (tokenizer.match(TokenType.LEFT_CURLY)) {
						var elseBlock:Block = parseBlock(TokenType.RIGHT_CURLY);
						tokenizer.match(TokenType.RIGHT_CURLY, true);
					} else
						var elseBlock:Block = parseStatement();
				}
				
				// push conditional
				block.push(new Conditional(condition, thenBlock, elseBlock));
				return block;

			    // for statement
			    case TokenType.FOR:
				// match opening 'for' and '('
				tokenizer.get();
				tokenizer.match(TokenType.LEFT_PAREN, true);
				
				// match initializer
				if (!tokenizer.match(TokenType.SEMICOLON)) {
					// variable definitions
					if ((tokenizer.peek().match(TokenType.TYPE) ||
					    tokenizer.peek().match(TokenType.IDENTIFIER)) &&
					    tokenizer.peek(2).match(TokenType.IDENTIFIER))
					    	block.append(parseVariables());
					// expression
					else
						block.push(parseExpression(TokenType.SEMICOLON));
						
					// match semicolon
					tokenizer.match(TokenType.SEMICOLON, true);
				}
				
				// match condition
				var condition:IExecutable = parseExpression(TokenType.SEMICOLON);
				tokenizer.match(TokenType.SEMICOLON, true);
				// match update
				var update:IExecutable = parseExpression(TokenType.RIGHT_PAREN);
				tokenizer.match(TokenType.RIGHT_PAREN, true);
				// parse body
				if (tokenizer.match(TokenType.LEFT_CURLY)) {
					var body:Block = parseBlock(TokenType.RIGHT_CURLY);
					tokenizer.match(TokenType.RIGHT_CURLY, true);
				} else
					var body:Block = parseStatement();
				
				// append loop body
				if (update)
					body.push(update);
				// push for loop
				block.push(new Loop(condition, body));
				return block;
			
			    // returns
			    case TokenType.RETURN:
				tokenizer.get();
				// push return statement
				block.push(new Return(parseExpression()));
				break;
			
			    // break
			    case TokenType.BREAK:
				tokenizer.get();			
				// match break and optional level
				block.push(new Break(tokenizer.match(TokenType.NUMBER) ?
				    tokenizer.currentToken.value : 1));					
				break;
				
			    // continue
			    case TokenType.CONTINUE:
				tokenizer.get();			
				// match continue and optional level
				block.push(new Continue(tokenizer.match(TokenType.NUMBER) ?
				    tokenizer.currentToken.value : 1));					
				break;
				
			    // definition visibility
			    case TokenType.STATIC:
			    case TokenType.PUBLIC:
			    case TokenType.PRIVATE:
//[TODO] what happens when "private" declared in main block? "static"?
				// get definition
				tokenizer.get();
				block.push(tokenizer.peek().match(TokenType.CLASS) ? parseClass() : parseFunction());
				return block;
				
			    case TokenType.CLASS:
				// get class definition
				block.push(parseClass());
				return block;
			
			    // definitions
			    case TokenType.TYPE:
			    case TokenType.IDENTIFIER:
				// resolve ambiguous identifier
				if (tokenizer.peek(2).match(TokenType.IDENTIFIER)) {
					// get parsed function
					if (tokenizer.peek(3).match(TokenType.LEFT_PAREN))
						return new Block(parseFunction());
						
					// else, get variable list
					block.append(parseVariables());
					break;
				}
				// fall-through
			
			    // expression
			    default:
				block.push(parseExpression(TokenType.SEMICOLON));
				break;
			}

			// match terminating semicolon
			if (!tokenizer.match(TokenType.SEMICOLON))
				throw new TokenizerSyntaxError('Missing ; after statement', tokenizer);
			// return parsed statement
			return block;
		}
		
		private function parseType():Type {
			// try and match a type declaration
			if (tokenizer.match(TokenType.TYPE))
				return tokenizer.currentToken.value;
			if (tokenizer.match(TokenType.IDENTIFIER))
				return new Type(tokenizer.currentToken.value);

			// could not match type
			return null;
		}
		
		private function parseFunction():FunctionDefinition {
			// get function type
			if (tokenizer.peek(2).match(TokenType.IDENTIFIER))
				var funcType:Type = parseType();
			// get function name
			tokenizer.match(TokenType.IDENTIFIER, true);
			var funcName:String = tokenizer.currentToken.value;
			
			// parse parameters
			tokenizer.match(TokenType.LEFT_PAREN, true);
			var params:Array = [];
			while (!tokenizer.peek().match(TokenType.RIGHT_PAREN))
			{
				// get type
				var type:Type = parseType();
				if (!type)
					throw new TokenizerSyntaxError('Invalid formal parameter type', tokenizer);
				// get identifier
				if (!tokenizer.match(TokenType.IDENTIFIER))
					throw new TokenizerSyntaxError('Invalid formal parameter', tokenizer);
				var name:String = tokenizer.currentToken.value;
				
				// add parameter
				params.push([name, type]);
				
				// check for comma
				if (!tokenizer.peek().match(TokenType.RIGHT_PAREN))
					tokenizer.match(TokenType.COMMA, true);
			}
			tokenizer.match(TokenType.RIGHT_PAREN, true);
			
			// parse body
			tokenizer.match(TokenType.LEFT_CURLY, true);
			var body:Block = parseBlock(TokenType.RIGHT_CURLY);
			tokenizer.match(TokenType.RIGHT_CURLY, true);
			
			// return function declaration statement
			return new FunctionDefinition(funcName, funcType, params, body);
		}
		
		private function parseClass():ClassDefinition
		{
			// get class name
			tokenizer.match(TokenType.CLASS, true);
			tokenizer.match(TokenType.IDENTIFIER, true);
			var className:String = tokenizer.currentToken.value;
			
			// parse body
			var constructor:Block = new Block();
			var publicBody:Block = new Block(), privateBody:Block = new Block();
			tokenizer.match(TokenType.LEFT_CURLY, true);
			while (!tokenizer.peek().match(TokenType.RIGHT_CURLY))
			{
				// get visibility (default public)
				var block:Block = publicBody;
				tokenizer.match(TokenType.PUBLIC);
				if (tokenizer.match(TokenType.PRIVATE))
				        block = privateBody;

				// get next token
				var token:Token = tokenizer.peek();
				switch (token.type)
				{
				    // variable or function
				    case TokenType.IDENTIFIER:
					// check for constructor
					if (token.value == className)
					{
						// get type-less constructors
						constructor.push(parseFunction());
						break;
					}
					// class type; fall-through
					
				    case TokenType.TYPE:
					if (tokenizer.peek(2).match(TokenType.IDENTIFIER))
					{
						// parse definition
						block.append(parseStatement());
						break;
					}
					// invalid definition; fall-through
				    
				    default:
					throw new TokenizerSyntaxError('Invalid initializer in class "' + className + '"', tokenizer);
				}
			}
			tokenizer.match(TokenType.RIGHT_CURLY, true);
			
			// return function declaration statement
			return new ClassDefinition(className, constructor, publicBody, privateBody);
		}
		
		private function parseVariables():Block
		{
			// get main variable type
			var varType = parseType();
			// get variable list
			var block:Block = new Block();
			do {
				// add definitions
				tokenizer.match(TokenType.IDENTIFIER, true);
				var varName:String = tokenizer.currentToken.value;
				// check for per-variable array brackets
				var dimensions = 
				    (tokenizer.match(TokenType.LEFT_BRACKET) && tokenizer.match(TokenType.RIGHT_BRACKET, true)) +
				    (tokenizer.match(TokenType.LEFT_BRACKET) && tokenizer.match(TokenType.RIGHT_BRACKET, true)) +
				    (tokenizer.match(TokenType.LEFT_BRACKET) && tokenizer.match(TokenType.RIGHT_BRACKET, true));
				// add definition
				block.push(new VariableDefinition(varName, new Type(varType.type, dimensions ? dimensions : varType.dimensions)));
				
				// check for assignment operation
				if (tokenizer.match(TokenType.ASSIGN))
				{
					// prevent assignment operators
					if (tokenizer.currentToken.assignOp)
						throw new TokenizerSyntaxError('Invalid variable initialization', tokenizer);

					// get initializer statement
					block.push(new Assignment(new Reference(new Literal(varName)),
					    parseExpression(TokenType.COMMA)));
				}
			} while (tokenizer.match(TokenType.COMMA));
			
			// return variable definition
			return block;
		}
		
//[TODO] remove stopAt token altogether
		private function parseList(stopAt:TokenType):Array
		{
			// parse a list (array initializer, function call, &c.)
			var list:Array = [];
			while (!tokenizer.peek().match(stopAt)) {
				// parse empty entries
				if (tokenizer.match(TokenType.COMMA)) {
					list.push(null);
					continue;
				}
				// parse arguments up to next comma
				list.push(parseExpression(TokenType.COMMA));
				if (!tokenizer.match(TokenType.COMMA))
					break;
			}
			return list;
		}
		
		private function parseExpression(stopAt:TokenType = undefined):IExecutable
		{
			// variable definitions
			var operators:Array = [], operands:Array = [];
		
			// main loop
			if (scanOperand(operators, operands, stopAt))
				while (scanOperator(operators, operands, stopAt))
					scanOperand(operators, operands, stopAt, true);
				
			// reduce to a single operand
			while (operators.length)
				reduceExpression(operators, operands);
			return operands.pop();
		}

		private function scanOperand(operators:Array, operands:Array, stopAt:TokenType = null, required:Boolean = false):Boolean
		{
			// get next token
			tokenizer.scanOperand = true;
			var token:Token = tokenizer.peek();
			// stop if token matches stop parameter
			if (stopAt && token.match(stopAt))
				return false;

			// switch based on type
			switch (token.type)
			{			
			    // unary operators
			    case TokenType.INCREMENT:
			    case TokenType.DECREMENT:
//[TODO] which of these are used in processing?
			    case TokenType.DELETE:
			    case TokenType.TYPEOF:
			    case TokenType.NOT:
			    case TokenType.BITWISE_NOT:
			    case TokenType.UNARY_PLUS:
			    case TokenType.UNARY_MINUS:
			    case TokenType.NEW:					
				// add operator
				tokenizer.get();
				operators.push(token.type);
				
				// match operand
				return scanOperand(operators, operands, stopAt, true);
				
			    // function casting
			    case TokenType.TYPE:
				if (tokenizer.peek(2).match(TokenType.LEFT_PAREN))
				{
					// push casting operator
					tokenizer.get();
					operators.push(TokenType.CAST);
					// push operands
					tokenizer.match(TokenType.LEFT_PAREN, true);
					operands.push(token.value);
					operands.push(parseExpression(TokenType.RIGHT_PAREN));
					tokenizer.match(TokenType.RIGHT_PAREN, true);
					break;
				}
				// fall-through
			    
			    // array initialization/references
			    case TokenType.IDENTIFIER:
				tokenizer.get();
//[TODO] move this into NEW operator?
				// check for new operator
				if (operators[operators.length - 1] == TokenType.NEW &&
				    tokenizer.peek().match(TokenType.LEFT_BRACKET)) {
					// get array initialization
					for (var sizes:Array = [], dimensions:int = 0; dimensions < 3; dimensions++) {
						// match an array dimension
						if (!tokenizer.match(TokenType.LEFT_BRACKET))
							break;

						sizes.push(parseExpression(TokenType.RIGHT_BRACKET))
						tokenizer.match(TokenType.RIGHT_BRACKET, true);
					}

					// create array initializer
					operators.pop();
					operands.push(new ArrayInstantiation(token.value, sizes[0], sizes[1], sizes[2]));
				} else if (token.match(TokenType.IDENTIFIER)) {
					// push reference
					operands.push(new Reference(new Literal(token.value)));
				} else {
					// invalid use of type keyword
					throw new TokenizerSyntaxError('Invalid type declaration', tokenizer);
				}
				break;
				
			    case TokenType.THIS:
				// push reference
				tokenizer.get();
				operands.push(new ThisReference());
				break;

			    // operands
			    case TokenType.NULL:
			    case TokenType.TRUE:
			    case TokenType.FALSE:
			    case TokenType.NUMBER:
			    case TokenType.STRING:
			    case TokenType.CHAR:
				// push literal
				tokenizer.get();
				operands.push(new Literal(token.value));
				break;
				
			    // array literal
			    case TokenType.LEFT_CURLY:
				// push array literal
				tokenizer.get();
				operands.push(new ArrayLiteral(parseList(TokenType.RIGHT_CURLY)));
				tokenizer.match(TokenType.RIGHT_CURLY, true);
				break;
			
			    // cast/group
			    case TokenType.LEFT_PAREN:
				tokenizer.get();

				// check if this be a cast or a group
				if (tokenizer.match(TokenType.TYPE))
				{
					// push casting operator
					operators.push(TokenType.CAST);
					// push operands
					operands.push(tokenizer.currentToken.value);
					tokenizer.match(TokenType.RIGHT_PAREN, true);
					return scanOperand(operators, operands, stopAt, true);
				}
				else if (tokenizer.peek(1).match(TokenType.RIGHT_PAREN) && tokenizer.match(TokenType.IDENTIFIER))
				{
					// match parenthetical
					var type:String = tokenizer.currentToken.value;
					tokenizer.match(TokenType.RIGHT_PAREN, true);
					
					// check if this be a cast
					var tmpOperators:Array = [], tmpOperands:Array = [];
					if (scanOperand(tmpOperators, tmpOperands))
					{
						// add operators
						operators.push(TokenType.CAST);
						operators = operators.concat(tmpOperators);
						// add operands
						operands.push(new Type(type));
						operands = operands.concat(tmpOperands);
						break;
					}

					// not a cast; add operand
					operands.push(new Reference(new Literal(type)));
					break;
				}
				
				// parse parenthetical
				operands.push(parseExpression(TokenType.RIGHT_PAREN));
				if (!tokenizer.match(TokenType.RIGHT_PAREN))
					throw new TokenizerSyntaxError('Missing ) in parenthetical', tokenizer);
				break;
				
			    default:
				// missing operand
				if (required)
					throw new TokenizerSyntaxError('Missing operand', tokenizer);
				else
					return false;
			}

			// matched operand
			return true;
		}

		private function scanOperator(operators:Array, operands:Array, stopAt:TokenType = null):Boolean {		
			// get next token
			tokenizer.scanOperand = false;
			var token:Token = tokenizer.peek();
			// stop if token matches stop parameter
			if (stopAt && token.match(stopAt))
				return false;

			// switch based on type
			switch (token.type) {				
			    // assignment
			    case TokenType.ASSIGN:
				// combine any higher-precedence expressions (using > and not >=, so postfix > prefix)
				while (operators.length &&
				    operators[operators.length - 1].precedence > token.type.precedence)
					reduceExpression(operators, operands);
					
				// push operator
				operators.push(tokenizer.get().type);
				// expand assignment operators
				if (token.assignOp) {
					operators.push(token.assignOp);
					operands.push(operands[operands.length-1]);
				}
				// push assignment value
				operands.push(parseExpression(stopAt));

				// reached end of expression
				return false;
				
			    // dot operator
			    case TokenType.DOT:			
				// combine any higher-precedence expressions
				while (operators.length &&
				    operators[operators.length - 1].precedence >= token.type.precedence)
					reduceExpression(operators, operands);
				
				// push operator
				operators.push(tokenizer.get().type);
				// match and push required identifier as string
				tokenizer.match(TokenType.IDENTIFIER, true);
				operands.push(new Literal(tokenizer.currentToken.value));

				// operand already found; find next operator
				return scanOperator(operators, operands, stopAt);

			    // brackets
			    case TokenType.LEFT_BRACKET:
				// combine any higher-precedence expressions
				while (operators.length &&
				    operators[operators.length - 1].precedence >= TokenType.INDEX.precedence)
					reduceExpression(operators, operands);

				// begin array index operator
				operators.push(TokenType.INDEX);
				tokenizer.match(TokenType.LEFT_BRACKET, true);
				operands.push(parseExpression(TokenType.RIGHT_BRACKET));
				if (!tokenizer.match(TokenType.RIGHT_BRACKET))
					throw new TokenizerSyntaxError('Missing ] in index expression', tokenizer);

				// operand already found; find next operator
				return scanOperator(operators, operands, stopAt);
			
			    // operators
			    case TokenType.OR:
			    case TokenType.AND:
			    case TokenType.BITWISE_OR:
			    case TokenType.BITWISE_XOR:
			    case TokenType.BITWISE_AND:
			    case TokenType.EQ:
			    case TokenType.NE:
			    case TokenType.STRICT_EQ:
			    case TokenType.STRICT_NE:
			    case TokenType.LT:
			    case TokenType.LE:
			    case TokenType.GE:
			    case TokenType.GT:
			    case TokenType.INSTANCEOF:
			    case TokenType.LSH:
			    case TokenType.RSH:
			    case TokenType.URSH:
			    case TokenType.PLUS:
			    case TokenType.MINUS:
			    case TokenType.MUL:
			    case TokenType.DIV:
			    case TokenType.MOD:				
				// combine any higher-precedence expressions
				while (operators.length &&
				    operators[operators.length - 1].precedence >= token.type.precedence)
					reduceExpression(operators, operands);

				// push operator and scan for operand
				operators.push(tokenizer.get().type);
				break;
			
			    // increment/decrement
			    case TokenType.INCREMENT:
			    case TokenType.DECREMENT:
				// postfix; reduce higher-precedence operators (using > and not >=, so postfix > prefix)
				while (operators.length &&
				    operators[operators.length - 1].precedence > token.type.precedence)
					reduceExpression(operators, operands);
					
				// add operator and reduce immediately
//[TODO] is reducing immediately necessary? a matter of precedence...
				operators.push(tokenizer.get().type);
				reduceExpression(operators, operands);
				break;
			
			    // call/instantiation
			    case TokenType.LEFT_PAREN:
				// reduce until we get the current function (or lower operator precedence than 'new')
				while (operators.length &&
				    operators[operators.length - 1].precedence > TokenType.NEW.precedence)
					reduceExpression(operators, operands);

				// parse arguments
				tokenizer.match(TokenType.LEFT_PAREN, true);
				operands.push(parseList(TokenType.RIGHT_PAREN));
				tokenizer.match(TokenType.RIGHT_PAREN, true);
				
				// designate call operator, or that 'new' has args
				if (!operators.length || operators[operators.length - 1] != TokenType.NEW)
					operators.push(TokenType.CALL);
				else if (operators[operators.length - 1] == TokenType.NEW)
					operators.splice(-1, 1, TokenType.NEW_WITH_ARGS);
//[TODO] completely reduce here?
				// reduce now because CALL/NEW has no precedence
				reduceExpression(operators, operands);

				// operand already found; find next operator
				return scanOperator(operators, operands, stopAt);

			    // no operator found
			    default:
				return false;
			}

			// operator matched
			return true;
		}

//[TODO] integrate some of this into other functions?
		private function reduceExpression(operatorList:Array, operandList:Array):void {
			// extract operator and operands
			var operator:TokenType = operatorList.pop();
			var operands:Array = operandList.splice(operandList.length - operator.arity);
			// convert expression to statements
			switch (operator) {
			    // object instantiation
			    case TokenType.NEW:
			    case TokenType.NEW_WITH_ARGS:
				operandList.push(new ObjectInstantiation(operands[0], operands[1]));
				break;
			    
			    // function call
			    case TokenType.CALL:
				operandList.push(new Call(operands[0], operands[1]));
				break;
			
			    // casting
			    case TokenType.CAST:
			        operandList.push(new Cast(operands[0], operands[1]));
			        break;
				
			    // increment/decrement
			    case TokenType.INCREMENT:
				operandList.push(new Increment(operands[0]));
				break;
			    case TokenType.DECREMENT:
			        operandList.push(new Decrement(operands[0]));
				break;
				
			    // assignment
			    case TokenType.ASSIGN:
				operandList.push(new Assignment(operands[0], operands[1]));
				break;
				
			    // property operator
			    case TokenType.INDEX:
			    case TokenType.DOT:
				operandList.push(new Reference(operands[1], operands[0]));
			        break;

			    // unary operators
			    case TokenType.NOT:
			    case TokenType.BITWISE_NOT:
			    case TokenType.UNARY_PLUS:
			    case TokenType.UNARY_MINUS:
				operandList.push(new Operation(operator, operands[0]));
				break;
		
			    // operators
			    case TokenType.OR:
			    case TokenType.AND:
			    case TokenType.BITWISE_OR:
			    case TokenType.BITWISE_XOR:
			    case TokenType.BITWISE_AND:
			    case TokenType.EQ:
			    case TokenType.NE:
			    case TokenType.STRICT_EQ:
			    case TokenType.STRICT_NE:
			    case TokenType.LT:
			    case TokenType.LE:
			    case TokenType.GE:
			    case TokenType.GT:
			    case TokenType.INSTANCEOF:
			    case TokenType.LSH:
			    case TokenType.RSH:
			    case TokenType.URSH:
			    case TokenType.PLUS:
			    case TokenType.MINUS:
			    case TokenType.MUL:
			    case TokenType.DIV:
			    case TokenType.MOD:
				operandList.push(new Operation(operator, operands[0], operands[1]));
				break;
			
			    default:
				throw new Error('Unknown operator "' + operator + '"');
			}
		}
	}
}
