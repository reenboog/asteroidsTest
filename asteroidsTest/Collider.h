//
//  Collidable.h
//  asteroidsTest
//
//  Created by Alex Gievsky on 19.07.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#ifndef asteroidsTest_Collidable_h
#define asteroidsTest_Collidable_h

#include "Component.h"
#include "Object.h"
#include "Types.h"

class Collider: public Component, public InstanceCollector<Collider> {
protected:
    Void_IntersectableFunc _block;
protected:
    Collider(Void_IntersectableFunc block);
    virtual ~Collider();
    
    void setUp();
    void tick(Float dt);
    
public:
    static Component * runWithBlock(Void_IntersectableFunc block);
};

Collider::~Collider() {
}

Collider::Collider(Void_IntersectableFunc block): Component(), InstanceCollector<Collider>(this) {
    _block = block;
}

Component * Collider::runWithBlock(Void_IntersectableFunc block) {
    return new Collider(block);
}

void Collider::setUp() {
    
}

void Collider::tick(Float dt) {
    // this is a very rough calculation
    // this component can be applied to Intersectable inheritors only
    for(Collider *collider: __instances) {
        Intersectable *t = dynamic_cast<Intersectable *>(_target);
        Intersectable *colliderTarget = dynamic_cast<Intersectable *>(collider->getTarget());
        
        if(t != colliderTarget && !collider->isAboutToDie() && collider->isRunning() && t->intersectsWithObject(colliderTarget)) {
            _block(colliderTarget);
        }
    }
}

template class InstanceCollector<Collider>;

#endif