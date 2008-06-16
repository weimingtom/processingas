package processing.parser {
	public class Token {
		// properties
		public var type:TokenType;
		public var value:* = null;
		public var start:int = 0;
		public var content:String = '';
		public var line:int = 0;
		public var assignOp:TokenType;
		
		public function Token(t:TokenType, v:* = null, c:String = '', s:int = 0, l:int = 0, a:TokenType = undefined) {
			type = t;
			value = v;
			start = s;
			content = c;
			line = l;
			assignOp = a;
		}
	}
}
