package processing.parser.statements
{
	import processing.parser.*;

	public class Reference implements IExecutable
	{
		public var identifier:IExecutable;
		public var base:IExecutable;
	
		public function Reference(i:IExecutable, b:IExecutable = null)
		{
			identifier = i;
			base = b;
		}
	
		public function execute(context:EvaluatorContext):*
		{
			// get simplified reference
			var ref:Reference = reduce(context);
			// return value
			return ref ? ref.base[ref.identifier] : ref;
		}
		
		public function reduce(context:EvaluatorContext):Reference
		{
			// evaluate identifier
			var identifier = this.identifier.execute(context);
			// evaluate base reference in current context
			if (base)
			{
				// base object exists
				var base = this.base.execute(context);
			}
			else
			{
				// climb context inheritance to find declared identifier
				for (var c:EvaluatorContext = context;
				    c && !c.scope.hasOwnProperty(_identifier);
				    c = c.parent);
				if (!c)
					return undefined;
				var base = c.scope;
			}

			// return reduced reference
			return new Reference(identifier, base);
		}
	}
}
