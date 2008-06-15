package processing.parser {
	import processing.parser.Statement;
	import processing.parser.Evaluator;

	public class Block extends Array {
		public function Block(... statements):void {
			for each (var statement:Statement in statements)
				push(statement);
		}

		public function execute(evaluator:Evaluator) {
			// iterate block
			var retValue:*;
			for each (var statement:Statement in this)
				retValue = statement.execute(evaluator);
			return retValue;
		}
	}
}
