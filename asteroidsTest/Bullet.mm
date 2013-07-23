//
//  Bullet.mm
//  asteroidsTest
//
//  Created by Alex Gievsky on 22.07.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#import "Bullet.h"

Bullet::~Bullet() {
}

Bullet::Bullet(Float lifeTime, Float size, Color4B color, const Vector2 &velocity, Bool smoothed, Void_IntersectableFunc onCollision): Mesh() {
    _lifeTime = lifeTime;
    _pointSize = size;
    _smoothed = smoothed;
    
    Float scale = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 1.0 : 0.5;
    
    _pointSize *= scale;
    
    setVertex(0, {{0.0, 0.0, 0.0}, {0, 0, 0, 0}});
    
    setColor(color);
    setAlpha(0);
    setScale(0.0001);
    
    this->applyComponent(Inert::runWithVelocity(velocity));
    this->applyComponent(Collider::runWithBlock(onCollision));
    // would be better to use a sequence of delay and a block instead
    this->applyComponent(ScheduledBlock::runWithDelay(_lifeTime, [this](){
        this->removeFromParent();
    }));
    
    this->applyComponent(GroupComponent::runWithComponents({
        FadeTo::runWithAlpha(color.a, 0.1)
    }));
}

void Bullet::render() {
    if(_vertices.size() < 1) {
        return;
    }
    
    Node::render();
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    Int offset = (Int)_vertices.data();
    Int diff = offsetof(VertexPosColor, pos);
#define kMeshVertexStride sizeof(VertexPosColor)
	glVertexPointer(3, GL_FLOAT, kMeshVertexStride, (void *) (offset + diff));
    
    diff = offsetof(VertexPosColor, color);

    if(_smoothed) {
        glEnable(GL_POINT_SMOOTH);
    }
    
    glPointSize(_pointSize);

    glColorPointer(4, GL_UNSIGNED_BYTE, kMeshVertexStride, (void *)(offset + diff));
    glDrawArrays(GL_POINTS, 0, _vertices.size());
    
    glDisable(GL_BLEND);
    
    if(_smoothed) {
        glDisable(GL_POINT_SMOOTH);
    }

}