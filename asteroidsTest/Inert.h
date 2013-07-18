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

class Inert: public Component {
private:
    typedef vector<Inert *> InertPool;
    static InertPool __inerts;
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

#endif /* defined(__asteroidsTest__Inert__) */
