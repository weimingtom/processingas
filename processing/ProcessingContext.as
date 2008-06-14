package processing {
	import com.gamemeal.html.Canvas;
	import com.gamemeal.graphics.ImageData;
	import processing.Processing;
	import processing.AniSprite;
	import processing.ArrayList;
	import processing.Point;
	import processing.Random;
	import flash.utils.setInterval;
	import flash.utils.clearInterval;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import asas.*;

	dynamic public class ProcessingContext {
		// processing object
		private var pObj:Processing;
		
		// public reference
		public function get processing() { return pObj; }
		public function get canvas() { return pObj.canvas; }
	
		// init
		public const PI = Math.PI;
		public const TWO_PI = Math.PI * 2;
		public const HALF_PI = Math.PI / 2;
		public const P3D = 3;
		public const CORNER = 0;
		public const CENTER = 1;
		public const CENTER_RADIUS = 2;
		public const RADIUS = 2;
		public const POLYGON = 1;
		public const TRIANGLES = 6;
		public const POINTS = 7;
		public const LINES = 8;
		public const TRIANGLE_STRIP = 9;
		public const CORNERS = 10;
		public const CLOSE = true;
		public const RGB = 1;
		public const HSB = 2;
		
		// private state variables
		private var curContext:Canvas;
		private var doFill:Boolean = true;
		private var doStroke:Boolean = true;
		private var loopStarted:Boolean = false;
		private var hasBackground:Boolean = false;
		private var doLoop:Boolean = true;
		private var curRectMode:Number = CORNER;
		private var curEllipseMode:Number = CENTER;
		private var inSetup:Boolean = false;
		private var inDraw:Boolean = false;
		private var curBackground:String = 'rgba(204,204,204,1)';
		private var curFrameRate:Number = 1000;
		private var curShape:Number = POLYGON;
		private var curShapeCount:Number = 0;
		private var opacityRange:Number = 255;
		private var redRange:Number = 255;
		private var greenRange:Number = 255;
		private var blueRange:Number = 255;
		private var pathOpen:Boolean = false;
		private var mousePressed:Boolean = false;
		private var keyPressed:Boolean = false;
		private var firstX:Number;
		private var firstY:Number;
		private var prevX:Number;
		private var prevY:Number;
		private var curColorMode:Number = RGB;
		private var curTint:Number = -1;
		private var curTextSize:Number = 12;
		private var curTextFont:String = 'Arial';
		private var getLoaded;
		private var start:Number;
		private var pixels:Array = [];
		
		// mouse position vars
//[TODO] read-only these?
		public var pmouseX:Number = 0;
		public var pmouseY:Number = 0;
		public var mouseX:Number = 0;
		public var mouseY:Number = 0;
		
		// user-replacable functions
		public var mouseDragged:Function = undefined;
		public var mouseMoved:Function = undefined;
//?		public var mousePressed:Function = undefined;
		public var mouseReleased:Function = undefined;
//?		public var keyPressed:Function = undefined;
		public var keyReleased:Function = undefined;
		public var draw:Function = undefined;
		public var setup:Function = undefined;
		
		// canvas width/height
		public function get width():Number { return pObj.canvas.width; }
		public function get height():Number { return pObj.canvas.height; }
		
		// constructor
		public function ProcessingContext(_pObj:Processing):void {
			// save processing object
			pObj = _pObj;
		
			// initialize state variables
			curContext = pObj.canvas.getContext('2d');
			start = (new Date).getTime();

/*
//******************************************************************************

var document = {
	createElement: function (name) {
		if (name == 'canvas')
			return new Canvas('canvas' + Math.random(), 1000, 1000);
	},
	getElementById: function (id) {
		//[TODO] uh
	},
	addEventListener: function (name, func, bubble) {
		//[TODO] uh
	}
};

var window = {
	location: '' //[TODO] uh
};

// changes: fixed RegExp.leftContext, .rightContext
// wrapped some regex's (that Flash no like for some reason)
// fixed log() function
// removed redundant labels from set, get, init, and color functions (compiler errors)

//******************************************************************************


	var p:ProcessingContext = this;
	
	var curElement:Canvas = pObj.canvas; */
		}
		
		// color conversion
		public function color(... args):String {
			// in case of HSV conversion:
			// http://srufaculty.sru.edu/david.dailey/javascript/js/5rml.js
			
			var aColor = '';
			
			// function overrides
			if (args.length == 3)
			{
				aColor = color(args[0], args[1], args[2], opacityRange );
			}
			else if (args.length == 4)
			{
				var a = args[3] / opacityRange;
				a = isNaN(a) ? 1 : a;
			
				if (curColorMode == HSB) {
					var rgb = HSBtoRGB(args[0], args[1], args[2]);
					var r = rgb[0], g = rgb[1], b = rgb[2];
				} else {
					var r = getColor(args[0], redRange);
					var g = getColor(args[1], greenRange);
					var b = getColor(args[2], blueRange);
				}
			
				aColor = "rgba(" + r + "," + g + "," + b + "," + a + ")";
			}
			else if ( typeof args[0] == "string" )
			{
				aColor = args[0];
			
				if (args.length == 2)
				{
					var c = aColor.split(",");
					c[3] = (args[1] / opacityRange) + ")";
					aColor = c.join(",");
				}
			}
			else if (args.length == 2)
			{
				aColor = color( args[0], args[0], args[0], args[1] );
			}
			else if (typeof args[0] == "number")
			{
				aColor = color( args[0], args[0], args[0], opacityRange );
			}
			else
			{
				aColor = color( redRange, greenRange, blueRange, opacityRange );
			}
			
			return aColor;
		}
		
		// HSB conversion function from Mootools, MIT Licensed
		private function HSBtoRGB(h, s, b):Array {
			h = (h / redRange) * 100;
			s = (s / greenRange) * 100;
			b = (b / blueRange) * 100;
			if (s != 0) {
				var hue = h % 360;
				var f = hue % 60;
				var br = Math.round(b / 100 * 255);
				var p = Math.round((b * (100 - s)) / 10000 * 255);
				var q = Math.round((b * (6000 - s * f)) / 600000 * 255);
				var t = Math.round((b * (6000 - s * (60 - f))) / 600000 * 255);
				switch (Math.floor(hue / 60)){
					case 0: return [br, t, p];
					case 1: return [q, br, p];
					case 2: return [p, br, t];
					case 3: return [p, q, br];
					case 4: return [t, p, br];
					case 5: return [br, p, q];
				}
			}
			return [b, b, b]
		}
			
		private function getColor( aValue, range ):Number {
			return Math.round(255 * (aValue / range));
		}
		
		// AniSprite class
		public var AniSprite:Class = AniSprite;
		
		public function createImage( w, h, mode = null ):Object
		{
			var data:Object = {
				width: w,
				height: h,
				pixels: new Array( w * h ),
				get: function(x,y)
				{
					return this.pixels[w*y+x];
				},
				_mask: null,
				mask: function(img)
				{
					this._mask = img;
				},
				loadPixels: function()
				{
				},
				updatePixels: function()
				{
				}
			};
			
			return data;
		}
		
		public function createGraphics( w, h ):ProcessingContext
		{
			var pObj:Processing = new Processing();
			var ret:ProcessingContext = pObj.context;
			ret.size( w, h );
			return ret;
		}
		
		public function beginDraw()
		{
			//[TODO] uh
		}

		public function endDraw()
		{
			//[TODO] uh
		}

		public function tint( rgb:Number, a:Number ):void
		{
			//[TODO] rgb?
			curTint = a;
		}
		
		//[TODO] this should be private; see AniSprite
		//[TODO] also, this function needs much work
		private function getImage( img ) {
			if ( typeof img == "string" )
			{
				//[TODO] load image from path
			}
			
			if ( img.img || img.canvas )
			{
				return img.img || img.canvas;
			}
			
			// convert pixel color array to ImageData, i guess
			
			img.data = [];
			
			for ( var i = 0, l = img.pixels.length; i < l; i++ )
			{
				var c = (img.pixels[i] || "rgba(0,0,0,1)").slice(5,-1).split(",");
				img.data.push( parseInt(c[0]), parseInt(c[1]), parseInt(c[2]), parseFloat(c[3]) * 100 );
			}
			
			var canvas:Canvas = new Canvas('canvas' + Math.random(), img.width, img.height);
			canvas.getContext('2d').putImageData( img, 0, 0 );
			
			img.canvas = canvas;
			
			return canvas;
		}
			
		public function image( img, x, y, w = null, h = null )
		{
			x = x || 0;
			y = y || 0;
	
			var obj = getImage(img);
	
			if ( curTint >= 0 )
			{
				var oldAlpha = curContext.globalAlpha;
				curContext.globalAlpha = curTint / opacityRange;
			}
	
			if ( arguments.length == 3 )
			{
				curContext.drawImage( obj, x, y );
			}
			else
			{
				curContext.drawImage( obj, x, y, w, h );
			}
	
			if ( curTint >= 0 )
			{
				curContext.globalAlpha = oldAlpha;
			}
	
			if ( img._mask )
			{
				var oldComposite = curContext.globalCompositeOperation;
				curContext.globalCompositeOperation = "darker";
				image( img._mask, x, y );
				curContext.globalCompositeOperation = oldComposite;
			}
		}
	
		public function exit()
		{
	
		}
	
		public function save( file )
		{
	
		}
	
		public function loadImage( file )
		{
			//[TODO] this
			/*
			var img = document.getElementById(file);
			if ( !img )
				return;
	
			var h = img.height, w = img.width;
	
			var canvas = document.createElement("canvas");
			canvas.width = w;
			canvas.height = h;
			var context = canvas.getContext("2d");
	
			context.drawImage( img, 0, 0 );
			var data = buildImageObject( context.getImageData( 0, 0, w, h ) );
			data.img = img;
			return data;*/
			return;
		}
		
		// text
//[TODO] this
		
		public function loadFont( name )
		{
			return {
				name: name,
				width: function( str )
				{
/*					if ( curContext.mozMeasureText )
						return curContext.mozMeasureText( typeof str == "number" ?
							String.fromCharCode( str ) :
							str) / curTextSize;
		else*/
			return 0;
				}
			};
		}
	
		public function textFont( name, size )
		{
			curTextFont = name;
			textSize( size );
		}
	
		public function textSize( size )
		{
			if ( size )
			{
				curTextSize = size;
			}
		}
	
		public function textAlign()
		{
	
		}
	
		public function text( str, x, y )
		{
/*			if ( str && curContext.mozDrawText )
			{
				curContext.save();
				curContext.mozTextStyle = curTextSize + "px " + curTextFont.name;
				curContext.translate(x, y);
				curContext.mozDrawText( typeof str == "number" ?
					String.fromCharCode( str ) :
		str );
				curContext.restore();
			}*/
		}
	
		public function char( key )
		{
			//return String.fromCharCode( key );
			return key;
		}
	
		public function println()
		{
	
		}
	
		public function map( value, istart, istop, ostart, ostop )
		{
			return ostart + (ostop - ostart) * ((value - istart) / (istop - istart));
		}
		
		public function colorMode( mode, range1, range2, range3, range4 )
		{
			curColorMode = mode;
	
			if ( arguments.length >= 4 )
			{
				redRange = range1;
				greenRange = range2;
				blueRange = range3;
			}
	
			if ( arguments.length == 5 )
			{
				opacityRange = range4;
			}
	
			if ( arguments.length == 2 )
			{
				colorMode( mode, range1, range1, range1, range1 );
			}
		}
		
		public function beginShape( type = POLYGON )
		{
			curShape = type;
			curShapeCount = 0; 
		}
		
		public function endShape( close = true )
		{
			if ( curShapeCount != 0 )
			{
				curContext.lineTo( firstX, firstY );
	
				if ( doFill )
					curContext.fill();
					
				if ( doStroke )
					curContext.stroke();
			
				curContext.closePath();
				curShapeCount = 0;
				pathOpen = false;
			}
	
			if ( pathOpen )
			{
				curContext.closePath();
			}
		}
		
		public function vertex( x, y, x2 = null, y2 = null, x3 = null, y3 = null )
		{
			if ( curShapeCount == 0 && curShape != POINTS )
			{
				pathOpen = true;
				curContext.beginPath();
				curContext.moveTo( x, y );
			}
			else
			{
				if ( curShape == POINTS )
				{
					point( x, y );
				}
				else if ( arguments.length == 2 )
				{
					if ( curShape == TRIANGLE_STRIP && curShapeCount == 2 )
					{
						curContext.moveTo( prevX, prevY );
						curContext.lineTo( firstX, firstY );
					}
	
					curContext.lineTo( x, y );
				}
				else if ( arguments.length == 4 )
				{
					if ( curShapeCount > 1 )
					{
			curContext.moveTo( prevX, prevY );
						curContext.quadraticCurveTo( firstX, firstY, x, y );
			curShapeCount = 1;
					}
				}
				else if ( arguments.length == 6 )
				{
					curContext.bezierCurveTo( x, y, x2, y2, x3, y3 );
					curShapeCount = -1;
				}
			}
	
			prevX = firstX;
			prevY = firstY;
			firstX = x;
			firstY = y;
	
			
			curShapeCount++;
			
			if ( curShape == LINES && curShapeCount == 2 ||
					 (curShape == TRIANGLES || curShape == TRIANGLE_STRIP) && curShapeCount == 3 )
			{
				endShape();
			}
	
			if ( curShape == TRIANGLE_STRIP && curShapeCount == 3 )
			{
				curShapeCount = 2;
			}
		}
	
		public function curveTightness()
		{
	
		}
	
		// [TODO] Unimplmented - not really possible with the Canvas API
		public function curveVertex( x, y, x2, y2 )
		{
			vertex( x, y, x2, y2 );
		}
	
		public function bezierVertex(x, y, x2, y2, x3, y3 ) {
			return vertex(x, y, x2, y2, x3, y3 );
		}
		
		public function rectMode( aRectMode )
		{
			curRectMode = aRectMode;
		}
	
		public function imageMode()
		{
	
		}
		
		public function ellipseMode( aEllipseMode )
		{
			curEllipseMode = aEllipseMode;
		}
		
		public function dist( x1, y1, x2, y2 )
		{
			return Math.sqrt( Math.pow( x2 - x1, 2 ) + Math.pow( y2 - y1, 2 ) );
		}
	
		public function year()
		{
			return (new Date).getYear() + 1900;
		}
	
		public function month()
		{
			return (new Date).getMonth();
		}
	
		public function day()
		{
			return (new Date).getDay();
		}
	
		public function hour()
		{
			return (new Date).getHours();
		}
	
		public function minute()
		{
			return (new Date).getMinutes();
		}
	
		public function second()
		{
			return (new Date).getSeconds();
		}
	
		public function millis()
		{
			return (new Date).getTime() - start;
		}
		
		public function ortho()
		{
		
		}
		
		public function translate( x, y )
		{
			curContext.translate( x, y );
		}
		
		public function scale( x, y )
		{
			curContext.scale( x, y || x );
		}
		
		public function rotate( aAngle )
		{
			curContext.rotate( aAngle );
		}
		
		public function pushMatrix()
		{
			curContext.save();
		}
		
		public function popMatrix()
		{
			curContext.restore();
		}
		
		public function redraw()
		{
			if ( hasBackground )
			{
				background();
			}
			
			inDraw = true;
			pushMatrix();
			draw();
			popMatrix();
			inDraw = false;
		}
		
		public function loop()
		{
			if ( loopStarted )
				return;
			
			var looping = setInterval(function()
			{
				try
				{
					redraw();
				}
				catch(e)
				{
					clearInterval( looping );
					throw e;
				}
			}, 1000 / curFrameRate );
			
			loopStarted = true;
		}
		
		public function frameRate( aRate )
		{
	//[TODO] set stage frame rate
			curFrameRate = aRate;
		}
		
		public function background( img = null )
		{
	
			if ( arguments.length )
			{
				if ( img && img.hasOwnProperty('img') )
				{
					curBackground = img;
				}
				else
				{
					curBackground = color.apply( this, arguments );
				}
			}
			
	
			if ( curBackground.hasOwnProperty('img') )
			{
				image( curBackground, 0, 0 );
			}
			else
			{
				var oldFill = curContext.fillStyle;
				curContext.fillStyle = curBackground + "";
				curContext.fillRect( 0, 0, width, height );
				curContext.fillStyle = oldFill;
			}
		}
	
		public function sq( aNumber )
		{
			return aNumber * aNumber;
		}
	
		public function sqrt( aNumber )
		{
			return Math.sqrt( aNumber );
		}
		
		public function int( aNumber )
		{
			return Math.floor( aNumber );
		}
	
		public function min( aNumber, aNumber2 )
		{
			return Math.min( aNumber, aNumber2 );
		}
	
		public function max( aNumber, aNumber2 )
		{
			return Math.max( aNumber, aNumber2 );
		}
	
		public function ceil( aNumber )
		{
			return Math.ceil( aNumber );
		}
	
		public function floor( aNumber )
		{
			return Math.floor( aNumber );
		}
	
		public function float( aNumber )
		{
			return typeof aNumber == "string" ?
		float( aNumber.charCodeAt(0) ) :
					parseFloat( aNumber );
		}
	
		public function byte( aNumber )
		{
			return aNumber || 0;
		}
		
		public function random( aMin, aMax )
		{
			return arguments.length == 2 ?
				aMin + (Math.random() * (aMax - aMin)) :
				Math.random() * aMin;
		}
	
		// From: http://freespace.virgin.net/hugo.elias/models/m_perlin.htm
		public function noise( x, y, z )
		{
			return arguments.length >= 2 ?
				PerlinNoise_2D( x, y ) :
				PerlinNoise_2D( x, x );
		}
	
		private function Noise(x, y)
		{
			var n = x + y * 57;
			n = (n<<13) ^ n;
			return Math.abs(1.0 - (((n * ((n * n * 15731) + 789221) + 1376312589) & 0x7fffffff) / 1073741824.0));
		}
	
		private function SmoothedNoise(x, y)
		{
			var corners = ( Noise(x-1, y-1)+Noise(x+1, y-1)+Noise(x-1, y+1)+Noise(x+1, y+1) ) / 16;
			var sides	 = ( Noise(x-1, y)	+Noise(x+1, y)	+Noise(x, y-1)	+Noise(x, y+1) ) /	8;
			var center	=	Noise(x, y) / 4;
			return corners + sides + center;
		}
	
		private function InterpolatedNoise(x, y)
		{
			var integer_X		= Math.floor(x);
			var fractional_X = x - integer_X;
	
			var integer_Y		= Math.floor(y);
			var fractional_Y = y - integer_Y;
	
			var v1 = SmoothedNoise(integer_X,		 integer_Y);
			var v2 = SmoothedNoise(integer_X + 1, integer_Y);
			var v3 = SmoothedNoise(integer_X,		 integer_Y + 1);
			var v4 = SmoothedNoise(integer_X + 1, integer_Y + 1);
	
			var i1 = Interpolate(v1 , v2 , fractional_X);
			var i2 = Interpolate(v3 , v4 , fractional_X);
	
			return Interpolate(i1 , i2 , fractional_Y);
		}
	
		private function PerlinNoise_2D(x, y)
		{
				var total = 0;
				var p = 0.25;
				var n = 3;
	
				for ( var i = 0; i <= n; i++ )
				{
						var frequency = Math.pow(2, i);
						var amplitude = Math.pow(p, i);
	
						total = total + InterpolatedNoise(x * frequency, y * frequency) * amplitude;
				}
	
				return total;
		}
	
		private function Interpolate(a, b, x)
		{
			var ft = x * PI;
			var f = (1 - cos(ft)) * .5;
			return	a*(1-f) + b*f;
		}
	
		public function red( aColor )
		{
			return parseInt(aColor.slice(5));
		}
	
		public function green( aColor )
		{
			return parseInt(aColor.split(",")[1]);
		}
	
		public function blue( aColor )
		{
			return parseInt(aColor.split(",")[2]);
		}
	
		public function alpha( aColor )
		{
			return parseInt(aColor.split(",")[3]);
		}
	
		public function abs( aNumber )
		{
			return Math.abs( aNumber );
		}
		
		public function cos( aNumber )
		{
			return Math.cos( aNumber );
		}
		
		public function sin( aNumber )
		{
			return Math.sin( aNumber );
		}
		
		public function pow( aNumber, aExponent )
		{
			return Math.pow( aNumber, aExponent );
		}
		
		public function constrain( aNumber, aMin, aMax )
		{
			return Math.min( Math.max( aNumber, aMin ), aMax );
		}
		
		public function atan2( aNumber, aNumber2 )
		{
			return Math.atan2( aNumber, aNumber2 );
		}
		
		public function radians( aAngle )
		{
			return ( aAngle / 180 ) * PI;
		}
		
		public function size( aWidth, aHeight )
		{
			var fillStyle = curContext.fillStyle;
			var strokeStyle = curContext.strokeStyle;
	
	//[TODO] does the Canvas object actually work this way?
			canvas.width = aWidth;
			canvas.height = aHeight;
	
			curContext.fillStyle = fillStyle;
			curContext.strokeStyle = strokeStyle;
		}
		
		public function noStroke()
		{
			doStroke = false;
		}
		
		public function noFill()
		{
			doFill = false;
		}
		
		public function smooth()
		{
		
		}
		
		public function noLoop()
		{
			doLoop = false;
		}
		
		public function fill( type = null)
		{
			doFill = true;
			curContext.fillStyle = color.apply( this, arguments );
		}
		
		public function stroke( type = null )
		{
			doStroke = true;
			curContext.strokeStyle = color.apply( this, arguments );
		}
	
		public function strokeWeight( w )
		{
			curContext.lineWidth = w;
		}
		
		public function point( x, y )
		{
			var oldFill = curContext.fillStyle;
			curContext.fillStyle = curContext.strokeStyle;
			curContext.fillRect( Math.round( x ), Math.round( y ), 1, 1 );
			curContext.fillStyle = oldFill;
		}
	
		public function get( x, y )
		{
			if ( arguments.length == 0 )
			{
				var c = createGraphics( width, height );
				c.image( curContext, 0, 0 );
				return c;
			}
	
			if ( !getLoaded )
			{
				getLoaded = buildImageObject( curContext.getImageData(0, 0, width, height) );
			}
	
			return getLoaded.get( x, y );
		}
	
		public function set( x, y, color )
		{
			var oldFill = curContext.fillStyle;
			curContext.fillStyle = color;
			curContext.fillRect( Math.round( x ), Math.round( y ), 1, 1 );
			curContext.fillStyle = oldFill;
		}
		
		public function arc( x, y, width, height, start, stop )
		{
			if ( width <= 0 )
				return;
	
			if ( curEllipseMode == CORNER )
			{
				x += width / 2;
				y += height / 2;
			}
	
			curContext.beginPath();
		
			curContext.moveTo( x, y );
			curContext.arc( x, y, curEllipseMode == CENTER_RADIUS ? width : width/2, start, stop, false );
			
			if ( doFill )
				curContext.fill();
				
			if ( doStroke )
				curContext.stroke();
			
			curContext.closePath();
		}
		
		public function line( x1, y1, x2, y2 )
		{
			curContext.lineCap = "round";
			curContext.beginPath();
		
			curContext.moveTo( x1 || 0, y1 || 0 );
			curContext.lineTo( x2 || 0, y2 || 0 );
			
			curContext.stroke();
			
			curContext.closePath();
		}
	
		public function bezier( x1, y1, x2, y2, x3, y3, x4, y4 )
		{
			curContext.lineCap = "butt";
			curContext.beginPath();
		
			curContext.moveTo( x1, y1 );
			curContext.bezierCurveTo( x2, y2, x3, y3, x4, y4 );
			
			curContext.stroke();
			
			curContext.closePath();
		}
	
		public function triangle( x1, y1, x2, y2, x3, y3 )
		{
			beginShape();
			vertex( x1, y1 );
			vertex( x2, y2 );
			vertex( x3, y3 );
			endShape();
		}
	
		public function quad( x1, y1, x2, y2, x3, y3, x4, y4 )
		{
			beginShape();
			vertex( x1, y1 );
			vertex( x2, y2 );
			vertex( x3, y3 );
			vertex( x4, y4 );
			endShape();
		}
		
		public function rect( x, y, width, height )
		{
			if ( width == 0 && height == 0 )
				return;
	
			curContext.beginPath();
			
			var offsetStart = 0;
			var offsetEnd = 0;
	
			if ( curRectMode == CORNERS )
			{
				width -= x;
				height -= y;
			}
			
			if ( curRectMode == RADIUS )
			{
				width *= 2;
				height *= 2;
			}
			
			if ( curRectMode == CENTER || curRectMode == RADIUS )
			{
				x -= width / 2;
				y -= height / 2;
			}
		
			curContext.rect(
				Math.round( x ) - offsetStart,
				Math.round( y ) - offsetStart,
				Math.round( width ) + offsetEnd,
				Math.round( height ) + offsetEnd
			);
				
			if ( doFill )
				curContext.fill();
				
			if ( doStroke )
				curContext.stroke();
			
			curContext.closePath();
		}
		
		public function ellipse( x, y, width, height )
		{
			x = x || 0;
			y = y || 0;
	
			if ( width <= 0 && height <= 0 )
				return;
	
			curContext.beginPath();
			
			if ( curEllipseMode == RADIUS )
			{
				width *= 2;
				height *= 2;
			}
			
			var offsetStart = 0;
			
			// Shortcut for drawing a circle
			if ( width == height )
				curContext.arc( x - offsetStart, y - offsetStart, width / 2, 0, Math.PI * 2, false );
		
			if ( doFill )
				curContext.fill();
				
			if ( doStroke )
				curContext.stroke();
			
			curContext.closePath();
		}

		public function link( href:String, target ):void
		{
			var request:URLRequest;
			request = new URLRequest(href);
			navigateToURL(request);
		}
	
		public function loadPixels()
		{
			pixels = buildImageObject( curContext.getImageData(0, 0, width, height) ).pixels;
		}
	
		public function updatePixels()
		{
			var colors = new RegExp('(\d+),(\d+),(\d+),(\d+)');
			var data = [];
			var pos = 0;
	
			for ( var i = 0, l = pixels.length; i < l; i++ ) {
				var c = (pixels[i] || "rgba(0,0,0,1)").match(colors);
				data[pos] = parseInt(c[1]);
				data[pos+1] = parseInt(c[2]);
				data[pos+2] = parseInt(c[3]);
				data[pos+3] = parseFloat(c[4]) * 100;
				pos += 4;
			}
	
			curContext.putImageData(new ImageData(width, height, data), 0, 0);
		}
	
		public function extendClass( obj, args, fn )
		{
			if ( arguments.length == 3 )
			{
				fn.apply( obj, args );
			}
			else
			{
				args.call( obj );
			}
		}
	
		public function addMethod( object, name, fn )
		{
			if ( object[ name ] )
			{
				var args = fn.length;
				
				var oldfn = object[ name ];
				object[ name ] = function()
				{
					if ( arguments.length == args )
						return fn.apply( this, arguments );
					else
						return oldfn.apply( this, arguments );
				};
			}
			else
			{
				object[ name ] = fn;
			}
		}
		
		private function buildImageObject(obj:ImageData) {
			var pixels = obj.data;
			var data = this.createImage( obj.width, obj.height );
			
			if ( data.__defineGetter__ && data.__lookupGetter__ && !data.__lookupGetter__("pixels") ) {
				var pixelsDone;
				data.__defineGetter__("pixels", function () {
					if ( pixelsDone )
						return pixelsDone;
					pixelsDone = [];
			
					for ( var i = 0; i < pixels.length; i += 4 )
						pixelsDone.push(this.color(pixels[i], pixels[i+1], pixels[i+2], pixels[i+3]) );
			
					return pixelsDone;	
				});
			} else {
				data.pixels = [];
			
				for ( var i = 0; i < pixels.length; i += 4 )
					data.pixels.push(this.color(pixels[i], pixels[i+1], pixels[i+2], pixels[i+3]) );
			}

			return data;
		}
	}
}