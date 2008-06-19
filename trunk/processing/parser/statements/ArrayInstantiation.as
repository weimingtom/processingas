package processing.parser.statements
{
	import processing.parser.*;
	import processing.api.ArrayList;

	public class ArrayInstantiation implements IExecutable
	{
		public var _type:*;
		public var _size:*;
	
		public function ArrayInstantiation(type:*, size:*) {
//[TODO] multi-dimensional arrays?
			_type = type;
			_size = size;
		}
	
		public function execute(context:EvaluatorContext):*
		{
			// execute statements
			var size = _size is IExecutable ? _size.execute(context) : _size;
		
			// return new ArrayList object
			return new ArrayList(size, 0, 0, _type);
		}
	}
}