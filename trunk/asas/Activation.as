//[TODO] ECMAScript 10.1.6
// should null prototype, unless we're relying on hasOwnProperty, in which case, nevermind

package asas {
	dynamic public class Activation {
		public function Activation(f, a) {
//[TODO] dontDelete on all properties & arguments!
			for (var i = 0, j = f.params.length; i < j; i++)
				this[f.params[i]] = a[i];
			this.arguments = a;
		}
	}
}