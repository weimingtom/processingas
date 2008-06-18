package processing.parser.statements
{
	import processing.parser.*;

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
			return new ArrayList(_type, size);
		}
	}
}

class ArrayList extends Array {
	private var _type:*;

	public function ArrayList( type:*, size:int = 0, size2:int = 0, size3:int = 0 ):void
	{
		// initialize array
		super( 0 | size );
		
		if ( size2 )
		{
			for ( var i = 0; i < size; i++ )
			{
				this[i] = [];

				for ( var j = 0; j < size2; j++ )
				{
					var a = this[i][j] = size3 ? new Array( size3 ) : 0;
					for ( var k = 0; k < size3; k++ )
					{
						a[k] = 0;
					}
				}
			}
		}
		else
		{
			for ( var i = 0; i < size; i++ )
			{
				this[i] = 0;
			}
		}
		
		// preserve type
		_type = type;
//[TODO] do something with type!
	}
	
	public function size():int
	{
		return this.length;
	}
	
	public function get( i ):*
	{
		return this[ i ];
	}
	
	public function remove( i ):*
	{
		return this.splice( i, 1 );
	}
	
	public function add( item ):void
	{
		for ( var i = 0; this[ i ] != undefined; i++ );
		this[ i ] = item;
	}
	
	public function clone():ArrayList
	{
		var a = new ArrayList( size );
		for ( var i = 0; i < size; i++ )
		{
			a[ i ] = this[ i ];
		}
		return a;
	}

	public function isEmpty():Boolean
	{
		return !this.length;
	}

	public function clear():void
	{
		this.length = 0;
	}
}