package processing.parser {
	import processing.parser.Statement;
	import processing.parser.Evaluator;

	dynamic public class Block extends Array {
		public function Block(... statements):void {
			for each (var statement:Statement in statements)
				push(statement);
		}

//[TODO] should literals be wrapped in Statement functions?
		public function execute(context:EvaluatorContext) {
			// iterate block
			var retValue:*;
			for each (var statement:* in this)
				retValue = (statement is Statement) ? statement.execute(context) : statement;
			return retValue;
		}
		
		public function append(block:Block) {
			// perform permanent concatenation
			for each (var statement:Statement in block)
				push(statement);
			return length;
		}
		
		public function debug(evaluator:Evaluator, indent = 0):void {
			for (var l = 0, ind = ''; l < indent; l++)
				ind += '\t';
				
			trace(ind + '{');
			for each (var i:* in this)
				if (i is Statement)
					i.debug(evaluator, indent + 1);
				else
					trace(ind + '\tentry: "' + i + '"');
			trace(ind + '}');
		}
	}
}
