//
//  Sprite.cpp
//  match3Test
//
//  Created by Alex Gievsky on 18.06.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#import "Sprite.h"
#import "TextureManager.h"
#import "Types.h"
#import "Common.h"

Sprite::~Sprite() {
    if(_texture.texture != -1) {
        glDeleteTextures(1, &_texture.texture);
    }

    printf("-sprite %s destroyed. \n", _file.c_str());
}

Sprite::Sprite(): Node(), Blendable() {
}

Sprite::Sprite(string file): Sprite() {
    loadTexture(file, 0, 0, -1, -1);
}

Sprite::Sprite(string file, Int x, Int y, Int w, Int h): Sprite() {
    
    loadTexture(file, x, y, w, h);
}

void Sprite::loadTexture(string file, Float x, Float y, Float width, Float height) {
    _anchorPoint = v2(0.5, 0.5);
    
    _file = file;
    
    _texture = TextureManager::mngr()->textureByName(file);
    
    GLint tWidth = _texture.width;
    GLint tHeight = _texture.height;
    
    _size.w = (width == -1 ? tWidth : width);
    _size.h = (height == -1 ? tHeight : height);
    
    setColor(_color);
    
    //apply tex coords
    _quad.br.uv = {(x + _size.w) / tWidth, (y + _size.h) / tHeight};
    _quad.tr.uv = {(x + _size.w) / tWidth, y / tHeight};
    _quad.tl.uv = {x / tWidth, y / tHeight};
    _quad.bl.uv = {x / tWidth, (y + _size.h) / tHeight};
    
    updateQuad();

    printf("+sprite %s created. \n", _file.c_str());
}

Size2 Sprite::getSize() {
    return _size;
}

void Sprite::cleanup() {
    
}

void Sprite::render() {
    Node::render();
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glEnable(GL_BLEND);
    glEnable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, _texture.texture);
    
    Int offset = (Int)&_quad;
    Int diff = offsetof(VertexPosColorUV, pos);
    
#define kQuadVertexStride sizeof(_quad.bl)
	glVertexPointer(3, GL_FLOAT, kQuadVertexStride, (void *) (offset + diff));
    
    diff = offsetof(VertexPosColorUV, color);
	glColorPointer(4, GL_UNSIGNED_BYTE, kQuadVertexStride, (void *)(offset + diff));
    
    Color4B col = _color;
    
    diff = offsetof(VertexPosColorUV, uv);
	glTexCoordPointer(2, GL_FLOAT, kQuadVertexStride, (void *)(offset + diff));
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    glDisable(GL_TEXTURE_2D);
    glDisable(GL_BLEND);
}

Bool Sprite::update(Float dt) {
    return true;
}

void Sprite::setUV(Float u0, Float v0, Float u1, Float v1) {
    _quad.br.uv.u = u1; _quad.br.uv.v = v1;
    _quad.tr.uv.u = u1; _quad.tr.uv.v = v0;
    _quad.tl.uv.u = u0; _quad.tl.uv.v = v0;
    _quad.bl.uv.u = u0; _quad.bl.uv.v = v1;
}

void Sprite::updateQuad() {
    Vector2 anchorCorrection = v2((0.5 - _anchorPoint.x) * _size.w, (0.5 - _anchorPoint.y) * _size.h);
    
    Float hw = _size.w / 2.0;
    Float hh = _size.h / 2.0;
    
    _quad.br.pos = Vector3{hw + anchorCorrection.x, hh + anchorCorrection.y, 0};
    _quad.tr.pos = Vector3{hw + anchorCorrection.x, -hh + anchorCorrection.y, 0};
    _quad.tl.pos = Vector3{-hw + anchorCorrection.x, -hh + anchorCorrection.y, 0};
    _quad.bl.pos = Vector3{-hw + anchorCorrection.x, hh + anchorCorrection.y, 0};
}

Vector2 Sprite::getAnchorPoint() {
    return _anchorPoint;
}

void Sprite::setAnchorPoint(Vector2 anchor) {
    _anchorPoint = anchor;
    
    updateQuad();
}

void Sprite::setColor(const Color4B &color) {
    Blendable::setColor(color);
    
    _quad.bl.color = _color;
    _quad.br.color = _color;
    _quad.tl.color = _color;
    _quad.tr.color = _color;
}

void Sprite::setAlpha(UChar alpha) {
    Blendable::setAlpha(alpha);
    
    setColor(_color);
}