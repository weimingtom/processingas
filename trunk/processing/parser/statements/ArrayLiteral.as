package processing.parser.statements
{
	import processing.parser.*;

	public class ArrayLiteral implements IExecutable
	{
		public var value:Array;
	
		public function ArrayLiteral(v:Array) {
			value = v;
		}
	
		public function execute(context:ExecutionContext):*
		{
			// parse array
			var array:Array = new Array();
			for (var i:* in value)
				array[i] = value[i].execute(context);
			return array;
		}
	}
}
