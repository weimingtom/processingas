package com.gamemeal.graphics {
	public class ImageData {
		private var _width:Number;
		public function get width():Number { return _width; }
		private var _height:Number;
		public function get height():Number { return _width; }
		private var _data:Array;
		public function get data():Array { return _data; }
		
		public function ImageData(w:Number, h:Number, d:Array){
			_width = w;
			_height = h;
			_data = d;
		}
	}
}