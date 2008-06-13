package asas {
	public class CompilerContext {
		// properties
		public var inFunction:Boolean = false;
		public var stmtStack:Array = [];
		public var funDecls:Array = [];
		public var varDecls:Array = [];
		public var bracketLevel:uint = 0;
		public var curlyLevel:uint = 0;
		public var parenLevel:uint = 0;
		public var hookLevel:uint = 0;
		public var inForLoopInit:Boolean = false;
		
		// constructor
		public function CompilerContext(inFunction:Boolean = false) {
			this.inFunction = inFunction;
		}
	}
}