package processing.parser {
	import flash.utils.*;

	public class Parser {
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

		public static function Statement(t, x) {
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

		public static function Variables(t, x) {
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
		}

		public static function ParenExpression(t, x) {
			t.mustMatch(Token.LEFT_PAREN);
			var n = Expression(t, x);
			t.mustMatch(Token.RIGHT_PAREN);
			return n;
		}
			
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

		public static function parse(s, f = '', l = 0) {
			var t = new Tokenizer(s, f, l);
			var x = new CompilerContext(false);
			var n = Script(t, x);
			if (!t.done)
				throw t.newSyntaxError("Syntax error");
			return n;
		}
	}
}
