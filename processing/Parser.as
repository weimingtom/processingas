package processing {
	import processing.*;
	import asas.*;

	public class Parser {
		public function Parser():void {
		}
		
		public function evaluate(code:String, p:Processing):void {
			// parse code
			var pCode:String = parse(code);
			trace(pCode);
			
			// evaluate it
			ExecutionContext.global.setProperty('Processing', ESObject.wrap(p));
			Evaluator.evaluate('with (Processing) { ' + pCode + '}');
		}
		
		private function parse( aCode ):String
		{
			// Angels weep at this parsing code :-(
		
			// Remove end-of-line comments
			aCode = aCode.replace(/\/\/ .*\n/g, "\n");
		
			// Weird parsing errors with %
			aCode = aCode.replace(/([^\s])%([^\s])/g, "$1 % $2");
		 
			// Simple convert a function-like thing to function
			aCode = aCode.replace(/(?:static )?(\w+ )(\w+)\s*(\([^\)]*\)\s*{)/g, function(all, type, name, args)
			{
				if ( name == "if" || name == "for" || name == "while" )
				{
					return all;
				}
				else
				{
					return "Processing." + name + " = function " + name + args;
				}
			});
		
			// Force .length() to be .length
			aCode = aCode.replace(/\.length\(\)/g, ".length");
		
			// foo( int foo, float bar )
			aCode = aCode.replace(/([\(,]\s*)(\w+)((?:\[\])+| )\s*(\w+\s*[\),])/g, "$1$4");
			aCode = aCode.replace(/([\(,]\s*)(\w+)((?:\[\])+| )\s*(\w+\s*[\),])/g, "$1$4");
		
			// float[] foo = new float[5];
			aCode = aCode.replace(/new (\w+)((?:\[([^\]]*)\])+)/g, function(all, name, args)
			{
				return "new ArrayList(" + args.slice(1,-1).split("][").join(", ") + ")";
			});
			
			aCode = aCode.replace(/(?:static )?\w+\[\]\s*(\w+)\[?\]?\s*=\s*{.*?};/g, function(all)
			{
				return all.replace(/{/g, "[").replace(/}/g, "]");
			});
		
			// int|float foo;
			var intFloat = new RegExp('(\n\s*(?:int|float)(?:\[\])?(?:\s*|[^\(]*?,\s*))([a-z]\w*)(;|,)', 'i');
			while ( intFloat.test(aCode) )
			{
				aCode = aCode.replace(new RegExp(intFloat), function(all, type, name, sep)
				{
					return type + " " + name + " = 0" + sep;
				});
			}
		
			// float foo = 5;
			aCode = aCode.replace(/(?:static )?(\w+)((?:\[\])+| ) *(\w+)\[?\]?(\s*[=,;])/g, function(all, type, arr, name, sep)
			{
				if ( type == "return" )
					return all;
				else
					return "var " + name + sep;
			});
		
			// Fix Array[] foo = {...} to [...]
			aCode = aCode.replace(/=\s*{((.|\s)*?)};/g, function(all,data)
			{
				return "= [" + data.replace(/{/g, "[").replace(/}/g, "]") + "]";
			});
			
			// static { ... } blocks
			aCode = aCode.replace(/static\s*{((.|\n)*?)}/g, function(all, init)
			{
				// Convert the static definitons to variable assignments
				//return init.replace(/\((.*?)\)/g, " = $1");
				return init;
			});
		
			// super() is a reserved word
			aCode = aCode.replace(/super\(/g, "superMethod(");
		
			var classes = ["int", "float", "boolean", "string"];
		
			function ClassReplace(all, name, extend, vars, last)
			{
				classes.push( name );
		
				var static = "";
		
				vars = vars.replace(/final\s+var\s+(\w+\s*=\s*.*?;)/g, function(all,set)
				{
					static += " " + name + "." + set;
					return "";
				});
		
				// Move arguments up from constructor and wrap contents with
				// a with(this), and unwrap constructor
				return "function " + name + "() {with(this){\n	" +
					(extend ? "var __self=this;function superMethod(){extendClass(__self,arguments," + extend + ");}\n" : "") +
					// Replace var foo = 0; with this.foo = 0;
					// and force var foo; to become this.foo = null;
					vars
			.replace(/,\s?/g, ";\n	this.")
			.replace(/\b(var |final |public )+\s*/g, "this.")
			.replace(/this.(\w+);/g, "this.$1 = null;") + 
			(extend ? "extendClass(this, " + extend + ");\n" : "") +
			"<CLASS " + name + " " + static + ">" + (typeof last == "string" ? last : name + "(");
			}
		
			var matchClasses = new RegExp('?:public |abstract |static )*class (\w+)\s*(?:extends\s*(\w+)\s*)?{\s*((?:.|\n)*?)\b\1\s*\(', 'g');
			var matchNoCon = new RegExp('(?:public |abstract |static )*class (\w+)\s*(?:extends\s*(\w+)\s*)?{\s*((?:.|\n)*?)(Processing)', 'g');
			
			aCode = aCode.replace(matchClasses, ClassReplace);
			aCode = aCode.replace(matchNoCon, ClassReplace);
		
			var matchClass = new RegExp('<CLASS (\w+) (.*?)>'), m;
			
			while ( (m = aCode.match( matchClass )) )
			{
				var left = aCode.substr(0, matchClass.lastIndex),
					allRest = aCode.substr(matchClass.lastIndex),
					rest = nextBrace(allRest),
					className = m[1],
					staticVars = m[2] || "";
					
				allRest = allRest.slice( rest.length + 1 );
		
				rest = rest.replace(new RegExp("\\b" + className + "\\(([^\\)]*?)\\)\\s*{", "g"), function(all, args)
				{
					args = args.split(/,\s*?/);
					
					if ( args[0].match(/^\s*$/) )
			args.shift();
					
					var fn = "if ( arguments.length == " + args.length + " ) {\n";
			
					for ( var i = 0; i < args.length; i++ )
					{
			fn += "		var " + args[i] + " = arguments[" + i + "];\n";
					}
			
					return fn;
				});
				
				// Fix class method names
				// this.collide = function() { ... }
				// and add closing } for with(this) ...
				rest = rest.replace(/(?:public )?Processing.\w+ = function (\w+)\((.*?)\)/g, function(all, name, args)
				{
					return "ADDMETHOD(this, '" + name + "', function(" + args + ")";
				});
				
				var matchMethod = new RegExp('ADDMETHOD([\s\S]*?{)'), mc;
				var methods = "";
				
				while ( (mc = rest.match( matchMethod )) )
				{
					var prev = rest.substr(0, matchMethod.lastIndex),
			allNext = rest.substr(matchMethod.lastIndex),
			next = nextBrace(allNext);
		
					methods += "addMethod" + mc[1] + next + "});"
					
					rest = prev + allNext.slice( next.length + 1 );
					
				}
		
				rest = methods + rest;
				
				aCode = left + rest + "\n}}" + staticVars + allRest;
			}
		
			// Do some tidying up, where necessary
			aCode = aCode.replace(/Processing.\w+ = function addMethod/g, "addMethod");
			
			function nextBrace( right )
			{
				var rest = right;
				var position = 0;
				var leftCount = 1, rightCount = 0;
				
				while ( leftCount != rightCount )
				{
					var nextLeft = rest.indexOf("{");
					var nextRight = rest.indexOf("}");
					
					if ( nextLeft < nextRight && nextLeft != -1 )
					{
			leftCount++;
			rest = rest.slice( nextLeft + 1 );
			position += nextLeft + 1;
					}
					else
					{
			rightCount++;
			rest = rest.slice( nextRight + 1 );
			position += nextRight + 1;
					}
				}
				
				return right.slice(0, position - 1);
			}
		
			// Handle (int) Casting
			aCode = aCode.replace(/\(int\)/g, "0|");
		
			// Remove Casting
			aCode = aCode.replace(new RegExp("\\((" + classes.join("|") + ")(\\[\\])?\\)", "g"), "");
			
			// Convert 3.0f to just 3.0
			aCode = aCode.replace(/(\d+)f/g, "$1");
		
			// Force numbers to exist
			//aCode = aCode.replace(/([^.])(\w+)\s*\+=/g, "$1$2 = ($2||0) +");
		
			// Force characters-as-bytes to work
			aCode = aCode.replace(/('[a-zA-Z0-9]')/g, "$1.charCodeAt(0)");
		
			// Convert #aaaaaa into color
			aCode = aCode.replace(/#([a-f0-9]{6})/ig, function(m, hex){
				var num = toNumbers(hex);
				return "color(" + num[0] + "," + num[1] + "," + num[2] + ")";
			});
		
			function toNumbers( str ){
				var ret = [];
				 str.replace(/(..)/g, function(str){
					ret.push( parseInt( str, 16 ) );
				});
				return ret;
			}
		
			return aCode;
		}
	}
}