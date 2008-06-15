package processing.parser {
	import processing.parser.Block;
	import processing.parser.Statement;

	public class Evaluator {
		// constants
		public const INT:Object = {};
		public const ADD:Object = {};
		public const LT:Object = {};
		public const FLOAT:Object = {};

		private var context:Object = {};

		public function Evaluator(c:Object):void {
			context = c;
		}

//[TODO] what parameter should this take?
		public function evaluate(code:*):* {
			return code.execute(this);
		}

		public function callMethod(func:String, args:Array = undefined) {
			// parse args for statements
			var parsedArgs:Array = [];
			if (args)
				for each (var i:* in args)
					parsedArgs.push(i instanceof Statement ? i.execute(this) : i);
			return context[func].apply(context, parsedArgs);
		}

		public function defineVar(type:Object, name:String, value:* = undefined) {
			// evaluate statements
			if (value instanceof Statement)
				value = value.execute(this);
			context[name] = value;
		}

		public function loop(cond:Statement, block:Block) {
			while (cond.execute(this))
				block.execute(this);
		}

		public function expression(a:*, b:*, type:Object) {
			// evaluate statements
			if (a instanceof Statement)
				a = a.execute(this);
			if (b instanceof Statement)
				b = b.execute(this);

			// execute expression
			switch (type) {
				case ADD: return a + b;
				case LT: return a < b;
				default: throw new Error('Unrecognized type.');
			}
		}

		public function getValue(varName:String) {
			return context[varName];
		}

		public function setValue(varName:String, value:*) {
			// check if value is a statement
			if (value instanceof Statement)
				value = value.execute(this);
			return context[varName] = value;
		}
	}
}
