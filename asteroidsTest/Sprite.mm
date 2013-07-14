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
    //------------------------------------------------
    printf("-sprite %s destroyed. \n", _file.c_str());
}

Sprite::Sprite() {
    
}

Sprite::Sprite(string file) {
    loadTexture(file, 0, 0, -1, -1);
}

Sprite::Sprite(string file, Int x, Int y, Int w, Int h) {
    
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
    
    Color4B tmpColor = {255, 255, 255, 255};
    
    _quad.bl.color = tmpColor;
    _quad.br.color = tmpColor;
    _quad.tl.color = tmpColor;
    _quad.tr.color = tmpColor;
    
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
    
    glEnable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, _texture.texture);
    
    Int offset = (Int)&_quad;
    Int diff = offsetof(Vertex, pos);
    
#define kQuadSize sizeof(_quad.bl)
	glVertexPointer(2, GL_FLOAT, kQuadSize, (void *) (offset + diff));
    
    diff = offsetof(Vertex, color);
	glColorPointer(4, GL_UNSIGNED_BYTE, kQuadSize, (void *)(offset + diff));
    
    diff = offsetof(Vertex, uv);
	glTexCoordPointer(2, GL_FLOAT, kQuadSize, (void *)(offset + diff));
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

//	glTexCoord2f(_uvCoords[0].u, _uvCoords[0].v);
//	glVertex3f(hw + anchorCorrection.x, hh + anchorCorrection.y, 0.0f);
//    
//	glTexCoord2f(_uvCoords[1].u, _uvCoords[1].v);
//	glVertex3f(hw + anchorCorrection.x, -hh + anchorCorrection.y, 0.0f);
//    
//	glTexCoord2f(_uvCoords[2].u, _uvCoords[2].v);
//	glVertex3f(-hw + anchorCorrection.x, -hh + anchorCorrection.y, 0.0f);
//    
//	glTexCoord2f(_uvCoords[3].u, _uvCoords[3].v);
//	glVertex3f(-hw + anchorCorrection.x, hh + anchorCorrection.y , 0.0f);
//    
//    glEnd();
    glDisable(GL_TEXTURE_2D);
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
    
    _quad.br.pos = Vector2{hw + anchorCorrection.x, hh + anchorCorrection.y};
    _quad.tr.pos = Vector2{hw + anchorCorrection.x, -hh + anchorCorrection.y};
    _quad.tl.pos = Vector2{-hw + anchorCorrection.x, -hh + anchorCorrection.y};
    _quad.bl.pos = Vector2{-hw + anchorCorrection.x, hh + anchorCorrection.y};
}

Vector2 Sprite::getAnchorPoint() {
    return _anchorPoint;
}

void Sprite::setAnchorPoint(Vector2 anchor) {
    _anchorPoint = anchor;
    
    updateQuad();
}
