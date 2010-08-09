//
//  WebViewBridgeAppDelegate.m
//  WebViewBridge
//
//  Created by Jonathan Wight on 08/07/10.
//  Copyright (c) 2010 toxicsoftware.com. All rights reserved.
//


#import "WebViewBridgeAppDelegate.h"

#import "CMainViewController.h"

@interface WebViewBridgeAppDelegate () <UIApplicationDelegate>
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (readwrite, retain) UIViewController *rootViewController;
@end

#pragma mark -

@implementation WebViewBridgeAppDelegate

@synthesize window;
@synthesize rootViewController;

- (void)dealloc
	{
	[window release];
	window = NULL;
	//
    [super dealloc];
	}

#pragma mark -

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
	{	
	[self.window makeKeyAndVisible];

	self.rootViewController = [[[CMainViewController alloc] init] autorelease];
	self.rootViewController.view.frame = [UIScreen mainScreen].applicationFrame;
	[self.window addSubview:self.rootViewController.view];
		
    return YES;
	}

- (void)applicationWillTerminate:(UIApplication *)application
	{
	}

@end

