package processing.parser {
	public class EvaluatorContext {
//		public var caller;
//		public var callee;
		public var scope:Object = {};
		public var parent:EvaluatorContext;
//		public var thisObject = global;
//		public var result = undefined;
//		public var target = null;
		
		public function EvaluatorContext(s:Object = null, p:EvaluatorContext = null):void {
			scope = s || {};
			parent = p || null;
		}
	}
}