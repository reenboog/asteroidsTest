//
//  Mesh.cpp
//  asteroidsTest
//
//  Created by Alex Gievsky on 16.07.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#include "Mesh.h"

Mesh::Mesh(): Node(), Blendable() {
    _lineWidth = 10.0;
}

Mesh::~Mesh() {
    
}

void Mesh::setLineWidth(Float width) {
    _lineWidth = width;
}

void Mesh::setAlpha(UChar alpha) {
    Blendable::setAlpha(alpha);
    
    for(auto it = _vertices.begin(); it != _vertices.end(); ++it) {
        it->color.a = _alpha;
    }
}

Float Mesh::getLineWidth() {
    return  _lineWidth;
}

Bool Mesh::setVertex(UInt index, const VertexPosColor &vertex, Bool skipColor) {
    
    // allow changing current vertices and pushing right back the new one
    if(index > _vertices.size()) {
        return false;
    } else if(index == _vertices.size()) {
        _vertices.push_back(vertex);
    } else {
        _vertices[index] = vertex;
    }
    
    if(skipColor) {
        _vertices[index].color = _color;
    }
    
    return true;
}

void Mesh::setColor(const Color4B &color) {
    Blendable::setColor(color);
    
    for(auto it = _vertices.begin(); it != _vertices.end(); ++it) {
        it->color = _color;
    }
}

void Mesh::render() {
    if(_vertices.size() < 2) {
        return;
    }
    
    Node::render();
    
    glLineWidth(_lineWidth);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    Int offset = (Int)_vertices.data();
    Int diff = offsetof(VertexPosColor, pos);
#define kMeshVertexStride sizeof(VertexPosColor)
	glVertexPointer(3, GL_FLOAT, kMeshVertexStride, (void *) (offset + diff));
    
    diff = offsetof(VertexPosColor, color);
	glColorPointer(4, GL_UNSIGNED_BYTE, kMeshVertexStride, (void *)(offset + diff));
    
	glDrawArrays(GL_LINE_STRIP, 0, _vertices.size());
    // what about fake smooth caps?
    glEnable(GL_POINT_SMOOTH);
    glPointSize(_lineWidth * 0.95);
    glDrawArrays(GL_POINTS, 0, _vertices.size());
    
    glDisable(GL_BLEND);
}