package processing.parser
{	
	public class ExecutionContext
	{
//[TODO] rename this to Scope class?
		public var scope:Object = {};
		public var parent:EvaluatorContext;
		public var thisObject:Object = null;
//		public var caller;
//		public var callee;
//		public var result = undefined;
//		public var target = null;

		public function ExecutionContext(s:Object = null, p:EvaluatorContext = null, t:Object = null):void
		{
			scope = s || {};
			parent = p;
			thisObject = t;
		}
	}
}
