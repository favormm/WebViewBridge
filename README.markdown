# WebViewBridge

WebViewBridge shows how to create a two-way interface between Objective-C iOS app and JavaScript (hosted in a UIWebView).

Calling Javascript from Objective-C is relatively straight-forward, UIWebView provides a "stringByEvaluatingJavaScriptFromString:" method that you can use. Calling Objective-C from Javascript is a little bit more involved. The accepted technique is for Javascript to request to open a URL with a custom scheme, with the API parameters embedded in the URL resource. The Objective-C UIWebView delegate can then intercept this request, decode the parameters and perform some functionality based on the request.

## Calling Objective-C from Javascript

### Step 1: Register a handler in Objective-C

	[self addHandler:^(id args) {
		[[[[UIAlertView alloc] initWithTitle:NULL message:[NSString stringWithFormat:@"%@", args] delegate:NULL cancelButtonTitle:@"OK" otherButtonTitles:NULL] autorelease] show];
	    return((id)@"Hi javascript (from Cocoa)");
		} forIdentifier:@"test"];

### Step 2: Call the script object

	window.scriptObject.call('test', 'hello cocoa (from Javascript)', function (args) { alert(args); });

## Callbacks

TODO

## Dependencies

* TouchJSON: http://touchcode.com/
* mootools: http://mootools.net/
* PLBlocks: http://code.google.com/p/plblocks/

All dependencies except for PLBlocks are included in the project (in the case of TouchJSON via a git submodule). Go fetch PLBlocks and install. On iPhone OS 4.0 and higher you shouldn't need PLBlocks

## Exercises for the Reader

* Modify html so it can load in desktop safari correctly (currently it tries to load a custom URL on load complete)

* Refactor code to make it less "sample codey" and more standalone.

* Remove mootools requirement. mootools is merely used to help with class creation in Javascript.

* Currently this is an iOS 3.2 application that uses PLBlocks. It is possible to remove the block usage from the app and just send Objective-C messages directly. Blocks are definitely a big part of the future of iOS and for this project.

* Update project (code should be identical) for iOS 4.x

* Stress test the API - how many API calls can this make from JS to ObjC per second. What happens when too many messages are sent? Are they dropped?

