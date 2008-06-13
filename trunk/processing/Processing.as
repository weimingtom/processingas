/*
 * Processing.js - John Resig (http://ejohn.org/)
 * MIT Licensed
 * http://ejohn.org/blog/processingjs/
 *
 * This is a port of the Processing Visualization Language.
 * More information: http://processing.org/
 */

package processing {

	import com.gamemeal.html.Canvas;
	import mx.controls.Alert;
	import processing.*;

	public function Processing( aElement, aCode )
	{
	  var p = buildProcessing( aElement );
	  p.init( aCode );
	  return p;
	}
}