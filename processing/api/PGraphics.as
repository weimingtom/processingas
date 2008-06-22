package processing.api {
	import processing.parser.ExecutionContext;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.CapsStyle;
	import flash.display.StageQuality;
	import flash.geom.Rectangle;
	import flash.geom.Matrix;
	import flash.utils.getDefinitionByName;
	import flash.events.Event;

	public class PGraphics extends PImage {
		// applet object
		public var applet:PApplet;
		
		// constructor
		public function PGraphics(w:int, h:int, a:PApplet = null):void {			
			// call super
			super(w, h);
			// save applet reference
			applet = a;

			// initialize state variables
			start = millis();
		}
	
		// drawing constants
		public const P2D = 3;
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
//[TODO] this is here because of shapeMatrix... fix that later?
			bitmapData.draw(shape, shapeMatrix, null, null, null, doSmooth);
			shape.graphics.clear();
		}
		
		// color conversion
//[TODO] should there be a color datatype?
		public function color(... args):Number {
			var aColor:Number = 0;

			// function overrides
			if (args.length == 1 && args[0] < 256 && args[0] >= 0)
			{
				// color(gray)
				return color( args[0], args[0], args[0], opacityRange );
			}
			else if (args.length == 2 && args[0] < 256 && args[0] >= 0)
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
			else if ( args.length == 1 )
			{
				// color(hex)
				return args[0];
			}
			else if ( args.length == 2 )
			{
				// color(hex, alpha)
				return args[0] + (args[1] << 24);
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
		
		public function createImage( w:int, h:int, mode = null ):PImage
		{
			var img:PImage = new PImage(w, h);
			img.loadPixels();
			return img;
		}
		
		public function createGraphics( w:int, h:int, type:int = P2D ):PGraphics
		{
//[TODO] what about type?
			return new PGraphics(w, h);
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
			
		public function image( img:PImage, x:int = 0, y:int = 0, w:int = undefined, h:int = undefined )
		{
			// create transformaton matrix
			var matrix:Matrix = new Matrix();
			// translation
			matrix.translate(x, y);
			// scaling
			if (arguments.length == 5)
				matrix.scale(w/img.width, h/img.height);
	
			// resync image
			img.updatePixels();
			// draw image
			bitmapData.draw(img.bitmapData, matrix);
	
/*			if ( img._mask )
			{
				var oldComposite = curContext.globalCompositeOperation;
				curContext.globalCompositeOperation = "darker";
				image( img._mask, x, y );
				curContext.globalCompositeOperation = oldComposite;
			}*/
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
	
		public function println()
		{
//[TODO] er
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

		public function beginShape( type = POLYGON )
		{
//[TODO] prevent other shapes from drawing until endShape
			curShape = type;
			curShapeCount = 0;
			beginShapeDrawing();
		}
		
		public function endShape( close = true )
		{
			// close shape
			if ( pathOpen )
			{
				shape.graphics.lineTo( firstX, firstY );
				pathOpen = false;
			}
			
			if ( curShapeCount != 0 )
			{
				endShapeDrawing();
				curShapeCount = 0;
			}
		}
		
		public function vertex( x, y, x2 = null, y2 = null, x3 = null, y3 = null )
		{
			if ( curShapeCount == 0 && curShape != POINTS )
			{
				pathOpen = true;
				shape.graphics.moveTo( x, y );
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
						shape.graphics.moveTo( prevX, prevY );
						shape.graphics.lineTo( firstX, firstY );
					}
	
					shape.graphics.lineTo( x, y );
				}
				else if ( arguments.length == 4 )
				{
					if ( curShapeCount > 1 )
					{
						shape.graphics.moveTo( prevX, prevY );
//[TODO]					shape.graphics.quadraticCurveTo( firstX, firstY, x, y );
						curShapeCount = 1;
					}
				}
				else if ( arguments.length == 6 )
				{
//[TODO]				shape.graphics.bezierCurveTo( x, y, x2, y2, x3, y3 );
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
	/*
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

		public function translate( x:Number, y:Number ):void
		{
			var newMatrix = new Matrix();
			newMatrix.translate(x, y);
			newMatrix.concat(shapeMatrix);
			shapeMatrix = newMatrix;
		}
		
		public function scale( x:Number, y:Number = undefined ):void
		{
			var newMatrix = new Matrix();
			newMatrix.scale(x, y == undefined ? x : y);
			newMatrix.concat(shapeMatrix);
			shapeMatrix = newMatrix;
		}
		
		public function rotate( aAngle:Number ):void
		{
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
//[TODO] what should we do here?
		}
		
		public function beginDraw()
		{
			// clear graphics and reset background
			if ( hasBackground )
			{
				background();
			}
		}
		
		public function endDraw()
		{
//[TODO] rasterize shape
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
				bitmapData.fillRect(new Rectangle(0, 0, width, height), curBackground);
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
			if (applet)
				applet.stage.quality = StageQuality.HIGH;
		}

		public function noSmooth():void
		{
			doSmooth = false;
			if (applet)
				applet.stage.quality = StageQuality.LOW;
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
			bitmapData.setPixel32(x, y, curStrokeColor);
		}
/*
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
		
		public function line( x1:Number = 0, y1:Number = 0, x2:Number = 0, y2:Number = 0):void
		{
			beginShapeDrawing();
			shape.graphics.moveTo( x1, y1 );
			shape.graphics.lineTo( x2, y2 );
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
		}*/
	
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

		//=========================================================
		// Environment
		//=========================================================

		public function frameRate( aRate:Number ):void
		{
			if (applet)
				applet.stage.frameRate = aRate;
		}

		public function size( aWidth:Number, aHeight:Number ):void
		{
			// change image size (no need to preserve data)
			bitmapData = new BitmapData( aWidth, aHeight);
			if (applet)
				applet.bitmapData = bitmapData;
		}

//[TODO] these might have to be moved out of this class
		public function loop()
		{
			if (applet)
				applet.enableLoop = true;
		}
		
		public function noLoop()
		{
			if (applet)
				applet.enableLoop = false;
		}

		public function link( href:String, target ):void
		{
			var request:URLRequest;
			request = new URLRequest(href);
			navigateToURL(request);
		}

		public function exit()
		{
			// stop applet
			if (applet)
				applet.stop();
		}

		//=========================================================
		// Input
		//=========================================================

		// Time & Date

		private var start:Number;

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
	}
}
