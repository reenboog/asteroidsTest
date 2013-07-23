//
//  Label.m
//  asteroidsTest
//
//  Created by Alex Gievsky on 15.07.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Label.h"

#import "Texture2d.h"

Label::Label(const string &str, Float fontSize, const string &font): Sprite() {
    _fontSize = fontSize;
    _font = font;
    _tex = nil;
    
    setString(str);
}

Label::~Label() {
    //glDeleteTextures(1, &_texture);
}

void Label::setString(const string &str) {
    if(_tex) {
        [_tex release];
        _texture.texture = -1;
    }
    _string = str;
    
    glColor4f(0, 0, 0, 1.0);
    
    
    
    UIFont *font = [UIFont fontWithName: [NSString stringWithFormat: @"%s", _font.c_str()]
                                   size: _fontSize];

    NSString *s = [NSString stringWithFormat: @"%s", _string.c_str()];
    CGSize dim = [s sizeWithFont: font];
    
    _tex = [[Texture2D alloc] initWithString: s
                                  dimensions: dim
                                   alignment: (UITextAlignment)UITextAlignmentLeft
                                    fontName: [NSString stringWithFormat: @"%s", _font.c_str()]
                                    fontSize: _fontSize];
    
    _texture.texture = [_tex name];
    _texture.width = _tex.pixelsWide;
    _texture.height = _tex.pixelsHigh;
    
    setContentSize({dim.width, dim.height});
    setContentRadius(dim.width * 0.6);

    updateQuad();
    setUV(0, 0, _tex.maxS, _tex.maxT);
}

string Label::getString() {
    return _string;
}

void Label::render() {
    Node::render();
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glEnable(GL_BLEND);
    glEnable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, _texture.texture);
    
    Int offset = (Int)&_quad;
    Int diff = offsetof(VertexPosColorUV, pos);
    
#define kQuadSize sizeof(_quad.bl)
	glVertexPointer(3, GL_FLOAT, kQuadSize, (void *) (offset + diff));
    
    diff = offsetof(VertexPosColorUV, color);
	glColorPointer(4, GL_UNSIGNED_BYTE, kQuadSize, (void *)(offset + diff));
    
    diff = offsetof(VertexPosColorUV, uv);
	glTexCoordPointer(2, GL_FLOAT, kQuadSize, (void *)(offset + diff));
    
    glScalef(getScaleX(), getScaleY() * -1, 1.0);
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    glDisable(GL_TEXTURE_2D);
    glDisable(GL_BLEND);
}
