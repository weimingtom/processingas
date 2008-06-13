package asas {
	public class TokenType {
		private var _value:String;
		private var _precedence:int;
		private var _arity:int;
		private var _type:int;
	
		public function TokenType(value:String = '', precedence:int = 0, arity:int = 0, type:int = 0):void {
			_value = value;
			_precedence = precedence;
			_arity = arity;
			_type = type;
		}
		
		//=============================================================
		// type constants
		//=============================================================
		
//		public static const KEYWORD = 1;
//		public static const OPERATOR = 2;
//		public static const ASSIGNMENT_OPERATOR = 6;

		//=============================================================
		// get properties
		//=============================================================
		
		public function get value():String {
			return _value;
		}

		public function get precedence():int {
			return _precedence;
		}
		
		public function get arity():int {
			return _arity;
		}
		
		public function get type():int {
			return _type;
		}
		
		//=============================================================
		// string functions
		//=============================================================
		
		public function toString():String {
			return _value;
		}
		
		public function valueOf():String {
			return _value;
		}
	}
}