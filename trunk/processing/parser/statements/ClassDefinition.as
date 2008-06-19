package processing.parser.statements
{
	import processing.parser.*;

	public class ClassDefinition implements IExecutable
	{
		public var _identifier:String;
		public var _constructor:IExecutable;
		public var _publicBody:IExecutable;
		public var _privateBody:IExecutable;
	
		public function ClassDefinition(identifier:String, constructor:IExecutable, publicBody:IExecutable, privateBody:IExecutable) {
			_identifier = identifier;
			_constructor = constructor;
			_publicBody = publicBody;
			_privateBody = privateBody;
		}
		
		public function execute(context:EvaluatorContext):*
		{
			context.scope[_identifier] = function (... args)
			{
				// check that this be called as a constructor
//[TODO] that
			
				// create new evaluator contexts
//[TODO] really this should modify .prototype...
				var objContext:EvaluatorContext = new EvaluatorContext(this, context);
				var classContext:EvaluatorContext = new EvaluatorContext({}, objContext);
				
				// define variables
				_publicBody.execute(objContext);
				_privateBody.execute(classContext);

				// call constructor
				if (_constructor) {
//[TODO] look into alternate means of defining constructor?
					_constructor.execute(classContext);
					classContext.scope[_identifier].apply(classContext.scope, args);
				}
			}
		}
	}
}
