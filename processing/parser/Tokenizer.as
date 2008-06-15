package processing.parser {
	dynamic public class Tokenizer {
		public var cursor;
		public var source;
		public var tokens;
		public var tokenIndex;
		public var lookahead;
		public var scanNewlines;
		public var scanOperand;
		public var filename;
		public var lineno;
		
		public function Tokenizer(s, f:String = '', l:uint = 0) {
			this.cursor = 0;
			this.source = String(s);
			this.tokens = [];
			this.tokenIndex = 0;
			this.lookahead = 0;
			this.scanNewlines = false;
			this.scanOperand = true;
			this.filename = f || "";
			this.lineno = l || 1;
		}
			
		public function get input() {
			return this.source.substring(this.cursor);
		}
	
		public function get done() {
			return this.peek() == Token.END;
		}
	
		public function get token() {
			return this.tokens[this.tokenIndex];
		}
		
		public function match(tt) {
			return this.get() == tt || this.unget();
		}
	
		public function mustMatch(tt) {
			if (!this.match(tt))
				throw this.newSyntaxError("Missing " + Token.getConstant(tt));
			return this.token;
		}
	
		public function peek() {
			var tt;
			if (this.lookahead) {
				tt = this.tokens[(this.tokenIndex + this.lookahead) & 3].type;
			} else {
				tt = this.get();
				this.unget();
			}
			return tt;
		}
	
		public function peekOnSameLine() {
			this.scanNewlines = true;
			var tt = this.peek();
			this.scanNewlines = false;
			return tt;
		}
	
		public function unget() {
			if (++this.lookahead == 4) throw "PANIC: too much lookahead!";
			this.tokenIndex = (this.tokenIndex - 1) & 3;
		}
	
		public function newSyntaxError(m) {
			var e = new SyntaxError(m);
			e.source = this.source;
			e.cursor = this.cursor;
			return e;
		}
		
		private function parseStringLiteral(str:String):String {
			return str
			    .replace(/((?:[^\\]|^)(?:\\\\)+)\\b/g, '$1\u0008')
			    .replace(/((?:[^\\]|^)(?:\\\\)+)\\t/g, '$1\u0009')
			    .replace(/((?:[^\\]|^)(?:\\\\)+)\\n/g, '$1\u000A')
			    .replace(/((?:[^\\]|^)(?:\\\\)+)\\v/g, '$1\u000B')
			    .replace(/((?:[^\\]|^)(?:\\\\)+)\\f/g, '$1\u000C')
			    .replace(/((?:[^\\]|^)(?:\\\\)+)\\r/g, '$1\u000D')
			    .replace(/((?:[^\\]|^)(?:\\\\)+)\\r/g, '$1\u000D')
			    .replace(/((?:[^\\]|^)(?:\\\\)+)\\"/g, '$1"')
			    .replace(/((?:[^\\]|^)(?:\\\\)+)\\'/g, "$1'")
			    .replace(/((?:[^\\]|^)(?:\\\\)+)\\u([0-9A-Fa-z]{4})/g, function (str, opening, code) {
				    return opening + String.fromCharCode(parseInt(code, 16));
				})
			    .replace(/((?:[^\\]|^)(?:\\\\)+)\\\\/g, '\\');
		}
		
		public function get() {
			var token:Object;
			while (this.lookahead) {
				--this.lookahead;
				this.tokenIndex = (this.tokenIndex + 1) & 3;
				token = this.tokens[this.tokenIndex];
				if (token.type != Token.NEWLINE || this.scanNewlines)
					return token.type;
			}
	
			for (; ; ) {
				var input = this.input;
				var match = (this.scanNewlines ? /^[ \t]+/ : /^\s+/)(input);
				if (match) {
					var spaces = match[0];
					this.cursor += spaces.length;
					var newlines = spaces.match(/\n/g);
					if (newlines)
						this.lineno += newlines.length;
					input = this.input;
				}
		
				if (!(match = /^\/(?:\*(?:.|\n|\r)*?\*\/|\/.*)/(input)))
					break;
				var comment = match[0];
				this.cursor += comment.length;
				newlines = comment.match(/\n/g);
				if (newlines)
					this.lineno += newlines.length;
			}
	
			this.tokenIndex = (this.tokenIndex + 1) & 3;
			token = this.tokens[this.tokenIndex];
			if (!token)
				this.tokens[this.tokenIndex] = token = {};
	
			if (!input)
				return token.type = Token.END;

			if ((match = /^\d+\.\d*(?:[eE][-+]?\d+)?|^\d+(?:\.\d*)?[eE][-+]?\d+|^\.\d+(?:[eE][-+]?\d+)?/(input))) {
				token.type = Token.NUMBER;
				token.value = parseFloat(match[0]);
			} else if ((match = /^0[xX][\da-fA-F]+|^0[0-7]*|^\d+/(input))) {
				token.type = Token.NUMBER;
				token.value = parseInt(match[0]);
			} else if ((match = /^\w+/(input))) {
				var id:String = match[0];
				token.type = Token.KEYWORDS[id] is TokenType ? Token.KEYWORDS[id] : Token.IDENTIFIER;
				token.value = id;
			} else if ((match = /^"(?:\\.|[^"])*"|^'(?:[^']|\\.)*'/(input))) {
				// string ""
				token.type = Token.STRING;
				token.value = parseStringLiteral(match[0].substring(1, match[0].length - 1));
			} else if (this.scanOperand &&
					   (match = /^\/((?:\\.|[^\/])+)\/([gimy]*)/(input))) {
				token.type = Token.REGEXP;
				token.value = new RegExp(parseStringLiteral(match[1]), match[2]);
			} else if ((match = /^(\|\||&&|===?|!==?|<<|<=|>>>?|>=|\+\+|--|[;,?:|^&=<>+\-*\/%!~.[\]{}()])/(input))) {
				var op:String = match[0];
				if (Token.ASSIGNMENT_OPS[op] && input.charAt(op.length) == '=') {
					token.type = Token.ASSIGN;
					token.assignOp = Token.OPS[op];
					match[0] += '=';
				} else {
					token.type = Token.OPS[op];
					if (this.scanOperand) {
						if (token.type == Token.PLUS) token.type = Token.UNARY_PLUS;
						if (token.type == Token.MINUS) token.type = Token.UNARY_MINUS;
					}
					token.assignOp = null;
				}
				token.value = op;
			} else {
				throw this.newSyntaxError("Illegal token " + input);
			}
	
			token.start = this.cursor;
			this.cursor += match[0].length;
			token.end = this.cursor;
			token.lineno = this.lineno;
			return token.type;
		}
	}
}
