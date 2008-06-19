package processing.api {
	import processing.api.*;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.CapsStyle;
	import flash.display.StageQuality;
	import flash.geom.Rectangle;
	import flash.geom.Matrix;
	import flash.utils.getDefinitionByName;

//[TODO] not dynamic!
	dynamic public class Context {
		// processing object
		private var p:Processing;
	
		// init

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
		private var hasBackground:Boolean = false;
		private var curRectMode:Number = CORNER;
		private var curEllipseMode:Number = CENTER;
		private var curBackground:*;
		private var curFrameRate:Number = 60;
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
		
		// mouse position vars
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
		public function get width():Number { return p.sprite.bitmapData.width; }
		public function get height():Number { return p.sprite.bitmapData.height; }

		// pixels array
		public var pixels:Array;
		
		// constructor
		public function Context(_p:Processing):void {
			// save processing object
			p = _p;
		
			// initialize state variables
			start = (new Date).getTime();		
		}

		// stroke
		private var doStroke:Boolean = true;
		private var curStrokeWeight:Number = 1;
		private var curStrokeColor:Number = 0xFF000000;
		private var curStrokeCap:String = CapsStyle.ROUND;

		// fill
		private var doFill:Boolean = true;
		private var curFillColor:Number = 0xFFFFFFFF;

		// shape drawing
		private var shape:Shape = new Shape();
		private var shapeMatrix:Matrix = new Matrix();
		private var doSmooth:Boolean = false;

		private function beginShapeDrawing():void {			
			// set stroke
			if (doStroke)
				shape.graphics.lineStyle(curStrokeWeight, curStrokeColor & 0xFFFFFF,
				    alpha(curStrokeColor) / 255, true, 'normal',
				    curStrokeCap, curStrokeCap);
			else
				shape.graphics.lineStyle();

			// set fill
			if (doFill)
				shape.graphics.beginFill(curFillColor & 0xFFFFFF, alpha(curFillColor) / 255);
		}

		private function endShapeDrawing():void {
			// end any open fill
			shape.graphics.endFill();

			// rasterize and clear shape
//[TODO] this is here cause of shapeMatrix... fix that later?
			p.sprite.bitmapData.draw(shape, shapeMatrix, null, null, null, doSmooth);
			shape.graphics.clear();
		}
		
		// color conversion
//[TODO] should be a color datatype
		public function color(... args):Number {
			var aColor:Number = 0;

			// function overrides
			if (args.length == 1 && args[0] < 256)
			{
				// color(gray)
				return color( args[0], args[0], args[0], opacityRange );
			}
			else if (args.length == 2 && args[0] < 256)
			{
				// color(gray, alpha)
				return color( args[0], args[0], args[0], args[1] );
			}
			else if (args.length == 3)
			{
				// color(value1, value2, value3)
				return color(args[0], args[1], args[2], opacityRange );
			}
			else if (args.length == 4)
			{
				// color(value1, value2, value3, alpha)
				var a = getColor(args[3], opacityRange);
	
				// normalize color values
				var colors = (curColorMode == HSB) ?
				    HSBtoRGB(args[0], args[1], args[2]) : args;
				// fit colors into range
				var r = getColor(colors[0], redRange);
				var g = getColor(colors[1], greenRange);
				var b = getColor(colors[2], blueRange);

				return (a << 24) + (r << 16) + (g << 8) + b;
			}
			else if ( args.length == 1 && args[0] > 256 )
			{
				// color(hex)
				return color(args[0] >> 16 & 0xFF, args[0] >> 8 & 0xFF, args[0] & 0xFF, args[0] >> 24 & 0xFF);
			}
			else if ( args.length == 2 && args[0] > 256 )
			{
				// color(hex, alpha)
				return color(args[0] >> 16 & 0xFF, args[0] >> 8 & 0xFF, args[0] & 0xFF, args[1]);
			}
			
			// catch-all
			return color( redRange, greenRange, blueRange, opacityRange );
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
//		public var AniSprite:Class = getDefinitionByName('processing.api.AniSprite') as Class;
		
		// ArrayList class
		public var ArrayList:Class = getDefinitionByName('processing.api.ArrayList') as Class;
		
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
		
		public function createGraphics( w, h )
		{
/*			var pObj:Processing = new Processing();
			var ret:Context = pObj.context;
			ret.size( w, h );
			return ret;*/
		}

		public function tint( rgb:Number, a:Number ):void
		{
			//[TODO] rgb?
			curTint = a;
		}
		
		//[TODO] this should be private; see AniSprite
		//[TODO] also, this function needs much work
		private function getImage( img ) {
/*			if ( typeof img == "string" )
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
			
			return canvas;*/
		}
			
		public function image( img, x, y, w = null, h = null )
		{
/*			x = x || 0;
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
			}*/
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
		
		public function colorMode( mode:Number, range1:Number = undefined, range2:Number = undefined, range3:Number = undefined, range4:Number = undefined ):void
		{
			curColorMode = mode;

			if ( arguments.length == 2 )
			{
				colorMode( mode, range1, range1, range1, range1 );
			}
			else if ( arguments.length >= 3 )
			{
				redRange = range1 ? range1 : redRange;
				greenRange = range2 ? range2 : redRange;
				blueRange = range3 ? range3 : redRange;
				opacityRange = range4 ? range4 : opacityRange;
			}
		}
/*
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
		}*/
		
		public function rectMode( aRectMode:Number ):void
		{
			curRectMode = aRectMode;
		}
	
		public function imageMode()
		{
	
		}
		
		public function ellipseMode( aEllipseMode:Number ):void
		{
			curEllipseMode = aEllipseMode;
		}
		
		public function ortho()
		{
		
		}

//[TODO] see effects order has on matrix!
		public function translate( x:Number, y:Number ):void
		{
			// apply matrix transformations
			var newMatrix = new Matrix();
			newMatrix.translate(x, y);
			newMatrix.concat(shapeMatrix);
			shapeMatrix = newMatrix;
		}
		
		public function scale( x:Number, y:Number = undefined ):void
		{
			shapeMatrix.scale(x, y == undefined ? x : y);
		}
		
		public function rotate( aAngle:Number ):void
		{
			// apply matrix transformations
			var newMatrix = new Matrix();
			newMatrix.rotate(aAngle);
			newMatrix.concat(shapeMatrix);
			shapeMatrix = newMatrix;
		}
		
		private var matrixStack:Array = [];
		
		public function pushMatrix()
		{
			matrixStack.push(shapeMatrix.clone());
		}
		
		public function popMatrix()
		{
			shapeMatrix = matrixStack.pop();
		}
		
		public function redraw()
		{
			beginDraw()
			pushMatrix();
			draw();
			popMatrix();
			endDraw();
		}
		
		public function beginDraw()
		{
			p.inDraw = true;
			
			// clear graphics and reset background
			if ( hasBackground )
			{
				background();
			}
		}
		
		public function endDraw()
		{
			p.inDraw = false;
		}
		
		public function loop()
		{
			p.loop = false;
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
				// set background color
				p.sprite.bitmapData.fillRect(new Rectangle(0, 0, width, height), curBackground);
			}
		}
	
		public function red( aColor:Number ):Number
		{
			return aColor >> 16 & 0xFF;
		}
	
		public function green( aColor:Number ):Number
		{
			return aColor >> 8 & 0xFF;
		}
	
		public function blue( aColor:Number ):Number
		{
			return aColor & 0xFF;
		}
	
		public function alpha( aColor:Number ):Number
		{
			return aColor >> 24 & 0xFF;
		}
		
		public function noStroke()
		{
			doStroke = false;
		}
		
		public function noFill()
		{
			doFill = false;
		}
		
		public function smooth():void
		{
			doSmooth = true;
			p.sprite.stage.quality = StageQuality.HIGH;
		}

		public function noSmooth():void
		{
			doSmooth = false;
			p.sprite.stage.quality = StageQuality.LOW;
		}
		
		public function noLoop()
		{
			p.loop = false;
		}
		
		public function fill( ... args ):void
		{
			doFill = true;
			curFillColor = color.apply( this, args );
		}
		
		public function stroke( ... args ):void
		{
			doStroke = true;
			curStrokeColor = color.apply( this, args );
		}
	
		public function strokeWeight( w:Number ):void
		{
			curStrokeWeight = w;
		}
		
		public function point( x:Number, y:Number ):void
		{
			p.sprite.bitmapData.setPixel32(x, y, curStrokeColor);
		}
	
/*		public function get( x, y )
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
		}*/
		
		public function line( x1, y1, x2, y2 )
		{
			beginShapeDrawing();
			shape.graphics.moveTo( x1 || 0, y1 || 0 );
			shape.graphics.lineTo( x2 || 0, y2 || 0 );
			endShapeDrawing();
		}
	
/*		public function bezier( x1, y1, x2, y2, x3, y3, x4, y4 )
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
		}*/
		
		public function rect( x:Number, y:Number, width:Number, height:Number )
		{
			// modify rectange mode
			switch (curRectMode)
			{
			    case CORNERS:
				width -= x;
				height -= y;
				break;

			    case RADIUS:
				width *= 2;
				height *= 2;
			    case CENTER:
				x -= (width / 2);
				y -= (height / 2);
				break;

			    default:
				break;
			}

			// draw shape
			beginShapeDrawing();
			shape.graphics.drawRect(x, y, width, height);
			endShapeDrawing();
		}
		
		public function ellipse( x:Number, y:Number, width:Number, height:Number )
		{
			// modify ellipse mode
			switch (curEllipseMode)
			{
			    case RADIUS:
				width *= 2;
				height *= 2;
			    case CENTER:
				x -= (width / 2);
				y -= (height / 2);
				break;
			}

			// draw shape
			beginShapeDrawing();
			shape.graphics.drawEllipse(x, y, width, height);
			endShapeDrawing();
		}

		public function link( href:String, target ):void
		{
			var request:URLRequest;
			request = new URLRequest(href);
			navigateToURL(request);
		}
	
/*		public function loadPixels()
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
		}*/

		public function int( aNumber )
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

		//=========================================================
		// Environment
		//=========================================================

		public function frameRate( aRate:Number ):void
		{
			p.sprite.stage.frameRate = aRate;
//[TODO] eliminate stored frameRate
			curFrameRate = aRate;
		}

		public function size( aWidth:Number, aHeight:Number ):void
		{
			// change image size (no need to preserve data)
			p.sprite.bitmapData = new BitmapData( aWidth, aHeight);
		}

		//=========================================================
		// Input
		//=========================================================

		// Time & Date

		public function hour():Number
		{
			return (new Date).getHours();
		}
	
		public function millis():Number
		{
			return (new Date).getTime() - start;
		}
	
		public function year():Number
		{
			return (new Date).getFullYear();
		}

		public function minute():Number
		{
			return (new Date).getMinutes();
		}
	
		public function month():Number
		{
			return (new Date).getMonth();
		}
	
		public function day():Number
		{
			return (new Date).getDay();
		}
	
		public function second():Number
		{
			return (new Date).getSeconds();
		}

		//=========================================================
		// Math
		//=========================================================

		// Calculation

		public function min( aNumber:Number, aNumber2:Number ):Number
		{
			return Math.min( aNumber, aNumber2 );
		}
	
		public function max( aNumber:Number, aNumber2:Number ):Number
		{
			return Math.max( aNumber, aNumber2 );
		}

		public function round( aNumber:Number ):Number
		{
			return Math.round( aNumber );
		}

		public function dist( x1:Number, y1:Number, x2:Number, y2:Number ):Number
		{
			return Math.sqrt( Math.pow( x2 - x1, 2 ) + Math.pow( y2 - y1, 2 ) );
		}

		public function pow( aNumber:Number, aExponent:Number ):Number
		{
			return Math.pow( aNumber, aExponent );
		}

		public function floor( aNumber:Number ):Number
		{
			return Math.floor( aNumber );
		}

		public function sqrt( aNumber:Number ):Number
		{
			return Math.sqrt( aNumber );
		}

		public function abs( aNumber:Number ):Number
		{
			return Math.abs( aNumber );
		}

		public function constrain( aNumber:Number, aMin:Number, aMax:Number ):Number
		{
			return Math.min( Math.max( aNumber, aMin ), aMax );
		}

		public function norm( value:Number, istart:Number, istop:Number ):Number
		{
			return map( value, istart, istop, 0, 1 );
		}

		public function lerp( value1:Number, value2:Number, amt:Number ):Number
		{
			return value1 + ((value2 - value1) * amt);
		}

		public function sq( aNumber:Number ):Number
		{
			return Math.pow( aNumber, 2 );
		}
	
		public function ceil( aNumber:Number ):Number
		{
			return Math.ceil( aNumber );
		}

		public function map( value:Number, istart:Number, istop:Number, ostart:Number, ostop:Number ):Number
		{
			return ostart + (ostop - ostart) * ((value - istart) / (istop - istart));
		}

		// Trigonometry

		public function tan( aNumber:Number ):Number
		{
			return Math.tan( aNumber );
		}

		public function sin( aNumber:Number ):Number
		{
			return Math.sin( aNumber );
		}
		
		public function cos( aNumber:Number ):Number
		{
			return Math.cos( aNumber );
		}

		public function degrees( aAngle:Number ):Number
		{
			return ( aAngle / Math.PI ) * 180;
		}

		public function atan2( aNumber:Number, aNumber2:Number ):Number
		{
			return Math.atan2( aNumber, aNumber2 );
		}
		
		public function radians( aAngle:Number ):Number
		{
			return ( aAngle / 180 ) * Math.PI;
		}

		// Random

		// From: http://freespace.virgin.net/hugo.elias/models/m_perlin.htm
		public function noise( x:Number, y:Number = undefined, z:Number = undefined ):Number
		{
			return arguments.length >= 2 ?
				PerlinNoise_2D( x, y ) :
				PerlinNoise_2D( x, x );
		}
	
		private function Noise(x, y):Number
		{
			var n = x + y * 57;
			n = (n<<13) ^ n;
			return Math.abs(1.0 - (((n * ((n * n * 15731) + 789221) + 1376312589) & 0x7fffffff) / 1073741824.0));
		}
	
		private function SmoothedNoise(x, y):Number
		{
			var corners = ( Noise(x-1, y-1)+Noise(x+1, y-1)+Noise(x-1, y+1)+Noise(x+1, y+1) ) / 16;
			var sides	 = ( Noise(x-1, y)	+Noise(x+1, y)	+Noise(x, y-1)	+Noise(x, y+1) ) /	8;
			var center	=	Noise(x, y) / 4;
			return corners + sides + center;
		}
	
		private function InterpolatedNoise(x, y):Number
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
	
		private function PerlinNoise_2D(x, y):Number
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
	
		private function Interpolate(a, b, x):Number
		{
			var ft = x * Math.PI;
			var f = (1 - Math.cos(ft)) * .5;
			return a*(1-f) + b*f;
		}

		public function randomSeed( aValue )
		{
			//[TODO]
		}

		public function random( aMin, aMax = null ):Number
		{
			return arguments.length == 2 ?
				aMin + (Math.random() * (aMax - aMin)) :
				Math.random() * aMin;
		}

		//=========================================================
		// Constants
		//=========================================================

		public const HALF_PI:Number = Math.PI / 2;
		public const TWO_PI:Number = Math.PI * 2;
		public const PI:Number = Math.PI;
		
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
		
		//=========================================================
		// TEMPORARY
		//=========================================================
        
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

	}
}
