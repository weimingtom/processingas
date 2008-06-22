package processing.api
{
	dynamic public class ArrayList extends Array {
		private var _type:*;
	
		public function ArrayList( size1:int = 0, size2:int = 0, size3:int = 0, type:* = null ):void
		{
			// initialize array
			super( size1 );
			
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
				for ( var i = 0; i < size1; i++ )
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
			var a = new ArrayList( this.length );
			for ( var i = 0; i < this.length; i++ )
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
}