package processing.parser.statements
{
	import processing.parser.*;

	public class Reference implements IExecutable
	{
		public var identifier:*;
		public var base:Object;
	
		public function Reference(i:*, b:Object = null)
		{
			identifier = i;
			base = b;
		}
	
		public function execute(context:EvaluatorContext):*
		{
			// get simplified reference
			var ref:Reference = reduce(context);
			// return value
			return ref.base[ref.identifier];
		}
		
		public function reduce(context:EvaluatorContext):Reference
		{
			// evaluate identifier
			var _identifier = (identifier is IExecutable) ? identifier.execute(context) : identifier;
			// reduce base reference in current context
			if (base)
			{
				// base object exists
				var _base = (base is IExecutable) ? base.execute(context) : base;
			}
			else
			{
				// climb context inheritance to find declared identifier
				for (var c:EvaluatorContext = context;
				    c && !c.scope.hasOwnProperty(_identifier);
				    c = c.parent);
				if (!c)
					return undefined;
				var _base = c.scope;
			}
			
			// return reduced reference
			return new Reference(_identifier, _base);
		}
	}
}