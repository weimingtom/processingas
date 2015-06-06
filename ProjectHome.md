Processing.as is a port of the [Processing](http://processing.org/) programming language to ActionScript. It includes a fully functional parser and evaluator, as well as an API layer, to run many existing and new Processing scripts. To check out Processing.as in action, take a look at the following examples:

  * **[Processing Test Suite (Java/JavaScript/Flash)](http://tim-ryan.com/projects/processing.as/testsuite.html)**
  * **[Processing.as sandbox](http://tim-ryan.com/projects/processing.as/sandbox.html)**

# Using Processing.swf #

The processing.swf file can be placed in any webpage and loaded with a Processing script dynamically via JavaScript. First download the [compiled](http://processingas.googlecode.com/files/processing.as-compiled-m1.zip) package. Embed the processing.swf in your page, and include the "processing.as.js" file. To interact with the swf, add methods to the ProcessingAS variable. For instance:

```
var Processing = null;

ProcessingAS.onLoad = function () {
	// movie loaded, get object reference
	Processing = document.getElementById('processing');
	// start interactivity
	Processing.start();
}

ProcessingAS.onStart = function () {
	// drawing APIs are now available
	Processing.size(200, 200);
	Processing.fill(255, 0, 0);
	Processing.rect(0, 0, 100, 100);

	// run some Processing code
	Processing.run('line(0, 0, width, height)');
}

ProcessingAS.onResize = function (w, h) {
	// Processing canvas resized; resize embedded element
	Processing.width = w;
	Processing.height = h;
}

```

# Using the Library #

The Processing library can be used for its API or for its Parser. To get started, download the [source](http://processingas.googlecode.com/files/processing.as-source-m1.zip) and unpack it to your script directory. You can take a look at the root-level processing.as for an example, or view the classes in the api/ folder for more information.

To use it in a script, you'll want to create a `new Processing` object, call `.evaluate()` with your code, and then `.start()`. Additionally, you can call the API methods directly with the `.applet.graphics` reference (an instance of the `PGraphics` class).

# Credits #

Many thanks go to [John Resig](http://ejohn.org/) for his work on [Processing.js](http://ejohn.org/blog/processingjs/), and the folks over at [Processing](http://processing.org/) for their work in developing the language.