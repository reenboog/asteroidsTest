//
//  Inert.mm
//  asteroidsTest
//
//  Created by Alex Gievsky on 18.07.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#include "Inert.h"
#include "Object.h"

Inert::InertPool Inert::__inerts;

Inert::~Inert(){
    __inerts.erase(remove(__inerts.begin(), __inerts.end(), this));
}

Inert::Inert(const Vector2 &v): Component() {
    _velocity = v;
    
    __inerts.push_back(this);
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