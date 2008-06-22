package processing.parser.statements
{
	import processing.parser.*;
	import processing.api.ArrayList;

	public class ArrayInstantiation implements IExecutable
	{
		public var type:*;
		public var size:IExecutable;
	
		public function ArrayInstantiation(t:*, s:IExecutable) {
//[TODO] multi-dimensional arrays?
			type = t;
			size = s;
		}
	
		public function execute(context:ExecutionContext):*
		{
			// return new ArrayList object
			return new ArrayList(size.execute(context), 0, 0, type);
		}
	}
}
