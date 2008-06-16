package processing.parser {
	import processing.parser.Tokenizer;

	public class TokenizerSyntaxError extends SyntaxError {
		public var source:String = '';
		public var cursor:Number = 0;
		
		public function TokenizerSyntaxError(message:String = '', tokenizer:Tokenizer = undefined) {
			super(message);
			if (tokenizer) {
				source = tokenizer.source;
				cursor = tokenizer.cursor;
			}
		}
	}
}