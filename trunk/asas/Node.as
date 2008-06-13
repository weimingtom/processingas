package asas {
	dynamic public class Node extends Array {
		public static var indentLevel:uint = 0;
	
		public function Node(t, type = null, ... args) {
			var token = t.token;
			if (token) {
				this.type = type || token.type;
				this.value = token.value;
				this.lineno = token.lineno;
				this.start = token.start;
				this.end = token.end;
			} else {
				this.type = type;
				this.lineno = t.lineno;
			}
			this.tokenizer = t;

			for (var i = 0; i < args.length; i++)
				this['push'](args[i]);
		}

		// Always use push to add operands to an expression, to update start and end.
		public function push(kid) {
			if (kid.start < this.start)
				this.start = kid.start;
			if (this.end < kid.end)
				this.end = kid.end;
			return this[this.length] = kid;
		}

		public function toString() {
			function repeatString(t, n) {
					var s = "";
					while (--n >= 0)
						s += t;
					return s;
			}

			var a = [];
			for (var i in this) {
				if (this.hasOwnProperty(i) && i != 'type')
					a.push({id: i, value: this[i]});
			}
			a.sort(function (a,b) { return (a.id < b.id) ? -1 : 1; });
			var INDENTATION = '	';
			var n = ++Node.indentLevel;
			var s = "{\n" + repeatString(INDENTATION, n) + "type: " + Token.getConstant(this.type);
			for (i = 0; i < a.length; i++)
				s += ",\n" + repeatString(INDENTATION, n) + a[i].id + ": " + a[i].value;
			n = --Node.indentLevel;
			s += "\n" + repeatString(INDENTATION, n) + "}";
			return s;
		}

		public function getSource() {
			return this.tokenizer.source.slice(this.start, this.end);
		}
	}
}