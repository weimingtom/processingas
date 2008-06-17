package processing.api {
	public class Point {
		public var x:Number = 0;
		public var y:Number = 0;

		public function Point( _x, _y )
		{
			x = _x;
			y = _y;
		}
		
		public function copy()
		{
			return new Point( x, y );
		}
	}
}