package asas {
	dynamic public class ExecutionContext {
		// code type constants
		public static const GLOBAL_CODE:Object = new Object();
		public static const EVAL_CODE:Object = new Object();
		public static const FUNCTION_CODE:Object = new Object();
	
		// current context
		public static var current:ExecutionContext;
		
		public static var global = ESObject.wrap({
			// values
			NaN: NaN,
			Infinity: Infinity,
			undefined: undefined,
			
			// functions
			parseInt: parseInt,
			parseFloat: parseFloat,
			isNaN: isNaN,
			isFinite: isFinite,
			decodeURI: decodeURI,
			encodeURI: encodeURI,
			decodeURIComponent: decodeURIComponent,
			encodeURIComponent: encodeURIComponent,

			// eval function
			eval: function eval(s) {
				if (typeof s != "string")
					return s;

				var x = ExecutionContext.current;
				var x2 = new ExecutionContext(ExecutionContext.EVAL_CODE);
				x2.thisObject = x.thisObject;
				x2.caller = x.caller;
				x2.callee = x.callee;
				x2.scope = x.scope;
				ExecutionContext.current = x2;
				try {
					Evaluator.execute(Parser.parse(s), x2);
				} catch (e) {
				if (e == Token.THROW)
					x.result = x2.result;
					throw e;
				} finally {
					ExecutionContext.current = x;
				}
				return x2.result;
			},


			// Class constructors.  Where ECMA-262 requires C.length == 1, we declare
			// a dummy formal parameter.
			Object: Object,
			Function: Function,
			Array: Array,
			String: String,
			Boolean: Boolean,
			Number: Number,
			Date: Date,
			RegExp: RegExp,
			Error: Error,
			EvalError: EvalError,
			RangeError: RangeError,
			ReferenceError: ReferenceError,
			SyntaxError: SyntaxError,
			TypeError: TypeError,
			URIError: URIError,

			// other properties
			Math: Math
		    }, false);
			
				
			/*Function: function Function(dummy) {
				var p = "", b = "", n = arguments.length;
				if (n) {
					var m = n - 1;
					if (m) {
						p += arguments[0];
						for (var k = 1; k < m; k++)
							p += "," + arguments[k];
					}
					b += arguments[m];
				}

				// XXX We want to pass a good file and line to the tokenizer.
				// Note the anonymous name to maintain parity with Spidermonkey.
				var t = new Tokenizer("anonymous(" + p + ") {" + b + "}");

				// NB: Use the STATEMENT_FORM constant since we don't want to push this
				// function onto the null compilation context.
				var f = Parser.FunctionDefinition(t, null, false, FunctionObject.STATEMENT_FORM);
				var s = {object: global, parent: null};
				return new FunctionObject(f, s);
			},
			Array: function Array(dummy) {
				// Array when called as a function acts as a constructor.
				return [].constructor.apply(this, arguments);
			},
			String: (function (str) {
				var StringClass = String;
				var String = function (str = '') {
					// convert the passed argument to a string
					str = StringClass(str);
					
					// when not called as a constructor, return a string representation
					if (!(this instanceof String))
						return str;
					// override string functions
					this.toString = function () { return str; }
					this.setPropertyIsEnumerable('toString', false);
					this.length = str.length;
					this.setPropertyIsEnumerable('length', false);
				}
				String.fromCharCode = StringClass.fromCharCode;
				for each (var prop in ['valueOf', 'charAt', 'charCodeAt',
				    'concat', 'indexOf', 'lastIndexOf', 'localeCompare',
				    'match', 'replace', 'search', 'slice', 'split',
				    'substring', 'toLowerCase', 'toLocaleLowerCase',
				    'toUpperCase', 'toLocaleUpperCase']) {
					String.prototype[prop] = StringClass.prototype[prop];
					String.prototype.setPropertyIsEnumerable(prop, false);
				}
				return String;
			})(),*/
	
		public var caller;
		public var callee;
		public var scope:Object = {object: ExecutionContext.global, parent: null};
		public var thisObject = global;
		public var result = undefined;
		public var target = null;
		public var type;
		
		public function ExecutionContext(type) {
			this.type = type;
		}
	}
}