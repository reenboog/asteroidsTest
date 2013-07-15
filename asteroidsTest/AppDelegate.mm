//
//  AppDelegate.m
//  asteroidsTest
//
//  Created by Alex Gievsky on 14.07.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize glView = _glView;
@synthesize window = _window;
@synthesize viewController = _viewController;

- (void) dealloc {
    self.glView = nil;
    self.viewController = nil;
    self.window = nil;

    [super dealloc];
}

- (BOOL) application: (UIApplication *) application didFinishLaunchingWithOptions: (NSDictionary *) launchOptions {
    CGRect bounds = [[UIScreen mainScreen] bounds];
    
    // rotate bounds since we have a landscape-oriented game
    bounds = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.height, bounds.size.width);
    
    _window = [[UIWindow alloc] initWithFrame: bounds];
    _glView = [[OpenGLView alloc] initWithFrame: bounds];

    _viewController = [[RootViewController alloc] initWithNibName: nil bundle: nil];
    _viewController.wantsFullScreenLayout = YES;
    _viewController.view = _glView;
    
    if([[UIDevice currentDevice].systemVersion floatValue] < 6.0) {
        [_window addSubview: _viewController.view];
    } else {
        [_window setRootViewController: _viewController];
    }

    
    [_window makeKeyAndVisible];

    return YES;
}

- (void) applicationWillResignActive: (UIApplication *) application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void) applicationDidEnterBackground: (UIApplication *) application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void) applicationWillEnterForeground: (UIApplication *) application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void) applicationDidBecomeActive: (UIApplication *) application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void) applicationWillTerminate: (UIApplication *) application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end