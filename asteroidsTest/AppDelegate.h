//
//  AppDelegate.h
//  asteroidsTest
//
//  Created by Alex Gievsky on 14.07.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenGLView.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    OpenGLView *_glView;
}

@property (retain, nonatomic) UIWindow *window;
@property (retain, nonatomic) IBOutlet OpenGLView *glView;

@end
