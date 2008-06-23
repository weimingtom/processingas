package processing.parser.statements
{
	import processing.parser.*;

	public class FunctionDefinition implements IExecutable
	{
		public var identifier:String;
		public var type:Type;
		public var params:Array;
		public var body:IExecutable;
	
		public function FunctionDefinition(i:String, t:Type, p:Array, b:IExecutable) {
			identifier = i;
			type = t;
			params = p;
			body = b;
		}
		
		public function execute(context:ExecutionContext):*
		{
			// check that a variable is not already defined
//[TODO] this shouldn't have " || !context.scope[identifier]"; must remove predefined .setup from Processing API context!
			if (!context.scope.hasOwnProperty(identifier) || !context.scope[identifier])
			{
				// define wrapper function
				context.scope[identifier] = function ()
				{
					// check that an overloader be available
					if (!arguments.callee.overloads.hasOwnProperty(arguments.length))
						throw new Error('Function called without proper argument number.');

					// convert arguments object to array
					for (var args:Array = [], i:int = 0; i < arguments.length; i++)
						args.push(arguments[i]);
					// call overload
					return arguments.callee.overloads[args.length].apply(null, args);
				}

				// create overloads array
				context.scope[identifier].overloads = [];
			}
			else if (context.scope[identifier] && !context.scope[identifier].hasOwnProperty('overloads'))
			{
				// cannot define function with name of declared variable
				throw new Error('Cannot declare function "' + identifier + '" as it is already defined.');
			}

			// add overload
//[TODO] overloads based on param type
			context.scope[identifier].overloads[params.length] = function (... args)
			{
				// check that this be called as a function
//[TODO] that
				// create new evaluator context
				var funcContext:ExecutionContext = new ExecutionContext({}, context);

				// parse args
				for (var i in args)
				{
//[TODO] what happens when args/params differ?
//[TODO] maybe shortcut something here?
					(new VariableDefinition(params[i][0], params[i][1])).execute(funcContext);
					(new Assignment(new Reference(new Literal(params[i][0])), new Literal(args[i]))).execute(funcContext);
				}
				
				try
				{
					// evaluate body
					body.execute(funcContext);
				}
				catch (ret:Return)
				{
					// handle returns
//[TODO] do something with type
					return ret.value.execute(funcContext);
				}
			}
		}
	}
}
