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
    Color4B tmpColor = {255, 255, 255, 255};
    
    _quad.bl.color = tmpColor;
    _quad.br.color = tmpColor;
    _quad.tl.color = tmpColor;
    _quad.tr.color = tmpColor;
    
    _anchorPoint = {0.5, 0.5};
}

Sprite::Sprite(string file): Sprite() {
    loadTexture(file, 0, 0, -1, -1);
}

Sprite::Sprite(string file, Int x, Int y, Int w, Int h): Sprite() {
    
    loadTexture(file, x, y, w, h);
}

void Sprite::loadTexture(string file, Float x, Float y, Float width, Float height) {
    _anchorPoint = {0.5, 0.5};
    
    _file = file;
    
    _texture = TextureManager::mngr()->textureByName(file);
    
    GLint tWidth = _texture.width;
    GLint tHeight = _texture.height;
    
    Size2 size;
    size.w = (width == -1 ? tWidth : width);
    size.h = (height == -1 ? tHeight : height);
    
    setContentSize(size);
    // a very rough intersection check for sprites
    setContentRadius(size.w > size.h ? size.w : size.h);
    setColor(_color);
    
    // apply tex coords
    _quad.br.uv = {(x + size.w) / tWidth, (y + size.h) / tHeight};
    _quad.tr.uv = {(x + size.w) / tWidth, y / tHeight};
    _quad.tl.uv = {x / tWidth, y / tHeight};
    _quad.bl.uv = {x / tWidth, (y + size.h) / tHeight};
    
    updateQuad();

    printf("+sprite %s created. \n", _file.c_str());
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

void Sprite::setUV(const UVRect &uv) {
    _quad.br.uv.u = uv._1.u; _quad.br.uv.v = uv._1.v;
    _quad.tr.uv.u = uv._1.u; _quad.tr.uv.v = uv._0.v;
    _quad.tl.uv.u = uv._0.u; _quad.tl.uv.v = uv._0.v;
    _quad.bl.uv.u = uv._0.u; _quad.bl.uv.v = uv._1.v;
}

UVRect Sprite::getUV() {
    UVRect rect = {_quad.tl.uv, _quad.br.uv};
    
    return rect;
}

Bool Sprite::pointInArea(const Vector2 &pt) {
    Size2 size = getContentSize();
    Vector2 anchorCorrection = {_anchorPoint.x * size.w, _anchorPoint.y * size.h};

    Vector2 pos = _pos;
    
    pos.decrease(anchorCorrection);

    if((pos.x <= pt.x && pos.y < pt.y) && (pt.x <= pos.x + size.w && pt.y <= pos.y + size.h)) {
        return true;
    }
    
    return false;
}

void Sprite::updateQuad() {
    Size2 size = getContentSize();
    
    Vector2 anchorCorrection = {(0.5f - _anchorPoint.x) * size.w, (0.5f - _anchorPoint.y) * size.h};
    
    Float hw = size.w / 2.0;
    Float hh = size.h / 2.0;
    
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

// transformUV

TransformUV::~TransformUV() {
}

TransformUV::TransformUV(const Vector2 &v) {
    _velocity = v;
}

Component * TransformUV::runWithVelocity(const Vector2 &v) {
    return new TransformUV(v);
}

void TransformUV::setUp() {
    Sprite *t = dynamic_cast<Sprite *>(_target);
    _originalRect = t->getUV();
}

void TransformUV::tick(Float dt) {
    Sprite *t = dynamic_cast<Sprite *>(_target);
    UVRect uv = t->getUV();
    
    // bug: clamp texture coords to [0..1]!
    // uv overflow is possible!
    uv._0.u += _velocity.x * dt;
    uv._0.u += _velocity.y * dt;
    uv._1.u += _velocity.x * dt;
    uv._1.u += _velocity.y * dt;
    
    t->setUV(uv);
}
