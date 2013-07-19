//
//  OpenGLView.m
//  asteroidsTest
//
//  Created by Alex Gievsky on 14.07.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#import "OpenGLView.h"
#import "Common.h"
#import "Scene.h"

@implementation OpenGLView
+ (Class) layerClass {
    return [CAEAGLLayer class];
}

- (void) setupLayer {
    _eaglLayer = (CAEAGLLayer *)self.layer;
    _eaglLayer.opaque = YES;
}

- (void) setupContext {
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES1;
    _context = [[EAGLContext alloc] initWithAPI: api];

    if (!_context) {
        NSLog(@"Error initializing GL context");
        exit(1);
    }
    
    if (![EAGLContext setCurrentContext: _context]) {
        NSLog(@"Error applying GL context");
        exit(1);
    }
}

- (void) setupRenderBuffer {
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);

    [_context renderbufferStorage: GL_RENDERBUFFER fromDrawable: _eaglLayer];
}

- (void) setupFrameBuffer {
    GLuint framebuffer;
    
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
}

- (void) setupDisplayLink {
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget: self selector: @selector(onFrame:)];
    [displayLink addToRunLoop: [NSRunLoop currentRunLoop] forMode: NSDefaultRunLoopMode];
}

// Replace dealloc method with this
- (void) dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    delete _scene;
    _scene = nullptr;
    
    [_context release];
    _context = nil;
    
    [super dealloc];
}

- (void) onEnterBackground {
    _readyToRender = false;
}

- (void) onEnterForeground {
    gettimeofday(&_lastUpdate,  0);
    
    _readyToRender = true;
}

- (id) initWithFrame: (CGRect) frame {
    if((self = [super initWithFrame: frame])) {
        
        _readyToRender = false;
        
        [self setupLayer];
        [self setupContext];
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        
        // enable multiple touches
        self.multipleTouchEnabled = YES;
        
        gettimeofday(&_lastUpdate,  0);
        
        CGRect screenBounds = frame;
        
        glViewport(0, 0, screenBounds.size.width, screenBounds.size.height);
        
        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();
        
        glOrthof(0, screenBounds.size.width, 0, screenBounds.size.height, -1, 1);
        
        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();
        
        //glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
        
        glEnableClientState(GL_VERTEX_ARRAY);
        glEnableClientState(GL_COLOR_ARRAY);
        glEnableClientState(GL_TEXTURE_COORD_ARRAY);
        
        glClearColor(0, 0, 0, 1.0);

        // reset timers when leaving active state
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(onEnterForeground)
                                                     name: UIApplicationDidBecomeActiveNotification
                                                   object: nil];
        
        //disable display link when entering background
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(onEnterBackground)
                                                     name: UIApplicationDidEnterBackgroundNotification
                                                   object: nil];

        [self setupDisplayLink];
        
        // set up a scene
        _scene = new Scene;
        _scene->init();
    }
    return self;
}

- (void) onFrame: (CADisplayLink *) displayLink {
    
    Float dt = 0;
    
    struct timeval now;
    gettimeofday(&now,  0);
    
    if(_isNextDeltaTimeZero) {
        dt = 0;
        _isNextDeltaTimeZero = NO;
    } else {
        dt = (now.tv_sec - _lastUpdate.tv_sec) + (now.tv_usec - _lastUpdate.tv_usec) / 1000000.0f;
        dt = MAX(0, dt);
    }
    
    //NSLog(@"duration: %f", (float)dt);
    
    [self update: dt];
    [self render];
    
    _lastUpdate = now;
}

- (void) update: (float) dt {
    _scene->loop(dt);
}

- (void) render {
    if(!_readyToRender) {
        return;
    }
    
    glClear(GL_COLOR_BUFFER_BIT);
    
    _scene->visit();
    
    
    
//    const GLfloat lineX[] = {
//        0.0f, 0.0f, 0.0f, //point A
//        200.0f, 400.0f, 0.0f //point B
//    };
// 
//    
//    glPushMatrix();
//    
//    glTranslatef(0, 0, 0.0);
//
    
//
//    glColor4f(1.0f, 0.0f, 0.0f, 1.0f); // opaque red
//    glVertexPointer(3, GL_FLOAT, 0, lineX);
//    glDrawArrays(GL_LINES, 0, 2);
//    
//        
//    //glDisableClientState(GL_VERTEX_ARRAY);
//    
//    glPopMatrix();
    

    [_context presentRenderbuffer: GL_RENDERBUFFER];
}

#pragma mark - touches

- (void) touchesBegan: (NSSet *) touches withEvent: (UIEvent *) event {
    Vector2Pool positions;
    
    CGRect bounds = GetBounds();
    
    for(UITouch *touch in touches) {
        CGPoint touchLocation = [touch locationInView: self];
        positions.push_back({touchLocation.x, bounds.size.height - touchLocation.y});
    }
    
    _scene->touchesBegan(positions);
}

- (void) touchesMoved: (NSSet *) touches withEvent: (UIEvent *) event {
    Vector2Pool positions;
    
    CGRect bounds = GetBounds();
    
    for(UITouch *touch in touches) {
        CGPoint touchLocation = [touch locationInView: self];
        positions.push_back({touchLocation.x, bounds.size.height - touchLocation.y});
    }
    
    _scene->touchesMoved(positions);
}

- (void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event {
    Vector2Pool positions;
    
    CGRect bounds = GetBounds();
    
    for(UITouch *touch in touches) {
        CGPoint touchLocation = [touch locationInView: self];
        positions.push_back({touchLocation.x, bounds.size.height - touchLocation.y});
    }
    
    _scene->touchesEnded(positions);
}

- (void) touchesCancelled: (NSSet *) touches withEvent:(UIEvent *) event {
    Vector2Pool positions;
    
    CGRect bounds = GetBounds();
    
    for(UITouch *touch in touches) {
        CGPoint touchLocation = [touch locationInView: self];
        positions.push_back({touchLocation.x, bounds.size.height - touchLocation.y});
    }
    
    _scene->touchesCancelled(positions);
}

@end
