//
//  Mesh.cpp
//  asteroidsTest
//
//  Created by Alex Gievsky on 16.07.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#include "Mesh.h"

Mesh::Mesh() {
    _lineWidth = 10.0;
}

Mesh::~Mesh() {
    
}

void Mesh::setLineWidth(Float width) {
    _lineWidth = width;
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
    _color = color;
    
    for(auto it = _vertices.begin(); it != _vertices.end(); ++it) {
        it->color = _color;
    }
}

Color4B Mesh::getColor() {
    return _color;
}

void Mesh::render() {
    if (_vertices.size() < 2) {
        return;
    }
    
    Node::render();
    
    //glDisable(GL_TEXTURE_2D);
    
    glLineWidth(_lineWidth);
    
    Int offset = (Int)_vertices.data();
    Int diff = offsetof(VertexPosColor, pos);
#define kMeshVertexStride sizeof(VertexPosColor)
	glVertexPointer(3, GL_FLOAT, kMeshVertexStride, (void *) (offset + diff));
    
    diff = offsetof(VertexPosColor, color);
	glColorPointer(4, GL_UNSIGNED_BYTE, kMeshVertexStride, (void *)(offset + diff));
    
	glDrawArrays(GL_LINE_STRIP, 0, _vertices.size() - 1);
}