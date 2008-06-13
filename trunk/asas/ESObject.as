/*[todo] associate ES relection cache with Contexts
mutable property, option to make settings permanent or local?
ES basic classes should be according to spec; other classes, not so much
class prototype property should be readwrite, for instance

native ES objects can be almost directly wrapped
declare functions with AS3 namespace to make them hidden from ES
*/

package asas {
	import flash.utils.describeType;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	public class ESObject {
		// constructor		
		public function ESObject(obj:Object, isMutable:Boolean = true, isLocallyMutable:Boolean = true) {
			// save the properties
			this.obj = obj;
			this.wrappedObj = obj;
			_isMutable = isMutable;
			_isLocallyMutable = isLocallyMutable;
			
			// convert classes to objects
			if (obj is Class) {
				// initialize object
				this.obj = function () {};

				// load static properties
				for (var prop in obj)
					this.obj[prop] = obj[prop];
				// class properties
				var type:XML = describeType(obj) as XML;
				for each (var node:XML in (type.constant + type.method + type.variable + type.accessor.(@access).(@access.indexOf('read') > -1))) {
					try {
						// set the property
						this.obj[node.@name] = obj[node.@name];
						readOnly[node.@name] = node.@access == 'readonly' || node.localName() == 'constant';
						dontDelete[node.@name] = node.localName() == 'accessor' || node.localName() == 'constant';
					} catch (e) {
						// potential write to read-only property; ignore
					}
				}
			}
		}

		// internal properties
		private var obj:*;
		private var wrappedObj:*;
		private var _constructor:ESObject;

		// property getters
		public function get constructor():ESObject {
			// if there is no constructor, return a wrapped class
			if (!_constructor) {
				// get the class reference (trimming off -* from anonymous functions)
				var className:String = getQualifiedClassName(obj).replace(/-[0-9]+$/, '');
				_constructor = ESObject.wrap(getDefinitionByName(className) as Class);
			}
			return _constructor;
		}

		public function get prototype():ESObject {
			// get the prototype of this object (or best guess, Object prototype)
			var proto:ESObject = constructor.getProperty('prototype');
			return proto && proto.valueOf().isPrototypeOf(obj) ? proto :
			    Object.prototype.isPrototypeOf(obj) ? ESObject.wrap(Object.prototype) :
			    null;
		}

		// mutability properties
		private var _isLocallyMutable:Boolean = true;
		private var _isMutable:Boolean = true;
		
		public function get isMutable():Boolean {
			return _isMutable;
		}

		public function get isLocallyMutable():Boolean {
			return _isLocallyMutable;
		}

		//=============================================================
		// properties
		//=============================================================

		// local properties array
		private var properties:Dictionary = new Dictionary();
		private var readOnly:Dictionary = new Dictionary();
		private var dontDelete:Dictionary = new Dictionary();
		
		private const DELETED_PROP:Object = new Object();

		public function getProperty(name:String):ESObject {
			// get property from local array
			if (properties.hasOwnProperty(name))
				return properties[name] === DELETED_PROP ? undefined :
				    ESObject.wrap(properties[name], isMutable, isLocallyMutable);
	
			// get property from object or prototype
			return obj.hasOwnProperty(name) ?
			    ESObject.wrap(obj[name], isMutable, isLocallyMutable) :
			    (prototype ? prototype.getProperty(name) : undefined);
		}

		public function setProperty(name:String, value:ESObject, dontDelete:Boolean = false, readOnly:Boolean = false, dontEnum:Boolean = false):Boolean {
			// check if the property can be set
			if (!canSetProperty(name))
				return false;

			// set object property
			var setLocal:Boolean = !isMutable && isLocallyMutable;
			if (isMutable)
				try {
					obj[name] = value.valueOf();
					obj.setPropertyIsEnumerable(name, !dontEnum);
				} catch (e:ReferenceError) {
					if (!isLocallyMutable)
						throw e;
					else
						setLocal = true;
				}
			// set local property
			if (setLocal) {
				properties[name] = value.valueOf();
				properties.setPropertyIsEnumerable(name, !dontEnum);
			}
			
			// set flags
			this.readOnly[name] = readOnly;
			this.dontDelete[name] = dontDelete;
			
			return true;
		}

		public function canSetProperty(name:String):Boolean {
			// check if property is read-only
			if (readOnly.hasOwnProperty(name))
				return !readOnly[name];
			// check prototype
			return !prototype || prototype.canSetProperty(name);
		}

		public function deleteProperty(name:String):Boolean {
			// check if the dontDelete flag is set
			if (dontDelete.hasOwnProperty(name) && dontDelete[name])
				return false;

			// delete the property and flags
			if (!(isMutable && delete obj[name]) && !isLocallyMutable)
				return false;
			else if (!isMutable && isLocallyMutable)
				properties[name] = DELETED_PROP;
			delete dontDelete[name];
			delete readOnly[name];
			return true;
		}

		public function hasOwnProperty(name:String):Boolean {
			// return if this object has the specified property
			return properties[name] !== DELETED_PROP &&
			    (properties.hasOwnProperty(name) ||
			    obj.hasOwnProperty(name));
		}

		public function hasProperty(name:String):Boolean {
			// return if this object or its prototype the specified property
			return hasOwnProperty(name) ||
			    (prototype && prototype.hasProperty(name));
		}

		public function callProperty(name:String, ... args):ESObject {
			// get property from array or prototype
			var prop:ESObject = getProperty(name);
			if (prop && (typeof prop.valueOf() == 'function'))
				return prop.call.apply(this, args);
			throw new EvalError(name + ' is not a function.');
		}

		public function getProperties():Dictionary {
			// get an array of properties
			var propArray:Dictionary = new Dictionary();
			// load from properties array
			for (var prop:* in properties)
				if (prop is String)
					propArray[prop] = getProperty(prop);
			// load from object
			for (var prop:* in obj)
				if (prop is String)
					propArray[prop] = getProperty(prop);
			return propArray;
		}

		//=============================================================
		// functions
		//=============================================================

		public function toString():String {
			return String(wrappedObj);
		}
		
		public function valueOf():* {
			return wrappedObj;
		}

		public function hasInstance(value:ESObject):Boolean {
			// get the value class
			return value.constructor === this;
		}

		public function call(... args):ESObject {
			// check that this is callable
//[TODO] call on RegExps?
			if (!(wrappedObj is Function || wrappedObj is Class))
				throw new TypeError(toString() + ' is not a function.');

			// unwrap arguments
			for (var i:int = 0; i < args.length; i++)
				args[i] = args[i].valueOf();
			// call the function
			return ESObject.wrap(wrappedObj.apply(this.valueOf(), args));
		}

		public function construct(... args):* {
			// check that this is callable
			if (!(wrappedObj is Function || wrappedObj is Class))
				throw new TypeError(toString() + ' is not a constructor.');

			// unwrap arguments
			for (var i:int = 0; i < args.length; i++)
				args[i] = args[i].valueOf();
			// call the constructor
			//[HACK] can't call constructor with array of arguments, ever :[
			switch (args.length) {
				case 0: return ESObject.wrap(new wrappedObj());
				case 1: return ESObject.wrap(new wrappedObj(args[0]));
				case 2: return ESObject.wrap(new wrappedObj(args[0], args[1]));
				case 3: return ESObject.wrap(new wrappedObj(args[0], args[1], args[2]));
				case 4: return ESObject.wrap(new wrappedObj(args[0], args[1], args[2], args[3]));
				case 5: return ESObject.wrap(new wrappedObj(args[0], args[1], args[2], args[3], args[4]));
				case 6: return ESObject.wrap(new wrappedObj(args[0], args[1], args[2], args[3], args[4], args[5]));
				case 7: return ESObject.wrap(new wrappedObj(args[0], args[1], args[2], args[3], args[4], args[5], args[6]));
				case 8: return ESObject.wrap(new wrappedObj(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7]));
				case 9: return ESObject.wrap(new wrappedObj(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8]));
				default: throw new Error('Constructor called with too many arguments.');
			};
		}
		
		//=============================================================
		// wrappers
		//=============================================================
		
		public static var wrapped:Dictionary = new Dictionary(true);
		
		public static function wrap(obj:*, isMutable:Boolean = true, isLocallyMutable:Boolean = true):* {
			// check if this object has already been wrapped
			if (ESObject.wrapped[obj] !== undefined)
				return ESObject.wrapped[obj];
			// don't wrap ESObjects!
	//[TODO] DO wrap esobjects, cause this should never happen!
			if (obj is ESObject)
				return obj;

			// wrap and cache the object
			var newObj:ESObject = new ESObject(obj, isMutable, isLocallyMutable);
			ESObject.wrapped[obj] = newObj;
			return newObj;
		}
	}
}