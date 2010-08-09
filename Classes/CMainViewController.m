//
//  CMainViewController.m
//  WebViewBridge
//
//  Created by Jonathan Wight on 08/07/10.
//  Copyright (c) 2010 toxicsoftware.com. All rights reserved.
//

#import "CMainViewController.h"

#import "CJSONDeserializer.h"
#import "CJSONSerializer.h"

@interface CMainViewController () <UIWebViewDelegate>
@property (readwrite, retain) IBOutlet UIWebView *webView;
@property (readwrite, retain) IBOutlet NSMutableDictionary *scriptHandlers;

- (void)addHandler:(id(^)(id args))inHandler forIdentifier:(NSString *)inIdentifier;
@end

#pragma mark -

@implementation CMainViewController

@synthesize webView;
@synthesize scriptHandlers;

- (id)init
	{
    if ((self = [super initWithNibName:NSStringFromClass([self class]) bundle:NULL]) != NULL)
		{
		scriptHandlers = [[NSMutableDictionary alloc] init];
		
		}
    return(self);
	}
	
- (void)dealloc
	{

	//    
	[super dealloc];
	}
	
- (void)viewDidLoad
	{
	[super viewDidLoad];

	__block CMainViewController *_self = self;

	[self addHandler:^(id args) { fprintf(stderr, "%s", [[args description] UTF8String]); return((id)NULL); } forIdentifier:@"_console_log"];
	[self addHandler:^(id args) { NSLog(@"DOM READY"); [_self.webView stringByEvaluatingJavaScriptFromString:@"console = new FakeConsole();"]; return((id)NULL); } forIdentifier:@"_domready"];
	[self addHandler:^(id args) {
		[[[[UIAlertView alloc] initWithTitle:NULL message:[NSString stringWithFormat:@"%@", args] delegate:NULL cancelButtonTitle:@"OK" otherButtonTitles:NULL] autorelease] show];
	    return((id)@"Hi javascript (from Cocoa)");
		} forIdentifier:@"test"];

	
	[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"]]]];
	}

- (void)addHandler:(id(^)(id args))inHandler forIdentifier:(NSString *)inIdentifier
	{
	id theCopy = [[inHandler copy] autorelease];
	[self.scriptHandlers setObject:theCopy forKey:inIdentifier];
	}
	
#if 0
// TODO: JIW not working yet
- (void)injectJavascript:(NSURL *)inURL
	{
	NSString *theScript = [NSString stringWithFormat:@"try { var headID = document.getElementsByTagName('head')[0]; \
		var newScript = document.createElement('script'); \
		newScript.type = 'text/javascript'; \
		newScript.src = '%@'; \
		headID.appendChild(newScript); } catch (e) { alert(e); }", [inURL absoluteString]];
		//newScript.onload=scriptLoaded; \
//	NSLog(@"%@", theScript);
	NSString *theResult = [self.webView stringByEvaluatingJavaScriptFromString:theScript];
	NSLog(@"%@", theResult);
	}
#endif	

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
	{
	NSLog(@"%@", request);
	
	if ([request.URL.scheme isEqualToString:@"x-script-call"])
		{
		NSString *theString = [(id)CFURLCreateStringByReplacingPercentEscapes(NULL, (CFStringRef)request.URL.resourceSpecifier, CFSTR("")) autorelease];
		NSData *theData = [theString dataUsingEncoding:NSUTF8StringEncoding];
		NSError *theError = NULL;
		id theObject = [[CJSONDeserializer deserializer] deserialize:theData error:&theError];
		NSString *theIdentifier = [theObject objectForKey:@"id"];
		id(^theHandler)(id) = [self.scriptHandlers objectForKey:theIdentifier];
		if (theHandler == NULL)
			{
			NSLog(@"No handler found for: %@", theIdentifier);
			}

		if (theHandler)
			{
			id theArguments = [theObject objectForKey:@"args"];
			id theResult = theHandler(theArguments);

			NSString *theUUID = [theObject objectForKey:@"callback_uuid"];
			if (theUUID)
				{
				NSString *theString = [[CJSONSerializer serializer] serializeObject:theResult error:&theError];
				
				NSString *theScript = [NSString stringWithFormat:@"window.scriptObject.callback(\"%@\", %@)", theUUID, theString];
				NSString *theResult = [self.webView stringByEvaluatingJavaScriptFromString:theScript];
				NSData *theData = [theResult dataUsingEncoding:NSUTF8StringEncoding];
				
				NSError *theError = NULL;
				id theObject = [[CJSONDeserializer deserializer] deserialize:theData error:&theError];
				NSLog(@"Callback response: %@", theObject);
				}
			}
		
		
		return(NO);
		}
	return(YES);
	}

- (void)webViewDidStartLoad:(UIWebView *)webView
	{
	}
	
- (void)webViewDidFinishLoad:(UIWebView *)webView
	{
//	[self injectJavascript:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"mootools-1.2.4-core-nc" ofType:@"js"]]];
//	[self injectJavascript:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"scriptobject" ofType:@"js"]]];
	}
	
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
	{
	NSLog(@"DID FAIL: %@", error);
	}

@end
