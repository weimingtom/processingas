package asas {
	public class Evaluator {
		// Helper to avoid Object.prototype.hasOwnProperty polluting scope objects.
//[TODO] eliminate it anyway!
		public static function hasDirectProperty(o, p) {
			return o.hasOwnProperty(p);
		}

		public static function getValue(v) {
//[TODO] Reference.getValue() ?
			if (v instanceof Reference) {
				if (!v.base)
					throw new ReferenceError(v.propertyName + ' is not defined');
//[TODO] throw error when property doesn't exist?
				// return the property
				return v.base.getProperty(v.propertyName);
			}
			return v;
		}

//[TODO] why is vn here!? what does it do?
		public static function putValue(v, w:ESObject, vn) {
			if (v instanceof Reference)
				return (v.base || ExecutionContext.global).setProperty(v.propertyName, w);
			throw new ReferenceError('Invalid assignment left-hand side');
		}

//[TODO] incorporate into ESObject?
		public static function isPrimitive(v:ESObject):Boolean {
			var t = typeof v.valueOf();
			return (t == 'object') ? v === null : t != 'function';
		}

		public static function isObject(v:ESObject):Boolean {
			var t = typeof v;
			return (t == 'object') ? v !== null : t == 'function';
		}

		// If r instanceof Reference, v == getValue(r); else v === r.  If passed, rn
		// is the node whose execute result was r.
		public static function toObject(v:ESObject, r) {
			switch (typeof v) {
			  case "boolean":
				return ESObject.wrap(Boolean).construct(v);
			  case "number":
				return ESObject.wrap(Number).construct(v);
			  case "string":
				return ESObject.wrap(String).construct(v);
			  case "function":
				return v;
			  case "object":
				if (v !== null)
					return v;
			}
			// object is null, can't be converted
			throw new TypeError(r + " (type " + (typeof v) + ") has no properties");
		}

//[TODO] ...what's this even do?
		public static function thunk(f, x) {
			return function () { return f.__call__(this, arguments, x); };
		}

//[TODO] not sure if this works. normally, x is supplied at call-time!
// wrap args in Activation(f, a)... or, we create ESFunction class
		public static function createFunctionObject(node, scope, x):ESObject {
			// create the function
			var $function:ESObject = ESObject.wrap(function () {
				// Curse ECMA for specifying that arguments is not an Array object!
//[TODO] actually convert that, lawls
// dontEnum on length OR indices!?
				
				// function call
				var x2 = new ExecutionContext(ExecutionContext.FUNCTION_CODE);
				x2.thisObject = this;
				x2.caller = x;
				x2.callee = this;
				arguments.callee = this;
				arguments.setPropertyIsEnumerable('callee', false);
				x2.scope = {
					object: ESObject.wrap(new Activation(node, arguments)),
					parent: scope
				    };
	
				ExecutionContext.current = x2;
				try {
					Evaluator.execute(node.body, x2);
				} catch (e) {
				   if (e == Token.RETURN)
					return x2.result;
					   if (e == Token.THROW)
						x.result = x2.result;
						throw e;
				} finally {
					ExecutionContext.current = x;
				}
				return undefined;
			     });
			
			// prototype.toString
			$function.getProperty('prototype').setProperty('toString',
			    ESObject.wrap(node.getSource));			
			// prototype.length
			$function.getProperty('prototype').setProperty('length',
			    new ESObject(node.params.length), true, true, true);
			
			return $function;
		}

		public static function execute(n, x) {
			var a, f, i, j, r, s, t, u:*, v:*;

//[DEBUG]		trace('SRT: ' + Token.getConstant(n.type) + ' (line: ' + n.lineno + ')');
			switch (n.type) {
			  case Token.FUNCTION:
//[TODO] what to do about function tokens?
				if (n.functionForm != Token.FUNCTION_DECLARED_FORM) {
					if (!n.name || n.functionForm == Token.FUNCTION_STATEMENT_FORM) {
						v = createFunctionObject(n, x.scope, x);
						if (n.functionForm == Token.FUNCTION_STATEMENT_FORM)
//[TODO] dontDelete this following property!
							x.scope.object[n.name] = v;
					} else {
						t = new Object;
						x.scope = {object: t, parent: x.scope};
						try {
							v = createFunctionObject(n, x.scope, x);
//[TODO] dontDelete and readOnly this following property!
							t[n.name] = v;
						} finally {
							x.scope = x.scope.parent;
						}
					}
				}
				break;

			  case Token.SCRIPT: 
				t = x.scope.object;
				
				// load function declarations
				a = n.funDecls;
				for (i = 0, j = a.length; i < j; i++) {
					s = a[i].name;
					f = createFunctionObject(a[i], x.scope, x);
					t.setProperty(s, f, x.type != ExecutionContext.EVAL_CODE);
				}
				
				a = n.varDecls;
				for (i = 0, j = a.length; i < j; i++) {
					u = a[i];
					s = u.name;
					if (u.readOnly && hasDirectProperty(t, s)) {
						throw new TypeError("Redeclaration of const " + s);
					}
					if (u.readOnly || !hasDirectProperty(t, s)) {
						t.setProperty(s, new ESObject(undefined), x.type != ExecutionContext.EVAL_CODE, u.readOnly);
					}
				}
				// FALL THROUGH

			  case Token.BLOCK: 
				for (i = 0, j = n.length; i < j; i++)
					execute(n[i], x);
				break;

			  case Token.IF:
				if (getValue(execute(n.condition, x)).valueOf())
					execute(n.thenPart, x);
				else if (n.elsePart)
					execute(n.elsePart, x);
				break;

			  case Token.SWITCH:
				s = getValue(execute(n.discriminant, x));
				a = n.cases;
				var matchDefault = false;
			
				switchloop: for (i = 0, j = a.length; ; i++) {
					if (i == j) {
						if (n.defaultIndex >= 0) {
							i = n.defaultIndex - 1; // no case matched, do default
							matchDefault = true;
							continue;
						}
						break;					  // no default, exit switch_loop
					}
					t = a[i];					   // next case (might be default!)
					if (t.type == Token.CASE) {
						u = getValue(execute(t.caseLabel, x));
					} else {
						if (!matchDefault)		  // not defaulting, skip for now
							continue;
						u = s;					  // force match to do default
					}
					if (u === s) {
						for (;;) {				  // this loop exits switch_loop
							if (t.statements.length) {
								var e;
								try {
									execute(t.statements, x);
								} catch (e) {
						if (e != Token.BREAK && x.target != n)
							throw e;
								}
					if (e == Token.BREAK && x.target == n)
						break switchloop;
							}
							if (++i == j)
								break switchloop;
							t = a[i];
						}
						// NOT REACHED
					}
				}
				break;

			  case Token.FOR:
				n.setup && getValue(execute(n.setup, x));
				// FALL THROUGH
			  case Token.WHILE:
				while (!n.condition || getValue(execute(n.condition, x))) {
					try {
						execute(n.body, x);
					} catch (e) {
				if (e == Token.BREAK && x.target == n)
					break;
				if (e == Token.CONTINUE && x.target == n)
					continue;
				throw e;
					}
					n.update && getValue(execute(n.update, x));
				}
				break;

			  case Token.FOR_IN:
				u = n.varDecl;
				if (u)
					execute(u, x);
				r = n.iterator;
				s = execute(n.object, x);
				v = getValue(s);

				t = toObject(v, s);
				a = [];
				for (i in t)
					a.push(i);
				for (i = 0, j = a.length; i < j; i++) {
					putValue(execute(r, x), a[i], r);
					try {
						execute(n.body, x);
					} catch (e) {
				if (e == Token.BREAK && x.target == n)
					break;
				if (e == Token.CONTINUE && x.target == n)
					continue;
				throw e;
					}
				}
				break;

			  case Token.DO:
				do {
					try {
						execute(n.body, x);
					} catch (e) {
				if (e == Token.BREAK && x.target == n)
					break;
				if (e == Token.CONTINUE && x.target == n)
					continue;
				throw e;
					}
				} while (getValue(execute(n.condition, x)));
				break;

			  case Token.BREAK:
			  case Token.CONTINUE:
				x.target = n.target;
				throw n.type;

			  case Token.TRY:
				try {
					execute(n.tryBlock, x);
				} catch (e) {
				if (e == Token.THROW && (j = n.catchClauses.length)) {
					e = x.result;
					x.result = undefined;
					for (i = 0; ; i++) {
						if (i == j) {
							x.result = e;
							throw Token.THROW;
						}
						t = n.catchClauses[i];
						x.scope = {object: {}, parent: x.scope};
//[TODO] dontDelete this following property!
						x.scope.object[t.varName] = e;
						try {
							execute(t.block, x);
							break;
						} finally {
							x.scope = x.scope.parent;
						}
					}
				} else
				throw e;
				} finally {
					if (n.finallyBlock)
						execute(n.finallyBlock, x);
				}
				break;

			  case Token.THROW:
				x.result = getValue(execute(n.exception, x));
				throw Token.THROW;

			  case Token.RETURN:
//[TODO] also a hack. check normal narcissus behavior for undefined return statements!
				x.result = n.value ? getValue(execute(n.value, x)) : undefined;
				throw Token.RETURN;

			  case Token.WITH:
				r = execute(n.object, x);
				t = toObject(getValue(r), r);
				x.scope = {object: t, parent: x.scope};
				try {
					execute(n.body, x);
				} finally {
					x.scope = x.scope.parent;
				}
				break;

			  case Token.VAR:
			  case Token.CONST:
				for (i = 0, j = n.length; i < j; i++) {
					u = n[i].initializer;
					if (!u)
						continue;
					t = n[i].name;
					for (s = x.scope; s; s = s.parent) {
						if (s.object.hasOwnProperty(t))
							break;
					}
					u = getValue(execute(u, x));
					if (n.type == Token.CONST)
						s.object.setProperty(t, u, x.type != ExecutionContext.EVAL_CODE, true);
					else
						s.object.setProperty(t, u);
				}
				break;

			  case Token.DEBUGGER:
				throw "NYI: " + Token.getConstant(n.type);

			  case Token.SEMICOLON:
				if (n.expression)
					x.result = getValue(execute(n.expression, x));
				break;

			  case Token.LABEL:
				try {
					execute(n.statement, x);
				} catch (e) {
				if (e != Token.BREAK || x.target != n)
					throw e;
				}
				break;

			  case Token.COMMA:
				for (i = 0, j = n.length; i < j; i++)
					v = getValue(execute(n[i], x));
				break;

			  case Token.ASSIGN:
				r = execute(n[0], x);
				t = n[0].assignOp;
				v = getValue(execute(n[1], x)).valueOf();
				
				// assignment operator
				if (t) {
					u = getValue(r).valueOf();
					switch (t) {
					    case Token.BITWISE_OR:	v = u | v; break;
					    case Token.BITWISE_XOR:	v = u ^ v; break;
					    case Token.BITWISE_AND:	v = u & v; break;
					    case Token.LSH:		v = u << v; break;
					    case Token.RSH:		v = u >> v; break;
					    case Token.URSH:		v = u >>> v; break;
					    case Token.PLUS:		v = u + v; break;
					    case Token.MINUS:	   	v = u - v; break;
					    case Token.MUL:		v = u * v; break;
					    case Token.DIV:		v = u / v; break;
					    case Token.MOD:		v = u % v; break;
					}
				}
				
				putValue(r, new ESObject(v), n[0]);
				break;

			  case Token.CONDITIONAL:
				v = getValue(execute(n[0], x)).valueOf() ?
				    getValue(execute(n[1], x)) : getValue(execute(n[2], x));
				break;

			    case Token.OR:
			    case Token.AND:
			    case Token.BITWISE_OR:
			    case Token.BITWISE_XOR:
			    case Token.BITWISE_AND:
			    case Token.EQ:
			    case Token.NE:
			    case Token.STRICT_EQ:
			    case Token.STRICT_NE:
			    case Token.LT:
			    case Token.LE:
			    case Token.GE:
			    case Token.GT:
			    case Token.IN:
		 	    case Token.INSTANCEOF:
			    case Token.LSH:
			    case Token.RSH:
			    case Token.URSH:
			    case Token.PLUS:
			    case Token.MINUS:
			    case Token.MUL:
			    case Token.DIV:
			    case Token.MOD:
			  	// operation
				u = getValue(execute(n[0], x)).valueOf();
			  	v = getValue(execute(n[1], x)).valueOf();
				switch (n.type) {
				    case Token.OR:		v = u || v; break;
				    case Token.AND:		v = u && v; break;
				    case Token.BITWISE_OR:	v = u | v; break;
				    case Token.BITWISE_XOR:	v = u ^ v; break;
				    case Token.BITWISE_AND:	v = u & v; break;
				    case Token.EQ:		v = u == v; break;
				    case Token.NE:		v = u !- v; break;
				    case Token.STRICT_EQ:	v = u === v; break;
				    case Token.STRICT_NE:	v = u !== v; break;
				    case Token.LT:		v = u < v; break;
				    case Token.LE:		v = u <= v; break;
				    case Token.GE:		v = u > v; break;
				    case Token.GT:		v = u >= v; break;
				    case Token.IN:		v = u in v; break;
				    case Token.INSTANCEOF:	v = u instanceof v; break;
				    case Token.LSH:		v = u << v; break;
				    case Token.RSH:		v = u >> v; break;
				    case Token.URSH:		v = u >>> v; break;
				    case Token.PLUS:		v = u + v; break;
				    case Token.MINUS:		v = u - v; break;
				    case Token.MUL:		v = u * v; break;
				    case Token.DIV:		v = u / v; break;
				    case Token.MOD:		v = u % v; break;
				}
				break;

			  case Token.DELETE:
				t = execute(n[0], x);
				v = !(t instanceof Reference) || t.base.deleteProperty(t.propertyName);
				break;

			  case Token.VOID:
				getValue(execute(n[0], x));
				break;

			  case Token.TYPEOF:
				t = execute(n[0], x);
				if (t instanceof Reference)
					t = t.base ? t.base.getProperty(t.propertyName) : undefined;
				v = ESObject.wrap(typeof t.valueOf());
				break;

			  case Token.NOT:
				v = !getValue(execute(n[0], x));
				break;

			  case Token.BITWISE_NOT:
				v = ~getValue(execute(n[0], x));
				break;

			  case Token.UNARY_PLUS:
				v = +getValue(execute(n[0], x));
				break;

			  case Token.UNARY_MINUS:
				v = -getValue(execute(n[0], x));
				break;

			  case Token.INCREMENT:
			  case Token.DECREMENT:
				t = execute(n[0], x);
				u = Number(getValue(t));
				if (n.postfix)
					v = u;
				putValue(t, new ESObject((n.type == Token.INCREMENT) ? ++u : --u), n[0]);
				if (!n.postfix)
					v = u;
				break;

			  case Token.DOT:
				r = execute(n[0], x);
				t = getValue(r);
				u = n[1].value;
//[TODO] toObject call incorrect...
				v = new Reference(toObject(t, r), u, n);
				break;

			  case Token.INDEX:
				r = execute(n[0], x);
				t = getValue(r);
				u = getValue(execute(n[1], x));
				v = new Reference(toObject(t, r), String(u), n);
				break;

			  case Token.LIST:
				// originally created faux arguments array; no longer! functionobject does so
//[TODO] make sure i didn't slaughter anything here...
				for (v = [], i = 0, j = n.length; i < j; i++)
					v.push(getValue(execute(n[i], x)).valueOf());
				break;

			  case Token.CALL:
//[TODO] when f shortens out to null, whut then?
				r = execute(n[0], x);
				a = execute(n[1], x).valueOf();
//[TODO] Tokenizer.createError(Class, message) inserts line, etc
				if ((f = getValue(r)) === null)
					throw new ReferenceError(r.propertyName + ' is not defined. (line: ' + n.lineno + ')');
				t = (r instanceof Reference) ? r.base : null;
				if (t instanceof Activation)
					t = null;
				// convert ESObject array to normal array
				for (var arg in a)
					a[arg] = ESObject.wrap(a[arg]);
				v = f.call.apply(t, a);
				break;

			  case Token.NEW:
			  case Token.NEW_WITH_ARGS:
				r = execute(n[0], x);
				f = getValue(r);
				a = (n.type == Token.NEW) ? [] : execute(n[1], x).valueOf();
				// convert ESObject array to normal array
				for (var arg in a)
					a[arg] = ESObject.wrap(a[arg]);
				v = f.construct.apply(f, a);
				break;

			  case Token.ARRAY_INIT:
				v = [];
				for (i = 0, j = n.length; i < j; i++) {
					if (n[i])
						v[i] = getValue(execute(n[i], x)).valueOf();
				}
				v.length = j;
				break;

			  case Token.OBJECT_INIT:
				v = {};
				for (i = 0, j = n.length; i < j; i++) {
					t = n[i];
					v[t[0].value] = getValue(execute(t[1], x)).valueOf();
				}
				break;

			  case Token.NULL:
				v = null;
				break;

			  case Token.THIS:
				v = x.thisObject;
				break;

			  case Token.TRUE:
				v = true;
				break;

			  case Token.FALSE:
				v = false;
				break;

			  case Token.IDENTIFIER:
//[TODO] should this be hasOwnProperty?
			  	// get the scope where this is defined
				for (s = x.scope; s; s = s.parent) {
//[TODO] also this is quite the hack:
					if (s.object.hasProperty && s.object.hasProperty(n.value))
						break;
				}
				// return the reference
				v = new Reference(s ? s.object : null, n.value, n);
				break;

			  case Token.NUMBER:
			  case Token.STRING:
			  case Token.REGEXP:
				v = n.value;
				break;

			  case Token.GROUP:
				v = execute(n[0], x);
				break;

			  default:
				throw "PANIC: unknown operation " + n.type;
			}
//[DEBUG]		trace('END: ' + Token.getConstant(n.type) + ' (line: ' + n.lineno + ')');
			
			// return a reference or ESObject
			return v is ESObject || v is Reference ? v : ESObject.wrap(v);
		}

		public static function evaluate(s, f = null, l = null) {
			if (typeof s != "string")
				return s;

			var x = ExecutionContext.current;
			var x2 = new ExecutionContext(ExecutionContext.GLOBAL_CODE);
			ExecutionContext.current = x2;
			try {
				execute(Parser.parse(s, f, l), x2);
			} catch (e) {
				if (e == Token.THROW) {
					if (x) {
						x.result = x2.result;
						throw Token.THROW;
					}
					throw x2.result;
				}
				throw e;
			} finally {
				ExecutionContext.current = x;
			}
//[TODO] should this return an ESOBject?
			return x2.result.valueOf();
		}
	}
}