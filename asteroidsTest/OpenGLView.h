//
//  OpenGLView.h
//  asteroidsTest
//
//  Created by Alex Gievsky on 14.07.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import <sys/time.h>

#import "Types.h"

class Scene;

@interface OpenGLView: UIView {
    CAEAGLLayer *_eaglLayer;
    EAGLContext *_context;
    GLuint _renderBuffer;
    
    GLuint _positionSlot;
    GLuint _colorSlot;
    
    Bool _isNextDeltaTimeZero;
    struct timeval *_lastUpdate;
    
    Scene *_scene;
}

- (void) update: (float) dt;
- (void) render;

@end
