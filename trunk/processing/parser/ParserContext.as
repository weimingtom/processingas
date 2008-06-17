package processing.parser {
	public class ParserContext {
		// properties
		public var inFunction:Boolean = false;
		public var bracketLevel:int = 0;
		public var curlyLevel:int = 0;
		public var parenLevel:int = 0;
		public var hookLevel:int = 0;
		public var inForLoopInit:Boolean = false;
		
//[TODO] make stmtStack, funDecls, varDecls into Blocks?
		public var stmtStack:Array = [];
		public var funDecls:Array = [];
		public var varDecls:Array = [];
		
		// constructor
		public function ParserContext(inFunction:Boolean = false) {
			inFunction = inFunction;
		}
	}
}