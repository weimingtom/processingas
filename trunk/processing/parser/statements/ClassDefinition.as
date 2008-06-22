package processing.parser.statements
{
	import processing.parser.*;

	public class ClassDefinition implements IExecutable
	{
		public var identifier:String;
		public var constructorBody:IExecutable;
		public var publicBody:IExecutable;
		public var privateBody:IExecutable;
	
		public function ClassDefinition(i:String, c:IExecutable, pu:IExecutable, pr:IExecutable) {
			identifier = i;
			constructorBody = c;
			publicBody = pu;
			privateBody = pr;
		}
		
		public function execute(context:ExecutionContext):*
		{
			// create class constructor
			context.scope[identifier] = function (... args)
			{
				// check that this be called as a constructor
//[TODO] that
			
				// create new evaluator contexts
//[TODO] really this should modify .prototype...
				var objContext:ExecutionContext = new ExecutionContext(this, context, this);
				var classContext:ExecutionContext = new ExecutionContext({}, objContext);
				
				// define variables
				publicBody.execute(objContext);
				privateBody.execute(classContext);

				// call constructor
				if (constructorBody) {
//[TODO] look into alternate means of defining constructor?
					constructorBody.execute(classContext);
					classContext.scope[identifier].apply(classContext.scope, args);
				}
			}
		}
	}
}
