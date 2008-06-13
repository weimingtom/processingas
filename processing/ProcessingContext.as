package processing {
	import com.gamemeal.html.Canvas;
	import mx.controls.Alert;
	import processing.*;
	import processing.ProcessingContext;
	import flash.utils.setInterval;
	import flash.utils.clearInterval;
	import asas.*;

	dynamic public class ProcessingContext {
		public function ProcessingContext(pObj:Processing):void {
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
  
  var curElement:Canvas = pObj.canvas;

  // "Private" variables used to maintain state
  var curContext = curElement.getContext("2d");
  var doFill = true;
  var doStroke = true;
  var loopStarted = false;
  var hasBackground = false;
  var doLoop = true;
  var curRectMode = p.CORNER;
  var curEllipseMode = p.CENTER;
  var inSetup = false;
  var inDraw = false;
  var curBackground = "rgba(204,204,204,1)";
  var curFrameRate = 1000;
  var curShape = p.POLYGON;
  var curShapeCount = 0;
  var opacityRange = 255;
  var redRange = 255;
  var greenRange = 255;
  var blueRange = 255;
  var pathOpen = false;
  var mousePressed = false;
  var keyPressed = false;
  var firstX, firstY, prevX, prevY;
  var curColorMode = p.RGB;
  var curTint = -1;
  var curTextSize = 12;
  var curTextFont = "Arial";
  var getLoaded = false;
  var start = (new Date).getTime();

  // Global vars for tracking mouse position
  p.pmouseX = 0;
  p.pmouseY = 0;
  p.mouseX = 0;
  p.mouseY = 0;

  // Will be replaced by the user, most likely
  p.mouseDragged = undefined;
  p.mouseMoved = undefined;
  p.mousePressed = undefined;
  p.mouseReleased = undefined;
  p.keyPressed = undefined;
  p.keyReleased = undefined;
  p.draw = undefined;
  p.setup = undefined;

  // The height/width of the canvas
  p.width = curElement.width - 0;
  p.height = curElement.height - 0;
  
  // In case I ever need to do HSV conversion:
  // http://srufaculty.sru.edu/david.dailey/javascript/js/5rml.js
  p.color = function ( aValue1, aValue2, aValue3, aValue4 )
  {
    var aColor = "";
    
    if ( arguments.length == 3 )
    {
      aColor = p.color( aValue1, aValue2, aValue3, opacityRange );
    }
    else if ( arguments.length == 4 )
    {
      var a = aValue4 / opacityRange;
      a = isNaN(a) ? 1 : a;

      if ( curColorMode == p.HSB )
      {
        var rgb = HSBtoRGB(aValue1, aValue2, aValue3);
        var r = rgb[0], g = rgb[1], b = rgb[2];
      }
      else
      {
        var r = getColor(aValue1, redRange);
        var g = getColor(aValue2, greenRange);
        var b = getColor(aValue3, blueRange);
      }

      aColor = "rgba(" + r + "," + g + "," + b + "," + a + ")";
    }
    else if ( typeof aValue1 == "string" )
    {
      aColor = aValue1;

      if ( arguments.length == 2 )
      {
        var c = aColor.split(",");
	c[3] = (aValue2 / opacityRange) + ")";
	aColor = c.join(",");
      }
    }
    else if ( arguments.length == 2 )
    {
      aColor = p.color( aValue1, aValue1, aValue1, aValue2 );
    }
    else if ( typeof aValue1 == "number" )
    {
      aColor = p.color( aValue1, aValue1, aValue1, opacityRange );
    }
    else
    {
      aColor = p.color( redRange, greenRange, blueRange, opacityRange );
    }

    // HSB conversion function from Mootools, MIT Licensed
    function HSBtoRGB(h, s, b)
    {
      h = (h / redRange) * 100;
      s = (s / greenRange) * 100;
      b = (b / blueRange) * 100;
      if (s == 0){
        return [b, b, b];
      } else {
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
    }

    function getColor( aValue, range )
    {
      return Math.round(255 * (aValue / range));
    }
    
    return aColor;
  }

  p.nf = function( num, pad )
  {
    var str = "" + num;
    while ( pad - str.length )
      str = "0" + str;
    return str;
  };

  p.AniSprite = function( prefix, frames )
  {
    this.images = [];
    this.pos = 0;

    for ( var i = 0; i < frames; i++ )
    {
      this.images.push( prefix + p.nf( i, ("" + frames).length ) + ".gif" );
    }

    this.display = function( x, y )
    {
      p.image( this.images[ this.pos ], x, y );

      if ( ++this.pos >= frames )
        this.pos = 0;
    };

    this.getWidth = function()
    {
      return getImage(this.images[0]).width;
    };

    this.getHeight = function()
    {
      return getImage(this.images[0]).height;
    };
  };

  function buildImageObject( obj )
  {
    var pixels = obj.data;
    var data = p.createImage( obj.width, obj.height );

    if ( data.__defineGetter__ && data.__lookupGetter__ && !data.__lookupGetter__("pixels") )
    {
      var pixelsDone;
      data.__defineGetter__("pixels", function()
      {
        if ( pixelsDone )
	  return pixelsDone;

	pixelsDone = [];

        for ( var i = 0; i < pixels.length; i += 4 )
        {
          pixelsDone.push( p.color(pixels[i], pixels[i+1], pixels[i+2], pixels[i+3]) );
        }

	return pixelsDone;
      });
    }
    else
    {
      data.pixels = [];

      for ( var i = 0; i < pixels.length; i += 4 )
      {
        data.pixels.push( p.color(pixels[i], pixels[i+1], pixels[i+2], pixels[i+3]) );
      }
    }

    return data;
  }

  p.createImage = function createImage( w, h, mode )
  {
    var data = {
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

  p.createGraphics = function createGraphics( w, h )
  {
    var pObj = new Processing();
    var ret = pObj.context;
    ret.size( w, h );
    ret.canvas = pObj.canvas;
    return ret;
  }

  p.beginDraw = function beginDraw()
  {

  }

  p.endDraw = function endDraw()
  {

  }

  p.tint = function tint( rgb, a )
  {
    curTint = a;
  }

  function getImage( img ) {
    if ( typeof img == "string" )
    {
      return document.getElementById(img);
    }

    if ( img.img || img.canvas )
    {
      return img.img || img.canvas;
    }

    img.data = [];

    for ( var i = 0, l = img.pixels.length; i < l; i++ )
    {
      var c = (img.pixels[i] || "rgba(0,0,0,1)").slice(5,-1).split(",");
      img.data.push( parseInt(c[0]), parseInt(c[1]), parseInt(c[2]), parseFloat(c[3]) * 100 );
    }

    var canvas = document.createElement("canvas")
    canvas.width = img.width;
    canvas.height = img.height;
    var context = canvas.getContext("2d");
    context.putImageData( img, 0, 0 );

    img.canvas = canvas;

    return canvas;
  }

  p.image = function image( img, x, y, w, h )
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
      p.image( img._mask, x, y );
      curContext.globalCompositeOperation = oldComposite;
    }
  }

  p.exit = function exit()
  {

  }

  p.save = function save( file )
  {

  }

  p.loadImage = function loadImage( file )
  {
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
    return data;
  }

  p.loadFont = function loadFont( name )
  {
    return {
      name: name,
      width: function( str )
      {
        if ( curContext.mozMeasureText )
          return curContext.mozMeasureText( typeof str == "number" ?
            String.fromCharCode( str ) :
            str) / curTextSize;
	else
	  return 0;
      }
    };
  }

  p.textFont = function textFont( name, size )
  {
    curTextFont = name;
    p.textSize( size );
  }

  p.textSize = function textSize( size )
  {
    if ( size )
    {
      curTextSize = size;
    }
  }

  p.textAlign = function textAlign()
  {

  }

  p.text = function text( str, x, y )
  {
    if ( str && curContext.mozDrawText )
    {
      curContext.save();
      curContext.mozTextStyle = curTextSize + "px " + curTextFont.name;
      curContext.translate(x, y);
      curContext.mozDrawText( typeof str == "number" ?
        String.fromCharCode( str ) :
	str );
      curContext.restore();
    }
  }

  p.char = function char( key )
  {
    //return String.fromCharCode( key );
    return key;
  }

  p.println = function println()
  {

  }

  p.map = function map( value, istart, istop, ostart, ostop )
  {
    return ostart + (ostop - ostart) * ((value - istart) / (istop - istart));
  };

  String.prototype.replaceAll = function(re, replace)
  {
    return this.replace(new RegExp(re, "g"), replace);
  };

  p.Point = function Point( x, y )
  {
    this.x = x;
    this.y = y;
    this.copy = function()
    {
      return new Point( x, y );
    }
  }

  p.Random = function()
  {
    var haveNextNextGaussian = false;
    var nextNextGaussian;

    this.nextGaussian = function()
    {
      if (haveNextNextGaussian) {
        haveNextNextGaussian = false;

        return nextNextGaussian;
      } else {
        var v1, v2, s;
        do { 
          v1 = 2 * p.random(1) - 1;   // between -1.0 and 1.0
          v2 = 2 * p.random(1) - 1;   // between -1.0 and 1.0
          s = v1 * v1 + v2 * v2;
        } while (s >= 1 || s == 0);
        var multiplier = Math.sqrt(-2 * Math.log(s)/s);
        nextNextGaussian = v2 * multiplier;
        haveNextNextGaussian = true;

        return v1 * multiplier;
      }
    };
  }

  p.ArrayList = function ArrayList( size, size2, size3 )
  {
    var array = new Array( 0 | size );
    
    if ( size2 )
    {
      for ( var i = 0; i < size; i++ )
      {
        array[i] = [];

        for ( var j = 0; j < size2; j++ )
        {
	  var a = array[i][j] = size3 ? new Array( size3 ) : 0;
	  for ( var k = 0; k < size3; k++ )
	  {
	    a[k] = 0;
	  }
        }
      }
    }
    else
    {
      for ( var i = 0; i < size; i++ )
      {
        array[i] = 0;
      }
    }
    
    array.size = function()
    {
      return this.length;
    };
    array.get = function( i )
    {
      return this[ i ];
    };
    array.remove = function( i )
    {
      return this.splice( i, 1 );
    };
    array.add = function( item )
    {
      for ( var i = 0; this[ i ] != undefined; i++ ) {}
      this[ i ] = item;
    };
    array.clone = function()
    {
      var a = new ArrayList( size );
      for ( var i = 0; i < size; i++ )
      {
        a[ i ] = this[ i ];
      }
      return a;
    };
    array.isEmpty = function()
    {
      return !this.length;
    };
    array.clear = function()
    {
      this.length = 0;
    };
    
    return array;
  }
  
  p.colorMode = function colorMode( mode, range1, range2, range3, range4 )
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
      p.colorMode( mode, range1, range1, range1, range1 );
    }
  }
  
  p.beginShape = function beginShape( type )
  {
    curShape = type;
    curShapeCount = 0; 
  }
  
  p.endShape = function endShape( close )
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
  
  p.vertex = function vertex( x, y, x2, y2, x3, y3 )
  {
    if ( curShapeCount == 0 && curShape != p.POINTS )
    {
      pathOpen = true;
      curContext.beginPath();
      curContext.moveTo( x, y );
    }
    else
    {
      if ( curShape == p.POINTS )
      {
        p.point( x, y );
      }
      else if ( arguments.length == 2 )
      {
        if ( curShape == p.TRIANGLE_STRIP && curShapeCount == 2 )
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
    
    if ( curShape == p.LINES && curShapeCount == 2 ||
         (curShape == p.TRIANGLES || curShape == p.TRIANGLE_STRIP) && curShapeCount == 3 )
    {
      p.endShape();
    }

    if ( curShape == p.TRIANGLE_STRIP && curShapeCount == 3 )
    {
      curShapeCount = 2;
    }
  }

  p.curveTightness = function()
  {

  }

  // Unimplmented - not really possible with the Canvas API
  p.curveVertex = function( x, y, x2, y2 )
  {
    p.vertex( x, y, x2, y2 );
  }

  p.bezierVertex = p.vertex
  
  p.rectMode = function rectMode( aRectMode )
  {
    curRectMode = aRectMode;
  }

  p.imageMode = function()
  {

  }
  
  p.ellipseMode = function ellipseMode( aEllipseMode )
  {
    curEllipseMode = aEllipseMode;
  }
  
  p.dist = function dist( x1, y1, x2, y2 )
  {
    return Math.sqrt( Math.pow( x2 - x1, 2 ) + Math.pow( y2 - y1, 2 ) );
  }

  p.year = function year()
  {
    return (new Date).getYear() + 1900;
  }

  p.month = function month()
  {
    return (new Date).getMonth();
  }

  p.day = function day()
  {
    return (new Date).getDay();
  }

  p.hour = function hour()
  {
    return (new Date).getHours();
  }

  p.minute = function minute()
  {
    return (new Date).getMinutes();
  }

  p.second = function second()
  {
    return (new Date).getSeconds();
  }

  p.millis = function millis()
  {
    return (new Date).getTime() - start;
  }
  
  p.ortho = function ortho()
  {
  
  }
  
  p.translate = function translate( x, y )
  {
    curContext.translate( x, y );
  }
  
  p.scale = function scale( x, y )
  {
    curContext.scale( x, y || x );
  }
  
  p.rotate = function rotate( aAngle )
  {
    curContext.rotate( aAngle );
  }
  
  p.pushMatrix = function pushMatrix()
  {
    curContext.save();
  }
  
  p.popMatrix = function popMatrix()
  {
    curContext.restore();
  }
  
  p.redraw = function redraw()
  {
    if ( hasBackground )
    {
      p.background();
    }
    
    inDraw = true;
    p.pushMatrix();
    p.draw();
    p.popMatrix();
    inDraw = false;
  }
  
  p.loop = function loop()
  {
    if ( loopStarted )
      return;
    
    var looping = setInterval(function()
    {
      try
      {
        p.redraw();
      }
      catch(e)
      {
        clearInterval( looping );
        throw e;
      }
    }, 1000 / curFrameRate );
    
    loopStarted = true;
  }
  
  p.frameRate = function frameRate( aRate )
  {
//[TODO] set stage one
    curFrameRate = aRate;
  }
  
  p.background = function background( img )
  {

    if ( arguments.length )
    {
      if ( img && img.hasOwnProperty('img') )
      {
        curBackground = img;
      }
      else
      {
        curBackground = p.color.apply( this, arguments );
      }
    }
    

    if ( curBackground.hasOwnProperty('img') )
    {
      p.image( curBackground, 0, 0 );
    }
    else
    {
      var oldFill = curContext.fillStyle;
      curContext.fillStyle = curBackground + "";
      curContext.fillRect( 0, 0, p.width, p.height );
      curContext.fillStyle = oldFill;
    }
  }

  p.sq = function sq( aNumber )
  {
    return aNumber * aNumber;
  }

  p.sqrt = function sqrt( aNumber )
  {
    return Math.sqrt( aNumber );
  }
  
  p.int = function int( aNumber )
  {
    return Math.floor( aNumber );
  }

  p.min = function min( aNumber, aNumber2 )
  {
    return Math.min( aNumber, aNumber2 );
  }

  p.max = function max( aNumber, aNumber2 )
  {
    return Math.max( aNumber, aNumber2 );
  }

  p.ceil = function ceil( aNumber )
  {
    return Math.ceil( aNumber );
  }

  p.floor = function floor( aNumber )
  {
    return Math.floor( aNumber );
  }

  p.float = function float( aNumber )
  {
    return typeof aNumber == "string" ?
	p.float( aNumber.charCodeAt(0) ) :
        parseFloat( aNumber );
  }

  p.byte = function byte( aNumber )
  {
    return aNumber || 0;
  }
  
  p.random = function random( aMin, aMax )
  {
    return arguments.length == 2 ?
      aMin + (Math.random() * (aMax - aMin)) :
      Math.random() * aMin;
  }

  // From: http://freespace.virgin.net/hugo.elias/models/m_perlin.htm
  p.noise = function( x, y, z )
  {
    return arguments.length >= 2 ?
      PerlinNoise_2D( x, y ) :
      PerlinNoise_2D( x, x );
  }

  function Noise(x, y)
  {
    var n = x + y * 57;
    n = (n<<13) ^ n;
    return Math.abs(1.0 - (((n * ((n * n * 15731) + 789221) + 1376312589) & 0x7fffffff) / 1073741824.0));
  }

  function SmoothedNoise(x, y)
  {
    var corners = ( Noise(x-1, y-1)+Noise(x+1, y-1)+Noise(x-1, y+1)+Noise(x+1, y+1) ) / 16;
    var sides   = ( Noise(x-1, y)  +Noise(x+1, y)  +Noise(x, y-1)  +Noise(x, y+1) ) /  8;
    var center  =  Noise(x, y) / 4;
    return corners + sides + center;
  }

  function InterpolatedNoise(x, y)
  {
    var integer_X    = Math.floor(x);
    var fractional_X = x - integer_X;

    var integer_Y    = Math.floor(y);
    var fractional_Y = y - integer_Y;

    var v1 = SmoothedNoise(integer_X,     integer_Y);
    var v2 = SmoothedNoise(integer_X + 1, integer_Y);
    var v3 = SmoothedNoise(integer_X,     integer_Y + 1);
    var v4 = SmoothedNoise(integer_X + 1, integer_Y + 1);

    var i1 = Interpolate(v1 , v2 , fractional_X);
    var i2 = Interpolate(v3 , v4 , fractional_X);

    return Interpolate(i1 , i2 , fractional_Y);
  }

  function PerlinNoise_2D(x, y)
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

  function Interpolate(a, b, x)
  {
    var ft = x * p.PI;
    var f = (1 - p.cos(ft)) * .5;
    return  a*(1-f) + b*f;
  }

  p.red = function( aColor )
  {
    return parseInt(aColor.slice(5));
  }

  p.green = function( aColor )
  {
    return parseInt(aColor.split(",")[1]);
  }

  p.blue = function( aColor )
  {
    return parseInt(aColor.split(",")[2]);
  }

  p.alpha = function( aColor )
  {
    return parseInt(aColor.split(",")[3]);
  }

  p.abs = function abs( aNumber )
  {
    return Math.abs( aNumber );
  }
  
  p.cos = function cos( aNumber )
  {
    return Math.cos( aNumber );
  }
  
  p.sin = function sin( aNumber )
  {
    return Math.sin( aNumber );
  }
  
  p.pow = function pow( aNumber, aExponent )
  {
    return Math.pow( aNumber, aExponent );
  }
  
  p.constrain = function constrain( aNumber, aMin, aMax )
  {
    return Math.min( Math.max( aNumber, aMin ), aMax );
  }
  
  p.sqrt = function sqrt( aNumber )
  {
  	return Math.sqrt( aNumber );
  }
  
  p.atan2 = function atan2( aNumber, aNumber2 )
  {
  	return Math.atan2( aNumber, aNumber2 );
  }
  
  p.radians = function radians( aAngle )
  {
    return ( aAngle / 180 ) * p.PI;
  }
  
  p.size = function size( aWidth, aHeight )
  {
    var fillStyle = curContext.fillStyle;
    var strokeStyle = curContext.strokeStyle;

    curElement.width = p.width = aWidth;
    curElement.height = p.height = aHeight;

    curContext.fillStyle = fillStyle;
    curContext.strokeStyle = strokeStyle;
  }
  
  p.noStroke = function noStroke()
  {
    doStroke = false;
  }
  
  p.noFill = function noFill()
  {
    doFill = false;
  }
  
  p.smooth = function smooth()
  {
  
  }
  
  p.noLoop = function noLoop()
  {
    doLoop = false;
  }
  
  p.fill = function fill()
  {
    doFill = true;
    curContext.fillStyle = p.color.apply( this, arguments );
  }
  
  p.stroke = function stroke()
  {
    doStroke = true;
    curContext.strokeStyle = p.color.apply( this, arguments );
  }

  p.strokeWeight = function strokeWeight( w )
  {
    curContext.lineWidth = w;
  }
  
  p.point = function point( x, y )
  {
    var oldFill = curContext.fillStyle;
    curContext.fillStyle = curContext.strokeStyle;
    curContext.fillRect( Math.round( x ), Math.round( y ), 1, 1 );
    curContext.fillStyle = oldFill;
  }

  p.get = function ( x, y )
  {
    if ( arguments.length == 0 )
    {
      var c = p.createGraphics( p.width, p.height );
      c.image( curContext, 0, 0 );
      return c;
    }

    if ( !getLoaded )
    {
      getLoaded = buildImageObject( curContext.getImageData(0, 0, p.width, p.height) );
    }

    return getLoaded.get( x, y );
  }

  p.set = function ( x, y, color )
  {
    var oldFill = curContext.fillStyle;
    curContext.fillStyle = color;
    curContext.fillRect( Math.round( x ), Math.round( y ), 1, 1 );
    curContext.fillStyle = oldFill;
  }
  
  p.arc = function arc( x, y, width, height, start, stop )
  {
    if ( width <= 0 )
      return;

    if ( curEllipseMode == p.CORNER )
    {
      x += width / 2;
      y += height / 2;
    }

    curContext.beginPath();
  
    curContext.moveTo( x, y );
    curContext.arc( x, y, curEllipseMode == p.CENTER_RADIUS ? width : width/2, start, stop, false );
    
    if ( doFill )
      curContext.fill();
      
    if ( doStroke )
      curContext.stroke();
    
    curContext.closePath();
  }
  
  p.line = function line( x1, y1, x2, y2 )
  {
    curContext.lineCap = "round";
    curContext.beginPath();
  
    curContext.moveTo( x1 || 0, y1 || 0 );
    curContext.lineTo( x2 || 0, y2 || 0 );
    
    curContext.stroke();
    
    curContext.closePath();
  }

  p.bezier = function bezier( x1, y1, x2, y2, x3, y3, x4, y4 )
  {
    curContext.lineCap = "butt";
    curContext.beginPath();
  
    curContext.moveTo( x1, y1 );
    curContext.bezierCurveTo( x2, y2, x3, y3, x4, y4 );
    
    curContext.stroke();
    
    curContext.closePath();
  }

  p.triangle = function triangle( x1, y1, x2, y2, x3, y3 )
  {
    p.beginShape();
    p.vertex( x1, y1 );
    p.vertex( x2, y2 );
    p.vertex( x3, y3 );
    p.endShape();
  }

  p.quad = function quad( x1, y1, x2, y2, x3, y3, x4, y4 )
  {
    p.beginShape();
    p.vertex( x1, y1 );
    p.vertex( x2, y2 );
    p.vertex( x3, y3 );
    p.vertex( x4, y4 );
    p.endShape();
  }
  
  p.rect = function rect( x, y, width, height )
  {
    if ( width == 0 && height == 0 )
      return;

    curContext.beginPath();
    
    var offsetStart = 0;
    var offsetEnd = 0;

    if ( curRectMode == p.CORNERS )
    {
      width -= x;
      height -= y;
    }
    
    if ( curRectMode == p.RADIUS )
    {
      width *= 2;
      height *= 2;
    }
    
    if ( curRectMode == p.CENTER || curRectMode == p.RADIUS )
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
  
  p.ellipse = function ellipse( x, y, width, height )
  {
    x = x || 0;
    y = y || 0;

    if ( width <= 0 && height <= 0 )
      return;

    curContext.beginPath();
    
    if ( curEllipseMode == p.RADIUS )
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

  p.link = function( href, target )
  {
    window.location = href;
  }

  p.loadPixels = function()
  {
    p.pixels = buildImageObject( curContext.getImageData(0, 0, p.width, p.height) ).pixels;
  }

  p.updatePixels = function()
  {
    var colors = new RegExp('(\d+),(\d+),(\d+),(\d+)');
    var pixels = {};
    var data = pixels.data = [];
    pixels.width = p.width;
    pixels.height = p.height;

    var pos = 0;

    for ( var i = 0, l = p.pixels.length; i < l; i++ ) {
      var c = (p.pixels[i] || "rgba(0,0,0,1)").match(colors);
      data[pos] = parseInt(c[1]);
      data[pos+1] = parseInt(c[2]);
      data[pos+2] = parseInt(c[3]);
      data[pos+3] = parseFloat(c[4]) * 100;
      pos += 4;
    }

    curContext.putImageData(pixels, 0, 0);
  }

  p.extendClass = function extendClass( obj, args, fn )
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

  p.addMethod = function addMethod( object, name, fn )
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

  p.init = function (code){
    p.stroke( 0 );
    p.fill( 255 );
  
    // Canvas has trouble rendering single pixel stuff on whole-pixel
    // counts, so we slightly offset it (this is super lame).
    curContext.translate( 0.5, 0.5 );

    if ( code )
    {
      (function(Processing){
		var pCode = parse(code, p);
		trace(pCode);
		ExecutionContext.global.setProperty('Processing', ESObject.wrap(Processing));
		Evaluator.evaluate('with (Processing) { ' + pCode + '}');
      })(p);
    }
  
    if ( p.setup )
    {
      inSetup = true;
      p.setup();
    }
    
    inSetup = false;
    
    if ( p.draw )
    {
      if ( !doLoop )
      {
        p.redraw();
      }
      else
      {
        p.loop();
      }
    }
    
    attach( curElement, "mousemove", function(e)
    {
      p.pmouseX = p.mouseX;
      p.pmouseY = p.mouseY;
      p.mouseX = e.clientX;
      p.mouseY = e.clientY;

      if ( p.mouseMoved )
      {
        p.mouseMoved();
      }      

      if ( mousePressed && p.mouseDragged )
      {
        p.mouseDragged();
      }      
    });
    
    attach( curElement, "mousedown", function(e)
    {
      mousePressed = true;

      if ( typeof p.mousePressed == "function" )
      {
        p.mousePressed();
      }
      else
      {
        p.mousePressed = true;
      }
    });
      
    attach( curElement, "mouseup", function(e)
    {
      mousePressed = false;

      if ( typeof p.mousePressed != "function" )
      {
        p.mousePressed = false;
      }

      if ( p.mouseReleased )
      {
        p.mouseReleased();
      }
    });

    attach( document, "keydown", function(e)
    {
      keyPressed = true;

      p.key = e.keyCode + 32;

      if ( e.shiftKey )
      {
        p.key = String.fromCharCode(p.key).toUpperCase().charCodeAt(0);
      }

      if ( typeof p.keyPressed == "function" )
      {
        p.keyPressed();
      }
      else
      {
        p.keyPressed = true;
      }
    });

    attach(document, "keyup", function(e) {
      keyPressed = false;

      if ( typeof p.keyPressed != "function" )
      {
        p.keyPressed = false;
      }

      if ( p.keyReleased )
      {
        p.keyReleased();
      }
    });
    
    function attach(elem, type, fn)
    {
      if ( elem.addEventListener )
        elem.addEventListener( type, fn, false );
      else
        elem.attachEvent( "on" + type, fn );
    }
  };

		}
		
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
	}
}