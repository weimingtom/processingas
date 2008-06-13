package asas {
	dynamic public class Reference {
		public var base:ESObject;
		public var propertyName:String;
		public var node:Node;
		
		public function Reference(base:ESObject, propertyName:String, node:Node) {
			this.base = base;
			this.propertyName = propertyName;
			this.node = node;
		}
		
		public function toString() {
			return this.node.getSource();
		}
	}
}