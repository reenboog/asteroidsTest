//
//  Collidable.h
//  asteroidsTest
//
//  Created by Alex Gievsky on 19.07.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#ifndef asteroidsTest_Collidable_h
#define asteroidsTest_Collidable_h

#import "Component.h"
#import "Object.h"
#import "Types.h"

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

inline Collider::~Collider() {
}

inline Collider::Collider(Void_IntersectableFunc block): Component(), InstanceCollector<Collider>(this) {
    _block = block;
}

inline Component * Collider::runWithBlock(Void_IntersectableFunc block) {
    return new Collider(block);
}

inline void Collider::setUp() {
    
}

inline void Collider::tick(Float dt) {
    // this is a very rough calculation
    // this component can be applied to Intersectable inheritors only
    for(Collider *collider: __instances) {
        Intersectable *t = dynamic_cast<Intersectable *>(_target);
        Intersectable *colliderTarget = dynamic_cast<Intersectable *>(collider->getTarget());
        
        if(t != colliderTarget && !collider->isAboutToDie() && collider->isRunning() && t->intersectsWithObject(colliderTarget)) {
//            printf("1: %f, %f\n", t->getPos().x, t->getPos().y);
//            printf("2: %f, %f\n", colliderTarget->getPos().x, colliderTarget->getPos().y);
            _block(colliderTarget);
        }
    }
}

template class InstanceCollector<Collider>;

#endif