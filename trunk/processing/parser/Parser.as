package processing.parser {
	import processing.parser.*;
	
	public class Parser {
		public var tokenizer:Tokenizer;
		public var evaluator:Evaluator;
		public var context:ParserContext;
	
		public function Parser(e:Evaluator) {
			// save evaluator
			evaluator = e;
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
		
		private function parseBlock():Block {
			// create new parser context
			context = new ParserContext;
		
			// parse code block
			var block:Block = new Block();
			while (!tokenizer.done && !tokenizer.peek().match(TokenType.RIGHT_CURLY))
				block.append(parseStatement());
			return block;			
		}

//[TODOSOON] make statements out of literals?

		private function parseStatement():Block {
			// parse current statement line
			var block:Block = new Block();
			var token:Token = tokenizer.peek();
			switch (token.type)
			{
			    // parse block
			    case TokenType.LEFT_CURLY:
				// get parsed block
				tokenizer.get();
				block = parseBlock();
				tokenizer.match(TokenType.RIGHT_CURLY, true);
				return block;

			    // for statement
			    case TokenType.FOR:
				// match opening 'for' and '('
				tokenizer.get();
				tokenizer.match(TokenType.LEFT_PAREN, true);
				
				// match initializer
				if (!tokenizer.match(TokenType.SEMICOLON)) {
					// match variable definitions or expression
					token = tokenizer.peek();
//[TODO] handle other declaration types...
					if (token.match(TokenType.INT) || token.match(TokenType.FLOAT))
						block.append(parseVariables());
					else
						block.push(parseExpression());
						
					// next semicolon
					tokenizer.match(TokenType.SEMICOLON, true);
				}
				
				// match condition
				var condition:Statement = (tokenizer.peek().match(TokenType.SEMICOLON)) ?
				    undefined : parseExpression();
				tokenizer.match(TokenType.SEMICOLON, true);
				// match update
				var update:Statement = (tokenizer.peek().match(TokenType.RIGHT_PAREN)) ?
				    undefined : parseExpression();
				tokenizer.match(TokenType.RIGHT_PAREN, true);
				// parse body
				var body:Block = parseStatement();
				
				// append loop body
				if (update)
					body.push(update);
				block.push(new Statement(evaluator.loop, [condition || true, body]));
				return block;
			
			    // empty expressions
			    case TokenType.NEWLINE:
			    case TokenType.SEMICOLON:
				return undefined;
			
			    // variables
//[TODO] handle classes with this
			    case TokenType.FLOAT:
			    case TokenType.INT:
				block = parseVariables();
				break;
			
			    // identifier
			    case TokenType.IDENTIFIER:
			    default:
				block.push(parseExpression());
				break;
			}
			
			// check for proper termination
			if (token.line == tokenizer.currentToken.line) {
				var nextToken:Token = tokenizer.peek(true);
				if (!nextToken.match(TokenType.END) &&
				    !nextToken.match(TokenType.NEWLINE) &&
				    !nextToken.match(TokenType.SEMICOLON) &&
				    !nextToken.match(TokenType.RIGHT_CURLY))
					throw new TokenizerSyntaxError('Missing ; before statement', tokenizer);
			}
			// eliminate tailing semicolon
			tokenizer.match(TokenType.SEMICOLON);
			
			// return parsed statement
			return block;
		}
		
/*		public static function Statement(t, x) {
			var i, label, n, n2, ss, tt = t.get();

			// Cases for statements ending in a right curly return early, avoiding the
			// common semicolon insertion magic after this switch.
			switch (tt) {
			  case Token.FUNCTION:
				return FunctionDefinition(t, x, true,
										  (x.stmtStack.length > 1)
										  ? Token.FUNCTION_STATEMENT_FORM
										  : Token.FUNCTION_DECLARED_FORM);

			  case Token.LEFT_CURLY:
				n = Statements(t, x);
				t.mustMatch(Token.RIGHT_CURLY);
				return n;

			  case Token.IF:
				n = new Node(t);
				n.condition = ParenExpression(t, x);
				x.stmtStack.push(n);
				n.thenPart = Statement(t, x);
				n.elsePart = t.match(Token.ELSE) ? Statement(t, x) : null;
				x.stmtStack.pop();
				return n;

			  case Token.SWITCH:
				n = new Node(t);
				t.mustMatch(Token.LEFT_PAREN);
				n.discriminant = Expression(t, x);
				t.mustMatch(Token.RIGHT_PAREN);
				n.cases = [];
				n.defaultIndex = -1;
				x.stmtStack.push(n);
				t.mustMatch(Token.LEFT_CURLY);
				while ((tt = t.get()) != Token.RIGHT_CURLY) {
					switch (tt) {
					  case Token.DEFAULT:
						if (n.defaultIndex >= 0)
							throw t.newSyntaxError("More than one switch default");
						// FALL THROUGH
					  case Token.CASE:
						n2 = new Node(t);
						if (tt == Token.DEFAULT)
							n.defaultIndex = n.cases.length;
						else
							n2.caseLabel = Expression(t, x, Token.COLON);
						break;
					  default:
						throw t.newSyntaxError("Invalid switch case");
					}
					t.mustMatch(Token.COLON);
					n2.statements = new Node(t, Token.BLOCK);
					while ((tt=t.peek()) != Token.CASE && tt != Token.DEFAULT && tt != Token.RIGHT_CURLY)
						n2.statements.push(Statement(t, x));
					n.cases.push(n2);
				}
				x.stmtStack.pop();
				return n;

			  case Token.FOR:
				n = new Node(t);
				n.isLoop = true;
				t.mustMatch(Token.LEFT_PAREN);
				if ((tt = t.peek()) != Token.SEMICOLON) {
					x.inForLoopInit = true;
					if (tt == Token.VAR || tt == Token.CONST) {
						t.get();
						n2 = Variables(t, x);
					} else {
						n2 = Expression(t, x);
					}
					x.inForLoopInit = false;
				}
				if (n2 && t.match(Token.IN)) {
					n.type = Token.FOR_IN;
					if (n2.type == Token.VAR) {
						if (n2.length != 1) {
							throw new SyntaxError("Invalid for..in left-hand side");
						}

						// NB: n2[0].type == IDENTIFIER and n2[0].value == n2[0].name.
						n.iterator = n2[0];
						n.varDecl = n2;
					} else {
						n.iterator = n2;
						n.varDecl = null;
					}
					n.object = Expression(t, x);
				} else {
					n.setup = n2 || null;
					t.mustMatch(Token.SEMICOLON);
					n.condition = (t.peek() == Token.SEMICOLON) ? null : Expression(t, x);
					t.mustMatch(Token.SEMICOLON);
					n.update = (t.peek() == Token.RIGHT_PAREN) ? null : Expression(t, x);
				}
				t.mustMatch(Token.RIGHT_PAREN);
				n.body = nest(t, x, n, Statement);
				return n;

			  case Token.WHILE:
				n = new Node(t);
				n.isLoop = true;
				n.condition = ParenExpression(t, x);
				n.body = nest(t, x, n, Statement);
				return n;

			  case Token.DO:
				n = new Node(t);
				n.isLoop = true;
				n.body = nest(t, x, n, Statement, Token.WHILE);
				n.condition = ParenExpression(t, x);
				break;

			  case Token.BREAK:
			  case Token.CONTINUE:
				n = new Node(t);
				if (t.peekOnSameLine() == Token.IDENTIFIER) {
					t.get();
					n.label = t.token.value;
				}
				ss = x.stmtStack;
				i = ss.length;
				label = n.label;
				if (label) {
					do {
						if (--i < 0)
							throw t.newSyntaxError("Label not found");
					} while (ss[i].label != label);
				} else {
					do {
						if (--i < 0) {
							throw t.newSyntaxError("Invalid " + ((tt == Token.BREAK)
																 ? "break"
																 : "continue"));
						}
					} while (!ss[i].isLoop && (tt != Token.BREAK || ss[i].type != Token.SWITCH));
				}
				n.target = ss[i];
				break;

			  case Token.TRY:
				n = new Node(t);
				n.tryBlock = Block(t, x);
				n.catchClauses = [];
				while (t.match(Token.CATCH)) {
					n2 = new Node(t);
					t.mustMatch(Token.LEFT_PAREN);
					n2.varName = t.mustMatch(Token.IDENTIFIER).value;
					t.mustMatch(Token.RIGHT_PAREN);
					n2.block = Block(t, x);
					n.catchClauses.push(n2);
				}
				if (t.match(Token.FINALLY))
					n.finallyBlock = Block(t, x);
				if (!n.catchClauses.length && !n.finallyBlock)
					throw t.newSyntaxError("Invalid try statement");
				return n;

			  case Token.CATCH:
			  case Token.FINALLY:
				throw t.newSyntaxError(Token.getConstant(tt) + " without preceding try");

			  case Token.THROW:
				n = new Node(t);
				n.exception = Expression(t, x);
				break;

			  case Token.RETURN:
				if (!x.inFunction)
					throw t.newSyntaxError("Invalid return");
				n = new Node(t);
				tt = t.peekOnSameLine();
				if (tt != Token.END && tt != Token.NEWLINE && tt != Token.SEMICOLON && tt != Token.RIGHT_CURLY)
					n.value = Expression(t, x);
//[TODO] hack; what's narcissus default behavor for n.value with no return statement?
				else
					n.value = undefined;
				break;

			  case Token.WITH:
				n = new Node(t);
				n.object = ParenExpression(t, x);
				n.body = nest(t, x, n, Statement);
				return n;

			  case Token.VAR:
			  case Token.CONST:
				n = Variables(t, x);
				break;

			  case Token.DEBUGGER:
				n = new Node(t);
				break;

			  case Token.NEWLINE:
			  case Token.SEMICOLON:
				n = new Node(t, Token.SEMICOLON);
				n.expression = null;
				return n;

			  default:
				if (tt == Token.IDENTIFIER) {
					t.scanOperand = false;
					tt = t.peek();
					t.scanOperand = true;
					if (tt == Token.COLON) {
						label = t.token.value;
						ss = x.stmtStack;
						for (i = ss.length-1; i >= 0; --i) {
							if (ss[i].label == label)
								throw t.newSyntaxError("Duplicate label");
						}
						t.get();
						n = new Node(t, Token.LABEL);
						n.label = label;
						n.statement = nest(t, x, n, Statement);
						return n;
					}
				}

				n = new Node(t, Token.SEMICOLON);
				t.unget();
				n.expression = Expression(t, x);
				n.end = n.expression.end;
				break;
			}

			if (t.lineno == t.token.lineno) {
				tt = t.peekOnSameLine();
				if (tt != Token.END && tt != Token.NEWLINE && tt != Token.SEMICOLON && tt != Token.RIGHT_CURLY)
					throw new SyntaxError("Missing ; before statement");
			}
			t.match(Token.SEMICOLON);
			return n;
		}*/
		
		private function parseVariables():Block {
			// get variable type
			var block:Block = new Block();
			var varType:TokenType = tokenizer.get().type;
			do {
				// add definitions
				tokenizer.match(TokenType.IDENTIFIER, true);
				var varName:String = tokenizer.currentToken.value;
				block.push(new Statement(evaluator.defineVar, [varName, varType]));
				
				// check for assignment operation
				if (tokenizer.match(TokenType.ASSIGN))
				{
					// prevent assignment operators
					if (tokenizer.currentToken.assignOp)
						throw new TokenizerSyntaxError('Invalid variable initialization', tokenizer);

					// get initializer statement
					block.push(new Statement(evaluator.setVar, [varName, parseExpression(TokenType.COMMA)]));
				}
			} while (tokenizer.match(TokenType.COMMA));
			
			// return variable definition
			return block;
		}
		
/*		public static function Variables(t, x) {
			var n = new Node(t);
			do {
				t.mustMatch(Token.IDENTIFIER);
				var n2 = new Node(t);
				n2.name = n2.value;
				if (t.match(Token.ASSIGN)) {
					if (t.token.assignOp)
						throw t.newSyntaxError("Invalid variable initialization");
					n2.initializer = Expression(t, x, Token.COMMA);
				}
				n2.readOnly = (n.type == Token.CONST);
				n.push(n2);
				x.varDecls.push(n2);
			} while (t.match(Token.COMMA));
			return n;
		}*/
		
		private function parseList(start:TokenType, stop:TokenType):Array {
			// match opening
			tokenizer.match(start, true);
			// parse a list (array initializer, function call, &c.)
			var list:Array = [];
			while (!tokenizer.peek().match(stop)) {
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
			// match closing
			tokenizer.match(stop, true);
			return list;
		}
		
		private function parseExpression(stopAt:TokenType = undefined):* {
			// variable definitions
			var operators:Array = [], operands:Array = [], token:Token;
//[TODO] should this use a parser context?
			var bracketLevel:int = 0, curlyLevel:int = 0, parenLevel:int = 0, hookLevel:int = 0;
		
			// main loop
			parseLoop: for (; !tokenizer.done || tokenizer.peek().type != TokenType.SEMICOLON; tokenizer.get()) {
				// get next token
				token = tokenizer.peek();
//trace('Currently parsing in Expression: ' + TokenType.getConstant(token.type));

				// stop if token matches stop parameter (on original bracket level)
				if (stopAt && token.match(stopAt) && !bracketLevel && !curlyLevel && !parenLevel && !hookLevel)
					break parseLoop;
				
				switch (token.type) {
				    // semicolon
				    case TokenType.SEMICOLON:
					// this shouldn't happen; Statement handles this
					break parseLoop;
				
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
				    case TokenType.DOT:
					// ensure that we be looking for an operator
					if (tokenizer.scanOperand)
						break parseLoop;
				
					// combine any higher-precedence expressions
					while (operators.length &&
					    operators[operators.length - 1].type.precedence >= token.type.precedence)
						reduceExpression(operators, operands);

//					if (tt == Token.DOT) {
//						t.mustMatch(Token.IDENTIFIER);
//						operands.push(new Node(t, Token.DOT, operands.pop(), new Node(t)));
//					} else {
						// push operator and scan for operands
						operators.push(token.type);
						tokenizer.scanOperand = true;
//					}
					break;
					
				    case TokenType.INCREMENT:
				    case TokenType.DECREMENT:
					// check placement
					if (tokenizer.scanOperand)
					{
						// prefix; add operator
						operators.push(token.type);
					}
					else
					{
						// postfix; reduce higher-precedence operators (using > and not >=, so postfix > prefix)
						while (operators.length &&
						    operators[operators.length - 1].type.precedence > token.type.precedence)
							reduceExpression(operators, operands);
							
						// add operator and reduce immediately
//[TODO] is reducing immediately necessary? a matter of precedence...
						operators.push(token.type);
						reduceExpression(operators, operands);
					}
					break;

				    // operands
				    case TokenType.IDENTIFIER:
				    case TokenType.NULL:
				    case TokenType.THIS:
				    case TokenType.TRUE:
				    case TokenType.FALSE:
				    case TokenType.NUMBER:
				    case TokenType.STRING:
				    case TokenType.REGEXP:
					// only add if scanning operands
					if (!tokenizer.scanOperand)
						break parseLoop;
					operands.push(token);
//[TODO] convertToken here? (no; variable assignment prohibits this, unless identifiers become Reference objects?)
					tokenizer.scanOperand = false;
					break;
					
				    case TokenType.LEFT_PAREN:
//[TODO] correct this
//					if (t.scanOperand) {
//						operators.push(TokenType.GROUP);
//						parenLevel++;
//					} else {
						// reduce until we get the current function (or lower operator precedence than 'new')
//						while (operators.length &&
//						    operators[operators.length - 1].type.precedence > TokenType.NEW.precedence)
//							reduce();
//[TODO] uncomment for 'new' operator
//						n = operators[operators.length-1];
						// parse arguments (scanning operands to match regexp and unary +/-)
						tokenizer.scanOperand = true;
						operands.push(parseList(TokenType.LEFT_PAREN, TokenType.RIGHT_PAREN));
						tokenizer.scanOperand = false;
//						if (tokenizer.match(TokenType.RIGHT_PAREN)) {
//							if (n && n.type == TokenType.NEW) {
//								--operators.length;
//								n.push(operands.pop());
//								operands.push(n);
//							} else {
//								operands.push(TokenType.LIST);
//							}
//							tokenizer.scanOperand = false;
//							break;
//						}
//						if (n && n.type == TokenType.NEW)
//							n.type = TokenType.NEW_WITH_ARGS;
//						else
							operators.push(TokenType.CALL);
//					}
					break;

				    case TokenType.RIGHT_PAREN:
//[TODO] correct this
					// check if we're closing a parenthetical
					if (tokenizer.scanOperand || !parenLevel)
						break parseLoop;

//[TODO] uncomment for groups		// reduce until the current operator is found
//					var op:TokenType = operators[operators.length - 1];
//					while (op != TokenType.GROUP) {
//						reduceExpression(operators, operands);
//						op = operators[operators.length - 1];
//					}
//					parenLevel--;
					break;
					
				    // Automatic semicolon insertion means we may scan across a newline
				    // and into the beginning of another statement.  If so, break out of
				    // the while loop and let tokenizer.scanOperand logic handle errors.
//[TODO] no automatic semicolon insertion!
				    default:
					break parseLoop;
				}			
			}
			
			// check that we are on the correct level...
			if (bracketLevel)
				throw new TokenizerSyntaxError('Missing ] in index expression', tokenizer);
			if (hookLevel)
				throw new TokenizerSyntaxError('Missing : after ?', tokenizer);
			if (parenLevel)
				throw new TokenizerSyntaxError('Missing ) in parenthetical', tokenizer);
//[TODO] curlyLevel!?
			// ...and are not missing an operand
			if (tokenizer.scanOperand)
				throw new TokenizerSyntaxError('Missing operand', tokenizer);
				
			// Resume default mode, scanning for operands, not operators.
			tokenizer.scanOperand = true;
			while (operators.length)
				reduceExpression(operators, operands);
			return convertOperand(operands.pop());
		}

//[TODO] move this inside former function?
		private function reduceExpression(operatorList:Array, operandList:Array):void {
			// extract operator and operands
			var operator:TokenType = operatorList.pop();
			var operands:Array = operandList.splice(operandList.length - operator.arity);
			
			// convert expression to Statements
			switch (operator) {
			    // function call
			    case TokenType.CALL:
				// convert operands to Statements
				operandList.push(new Statement(evaluator.callMethod,
				    [convertOperand(operands[0]), operands[1]]));
				break;
				
			    // increment/decrement
			    case TokenType.INCREMENT:
			    case TokenType.DECREMENT:
				// create expressions
				var getExpression:Statement = new Statement(evaluator.getVar, [operands[0].value]);
				var changeExpression:Statement = new Statement(evaluator.expression, [getExpression, 1,
				    operator == TokenType.INCREMENT ? TokenType.PLUS : TokenType.MINUS]);
			        operandList.push(new Statement(evaluator.setVar, [operands[0].value, changeExpression]));
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
			    case TokenType.DOT:
				operandList.push(new Statement(evaluator.expression,
				    [convertOperand(operands[0]), convertOperand(operands[1]), operator]));
				break;
			
			    default:
				throw new Error('Unknown operator "' + operator.type + '"');
			}
		}
		
		private function convertOperand(operand:*):* {
			// convert tokens to statement
			if (operand is Token) {
				switch (operand.type) {
				    case TokenType.NULL:
				    case TokenType.TRUE:
				    case TokenType.FALSE:
				    case TokenType.NUMBER:
				    case TokenType.STRING:
				    case TokenType.REGEXP:
					return operand.value;
				    
				    case TokenType.IDENTIFIER:
				    case TokenType.THIS:
					return new Statement(evaluator.getVar, [operand.value]);
				
				    default:
					throw new Error('Could not convert operand of type "' + operand.type + '"');
				}
			}
			
			// otherwise, return operand
			return operand;
		}
			
/*
		public static function Expression(t, x, stop = null) {
			var n, id, tt, operators = [], operands = [];
			var bl = x.bracketLevel, cl = x.curlyLevel, pl = x.parenLevel,
				hl = x.hookLevel;

			function reduce() {
				var n = operators.pop();
				var op = n.type;
				var arity = op.arity;

				if (arity == -2) {
					// Flatten left-associative trees.
				if (operands.length >= 2) {
						var left = operands[operands.length-2];
						if (left.type == op) {
							var right = operands.pop();
							left.push(right);
							return left;
						}
					}
					arity = 2;
				}

				// Always use push to add operands to n, to update start and end.
				var a = operands.splice(operands.length - arity);
				for (var i = 0; i < arity; i++)
					n.push(a[i]);

				// Include closing bracket or postfix operator in [start,end).
				if (n.end < t.token.end)
					n.end = t.token.end;

				operands.push(n);
				return n;
			}
			
			loop: while ((tt = t.get()) != Token.END) {
//[DEBUG]			trace('+' + Token.getConstant(tt));
				if (tt == stop &&
					x.bracketLevel == bl && x.curlyLevel == cl && x.parenLevel == pl &&
					x.hookLevel == hl) {
					// Stop only if tt matches the optional stop parameter, and that
					// token is not quoted by some kind of bracket.
					break;
				}

				switch (tt) {
				  case Token.SEMICOLON:
					// NB: cannot be empty, Statement handled that.
					break loop;

				  case Token.ASSIGN:
				  case Token.HOOK:
				  case Token.COLON:
					if (t.scanOperand)
						break loop;
					// Use >, not >=, for right-associative ASSIGN and HOOK/COLON.
					while (operators.length && (operators[operators.length-1].type.precedence > tt.precedence ||
						   (tt == Token.COLON && operators[operators.length-1].type == Token.ASSIGN))) {
						reduce();
					}
					if (tt == Token.COLON) {
						n = operators[operators.length-1];
						if (n.type != Token.HOOK)
							throw t.newSyntaxError("Invalid label");
						n.type = Token.CONDITIONAL;
						--x.hookLevel;
					} else {
						operators.push(new Node(t));
						if (tt == Token.ASSIGN)
							operands[operators.length-1].assignOp = t.token.assignOp;
						else
							++x.hookLevel;	  // tt == HOOK
					}
					t.scanOperand = true;
					break;

				  case Token.IN:
					// An in operator should not be parsed if we're parsing the head of
					// a for (...) loop, unless it is in the then part of a conditional
					// expression, or parenthesized somehow.
					if (x.inForLoopInit && !x.hookLevel &&
						!x.bracketLevel && !x.curlyLevel && !x.parenLevel) {
						break loop;
					}
					// FALL THROUGH
				  case Token.COMMA:
					// Treat comma as left-associative so reduce can fold left-heavy
					// COMMA trees into a single array.
					// FALL THROUGH
				  case Token.OR:
				  case Token.AND:
				  case Token.BITWISE_OR:
				  case Token.BITWISE_XOR:
				  case Token.BITWISE_AND:
				  case Token.EQ: case Token.NE: case Token.STRICT_EQ: case Token.STRICT_NE:
				  case Token.LT: case Token.LE: case Token.GE: case Token.GT:
				  case Token.INSTANCEOF:
				  case Token.LSH: case Token.RSH: case Token.URSH:
				  case Token.PLUS: case Token.MINUS:
				  case Token.MUL: case Token.DIV: case Token.MOD:
				  case Token.DOT:
					if (t.scanOperand)
						break loop;
					while (operators.length && operators[operators.length-1].type.precedence >= tt.precedence)
						reduce();
					if (tt == Token.DOT) {
						t.mustMatch(Token.IDENTIFIER);
						operands.push(new Node(t, Token.DOT, operands.pop(), new Node(t)));
					} else {
						operators.push(new Node(t));
						t.scanOperand = true;
					}
					break;

				  case Token.DELETE: case Token.VOID: case Token.TYPEOF:
				  case Token.NOT: case Token.BITWISE_NOT: case Token.UNARY_PLUS: case Token.UNARY_MINUS:
				  case Token.NEW:
					if (!t.scanOperand)
						break loop;
					operators.push(new Node(t));
					break;

				  case Token.INCREMENT: case Token.DECREMENT:
					if (t.scanOperand) {
						operators.push(new Node(t));  // prefix increment or decrement
					} else {
						// Use >, not >=, so postfix has higher precedence than prefix.
						while (operators.length && operators[operators.length-1].type.precedence > tt.precedence)
							reduce();
						n = new Node(t, tt, operands.pop());
						n.postfix = true;
						operands.push(n);
					}
					break;

				  case Token.FUNCTION:
					if (!t.scanOperand)
						break loop;
					operands.push(FunctionDefinition(t, x, false, Token.FUNCTION_EXPRESSED_FORM));
					t.scanOperand = false;
					break;

				  case Token.NULL: case Token.THIS: case Token.TRUE: case Token.FALSE:
				  case Token.IDENTIFIER: case Token.NUMBER: case Token.STRING: case Token.REGEXP:
					if (!t.scanOperand)
						break loop;
					operands.push(new Node(t));
					t.scanOperand = false;
					break;

				  case Token.LEFT_BRACKET:
					if (t.scanOperand) {
						// Array initialiser.  Parse using recursive descent, as the
						// sub-grammar here is not an operator grammar.
						n = new Node(t, Token.ARRAY_INIT);
						while ((tt = t.peek()) != Token.RIGHT_BRACKET) {
							if (tt == Token.COMMA) {
								t.get();
								n.push(null);
								continue;
							}
							n.push(Expression(t, x, Token.COMMA));
							if (!t.match(Token.COMMA))
								break;
						}
						t.mustMatch(Token.RIGHT_BRACKET);
						operands.push(n);
						t.scanOperand = false;
					} else {
						// Property indexing operator.
						operators.push(new Node(t, Token.INDEX));
						t.scanOperand = true;
						++x.bracketLevel;
					}
					break;

				  case Token.RIGHT_BRACKET:
					if (t.scanOperand || x.bracketLevel == bl)
						break loop;
					while (reduce().type != Token.INDEX)
						continue;
					--x.bracketLevel;
					break;

				  case Token.LEFT_CURLY:
					if (!t.scanOperand)
						break loop;
					// Object initialiser.  As for array initialisers (see above),
					// parse using recursive descent.
					++x.curlyLevel;
					n = new Node(t, Token.OBJECT_INIT);
					object_init:
					if (!t.match(Token.RIGHT_CURLY)) {
						do {
							tt = t.get();
							switch (tt) {
							  case Token.IDENTIFIER:
							  case Token.NUMBER:
							  case Token.STRING:
								id = new Node(t);
								break;
							  case Token.RIGHT_CURLY:
								throw t.newSyntaxError("Illegal trailing ,");
							  default:
								throw t.newSyntaxError("Invalid property name");
							}
							t.mustMatch(Token.COLON);
							n.push(new Node(t, Token.PROPERTY_INIT, id,
											Expression(t, x, Token.COMMA)));
						} while (t.match(Token.COMMA));
						t.mustMatch(Token.RIGHT_CURLY);
					}
					operands.push(n);
					t.scanOperand = false;
					--x.curlyLevel;
					break;

				  case Token.RIGHT_CURLY:
					if (!t.scanOperand && x.curlyLevel != cl)
						throw "PANIC: right curly botch";
					break loop;

				  case Token.LEFT_PAREN:
					if (t.scanOperand) {
						operators.push(new Node(t, Token.GROUP));
					} else {
						while (operators.length && operators[operators.length-1].type.precedence > Token.NEW.precedence)
							reduce();
						// Handle () now, to regularize the n-ary case for n > 0.
						// We must set scanOperand in case there are arguments and
						// the first one is a regexp or unary+/-.
						n = operators[operators.length-1];
						t.scanOperand = true;
						if (t.match(Token.RIGHT_PAREN)) {
							if (n && n.type == Token.NEW) {
								--operators.length;
								n.push(operands.pop());
							} else {
								n = new Node(t, Token.CALL, operands.pop(),
											 new Node(t, Token.LIST));
							}
							operands.push(n);
							t.scanOperand = false;
							break;
						}
						if (n && n.type == Token.NEW)
							n.type = Token.NEW_WITH_ARGS;
						else
							operators.push(new Node(t, Token.CALL));
					}
					++x.parenLevel;
					break;

				  case Token.RIGHT_PAREN:
					if (t.scanOperand || x.parenLevel == pl)
						break loop;
					while ((tt = reduce().type) &&
					    tt != Token.GROUP && tt != Token.CALL && tt != Token.NEW_WITH_ARGS);
					if (tt != Token.GROUP) {
						n = operands[operands.length-1];
						if (n[1].type != Token.COMMA)
							n[1] = new Node(t, Token.LIST, n[1]);
						else
							n[1].type = Token.LIST;
					}
					--x.parenLevel;
					break;

				  // Automatic semicolon insertion means we may scan across a newline
				  // and into the beginning of another statement.  If so, break out of
				  // the while loop and let the t.scanOperand logic handle errors.
				  default:
					break loop;
				}
//[DEBUG]			trace('-' + Token.getConstant(tt));
			}

			if (x.hookLevel != hl)
				throw t.newSyntaxError("Missing : after ?");
			if (x.parenLevel != pl)
				throw t.newSyntaxError("Missing ) in parenthetical");
			if (x.bracketLevel != bl)
				throw t.newSyntaxError("Missing ] in index expression");
			if (t.scanOperand)
				throw t.newSyntaxError("Missing operand");
				
			// Resume default mode, scanning for operands, not operators.
			t.scanOperand = true;
			t.unget();
			while (operators.length)
				reduce();
			return operands.pop();
		}

		public static function Script(t, x) {
			var n:Node = Statements(t, x);
			n.type = Token.SCRIPT;
			n.funDecls = x.funDecls;
			n.varDecls = x.varDecls;
			return n;
		}

		public static function tokenstr(tt) {
			return Token.getConstant(tt);
		}

		// Statement stack and nested statement handler.
		public static function nest(t, x, node, func, end = null) {
			x.stmtStack.push(node);
			var n = func(t, x);
			x.stmtStack.pop();
			end && t.mustMatch(end);
			return n;
		}

		public static function Statements(t, x) {
			var n = new Node(t, Token.BLOCK);
			x.stmtStack.push(n);
			while (!t.done && t.peek() != Token.RIGHT_CURLY)
				n.push(Statement(t, x));
			x.stmtStack.pop();
			return n;
		}

		public static function Block(t, x) {
			t.mustMatch(Token.LEFT_CURLY);
			var n = Statements(t, x);
			t.mustMatch(Token.RIGHT_CURLY);
			return n;
		}

		public static function FunctionDefinition(t, x, requireName, functionForm) {
			var f:Node = new Node(t);
			if (t.match(Token.IDENTIFIER))
				f.name = t.token.value;
			else if (requireName)
				throw t.newSyntaxError("Missing function identifier");

			t.mustMatch(Token.LEFT_PAREN);
			f.params = [];
			var tt;
			while ((tt = t.get()) != Token.RIGHT_PAREN) {
				if (tt != Token.IDENTIFIER)
					throw t.newSyntaxError("Missing formal parameter");
				f.params.push(t.token.value);
				if (t.peek() != Token.RIGHT_PAREN)
					t.mustMatch(Token.COMMA);
			}

			t.mustMatch(Token.LEFT_CURLY);
			var x2 = new CompilerContext(true);
			f.body = Script(t, x2);
			t.mustMatch(Token.RIGHT_CURLY);
			f.end = t.token.end;

			f.functionForm = functionForm;
			if (functionForm == Token.FUNCTION_DECLARED_FORM)
				x.funDecls.push(f);
			return f;
		}

		public static function ParenExpression(t, x) {
			t.mustMatch(Token.LEFT_PAREN);
			var n = Expression(t, x);
			t.mustMatch(Token.RIGHT_PAREN);
			return n;
		}
			


		public static function parse(s, f = '', l = 0) {
			var t = new Tokenizer(s, f, l);
			var x = new CompilerContext(false);
			var n = Script(t, x);
			if (!t.done)
				throw t.newSyntaxError("Syntax error");
			return n;
		}*/
	}
}