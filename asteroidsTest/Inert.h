//
//  Inert.h
//  asteroidsTest
//
//  Created by Alex Gievsky on 18.07.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#ifndef __asteroidsTest__Inert__
#define __asteroidsTest__Inert__

#include "Component.h"
#include "Object.h"

class Inert: public Component, public InstanceCollector<Inert> {
private:
protected:
    Vector2 _velocity;
protected:
    Inert(const Vector2 &v);
    virtual ~Inert();
public:
    void setUp();
    void tick(Float dt);
    
    static Component * runWithVelocity(const Vector2 &v);
};

Inert::~Inert(){
}

Inert::Inert(const Vector2 &v): Component(), InstanceCollector<Inert>(this) {
    _velocity = v;
}

Component * Inert::runWithVelocity(const Vector2 &v) {
    return new Inert(v);
}

void Inert::setUp() {
}

void Inert::tick(Float dt) {
    Movable *t = dynamic_cast<Movable *>(_target);
    Vector2 pos = t->getPos() + (_velocity * dt);
    
    t->setPos(pos);
}

template class InstanceCollector<Inert>;

#endif /* defined(__asteroidsTest__Inert__) */
