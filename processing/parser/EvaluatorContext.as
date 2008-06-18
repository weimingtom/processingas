package processing.parser
{
	import processing.api.*;
	
	public class EvaluatorContext
	{
//		public var caller;
//		public var callee;
		public var scope:Object = {};
		public var parent:EvaluatorContext;
//		public var thisObject = global;
//		public var result = undefined;
//		public var target = null;
		
		public function EvaluatorContext(s:Object = null, p:EvaluatorContext = null):void
		{
			scope = s || {};
			parent = p || null;
		}
		
		public function findVariableContext(identifier:String):EvaluatorContext
		{
			// climb context inheritance tree
			for (var context:EvaluatorContext = this;
			    context && !context.scope.hasOwnProperty(identifier);
			    context = context.parent);
			return context;
		}
	}
}