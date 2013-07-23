//
//  SurfaceManager.cpp
//  match3Test
//
//  Created by Alex Gievsky on 18.06.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#import "TextureManager.h"
#import "FilesUtils.h"

TextureManager* TextureManager::__instance = nullptr;

TextureManager::~TextureManager() {
    purge();
}

TextureManager::TextureManager() {
    //fake for a while
}

TextureManager* TextureManager::mngr() {
    if(__instance == nullptr) {
        __instance = new TextureManager();
    }
    
    return __instance;
}

void TextureManager::purge() {
    for(auto tex: _textures) {
        glDeleteTextures(1, &tex.second.texture);
    }
    
    _textures.clear();
}

Texture TextureManager::textureByName(const string &name) {
    
    NSString *fileName = [FilesUtils getFileName: [NSString stringWithFormat: @"%s", name.c_str()]
                                      skipIdioms: NO];
    
    auto it = _textures.find(fileName.UTF8String);
    
    if(it == _textures.end()) {
        CGImageRef image = [UIImage imageNamed: fileName].CGImage;
        
        if (!image) {
            NSLog(@"Error loading image: %@", fileName);
            exit(1);
        }
        
        //this stuff doesn't load npot textures, so no automatic padding importd for now
        
        size_t width = CGImageGetWidth(image);
        size_t height = CGImageGetHeight(image);
        
        GLubyte *imageData = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte));
        
        CGContextRef spriteContext = CGBitmapContextCreate(imageData, width, height, 8, width*4,
                                                           CGImageGetColorSpace(image), kCGImageAlphaPremultipliedLast);
        
        CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), image);
        
        CGContextRelease(spriteContext);
        
        GLuint texture;
        glGenTextures(1, &texture);
        glBindTexture(GL_TEXTURE_2D, texture);
        
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
        
        free(imageData);
        
        Texture tex{texture, static_cast<GLint>(width), static_cast<GLint>(height)};
        
        _textures.insert({fileName.UTF8String, tex});
        return tex;
        
    } else {
        return it->second;
    }
}