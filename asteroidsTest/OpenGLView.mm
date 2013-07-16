//
//  OpenGLView.m
//  asteroidsTest
//
//  Created by Alex Gievsky on 14.07.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#import "OpenGLView.h"
#import "FilesUtils.h"
#import "TextureManager.h"

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
    
    delete _scene;
    _scene = nullptr;
    
    [_context release];
    _context = nil;
    
    [super dealloc];
}

//- (GLuint) compileShader: (NSString *) name withType: (GLenum) shaderType {
//    
//    NSString *shaderPath = [[NSBundle mainBundle] pathForResource: name ofType: @"glsl"];
//    NSError *error = NULL;
//    
//    NSString *shaderContents = [NSString stringWithContentsOfFile: shaderPath
//                                                         encoding: NSUTF8StringEncoding
//                                                            error: &error];
//    if(!shaderContents) {
//        NSLog(@"Error loading shader: %@", error.localizedDescription);
//        exit(1);
//    }
//    
//    GLuint shader = glCreateShader(shaderType);
//    const char *shaderStringUTF8 = [shaderContents UTF8String];
//    int shaderStringLength = shaderContents.length;
//    
//    glShaderSource(shader, 1, &shaderStringUTF8, &shaderStringLength);
//    glCompileShader(shader);
//    
//    GLint compileSuccess;
//    glGetShaderiv(shader, GL_COMPILE_STATUS, &compileSuccess);
//
//    if(compileSuccess == GL_FALSE) {
//        GLchar messages[256];
//        
//        glGetShaderInfoLog(shader, sizeof(messages), 0, &messages[0]);
//
//        NSString *messageString = [NSString stringWithUTF8String: messages];
//        NSLog(@"%@", messageString);
//        exit(1);
//    }
//    
//    return shader;
//}

//- (void) compileShaders {
//    GLuint vertexShader = [self compileShader: @"BasicVertex" withType: GL_VERTEX_SHADER];
//    GLuint fragmentShader = [self compileShader: @"BasicFragment" withType: GL_FRAGMENT_SHADER];
//    
//    GLuint programHandle = glCreateProgram();
//    glAttachShader(programHandle, vertexShader);
//    glAttachShader(programHandle, fragmentShader);
//    glLinkProgram(programHandle);
//    
//    GLint linkSuccess;
//    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
//
//    if(linkSuccess == GL_FALSE) {
//        GLchar messages[256];
//        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
//        NSString *messageString = [NSString stringWithUTF8String:messages];
//        NSLog(@"%@", messageString);
//        exit(1);
//    }
//    
//    glUseProgram(programHandle);
//    
//    _positionSlot = glGetAttribLocation(programHandle, "Position");
//    _colorSlot = glGetAttribLocation(programHandle, "SourceColor");
//    
//    glEnableVertexAttribArray(_positionSlot);
//    glEnableVertexAttribArray(_colorSlot);
//}

- (id) initWithFrame: (CGRect) frame {
    if((self = [super initWithFrame: frame])) {
        
        [self setupLayer];
        [self setupContext];
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        //[self compileShaders];
        
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
        
        //set up a scene

        [self setupDisplayLink];
        
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
    _scene->update(dt);
}

- (void) render {
    
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

@end
