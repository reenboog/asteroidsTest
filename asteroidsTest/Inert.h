//
//  Inert.h
//  asteroidsTest
//
//  Created by Alex Gievsky on 18.07.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#ifndef __asteroidsTest__Inert__
#define __asteroidsTest__Inert__

#import "Component.h"
#import "Object.h"

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
    
    void setVelocity(const Vector2 &v) {_velocity = v;};
    Vector2 getVelocity() {return _velocity;};
    
    static Component * runWithVelocity(const Vector2 &v);
};

inline Inert::~Inert(){
}

inline Inert::Inert(const Vector2 &v): Component(), InstanceCollector<Inert>(this) {
    _velocity = v;
}

inline Component * Inert::runWithVelocity(const Vector2 &v) {
    return new Inert(v);
}

inline void Inert::setUp() {
}

inline void Inert::tick(Float dt) {
    
    Movable *t = dynamic_cast<Movable *>(_target);
    Vector2 pos = t->getPos().add(_velocity.mul(dt));
    
    t->setPos(pos);
}

template class InstanceCollector<Inert>;

#endif /* defined(__asteroidsTest__Inert__) */
