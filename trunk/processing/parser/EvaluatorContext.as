package processing.parser
{	
	public class EvaluatorContext
	{
//		public var caller;
//		public var callee;
		public var scope:Object = {};
		public var parent:EvaluatorContext;
		public var thisObject:Object = null;
//		public var result = undefined;
//		public var target = null;
		
		public function EvaluatorContext(s:Object = null, p:EvaluatorContext = null, t:Object = null):void
		{
			scope = s || {};
			parent = p;
			thisObject = t;
		}
	}
}