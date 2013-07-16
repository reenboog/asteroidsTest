//
//  AppDelegate.h
//  asteroidsTest
//
//  Created by Alex Gievsky on 14.07.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpenGLView;
@class  RootViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    OpenGLView *_glView;
    UIWindow *_window;
    
    RootViewController *_viewController;
}

@property (retain, nonatomic) UIWindow *window;
@property (retain, nonatomic) OpenGLView *glView;
@property (retain, nonatomic) RootViewController *viewController;

@end
