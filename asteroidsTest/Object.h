//
//  Object.h
//  asteroidsTest
//
//  Created by Alex Gievsky on 16.07.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#ifndef __asteroidsTest__Object__
#define __asteroidsTest__Object__

#import "Types.h"

#include "Component.h"

//class Component;

class Object {
private:
    ComponentPool _components;
protected:
    void updateComponents(Float dt);
public:
    Object();
    virtual ~Object();
    
    void applyComponent(Component *component);
    void detachComponent(Component *component);
};

// interfaces

class Movable /*: public virtual Object */ {
protected:
    Vector2 _pos;
public:
    virtual void setPos(Vector2 pos) = 0;
    virtual Vector2 getPos() = 0;
};

//


#endif /* defined(__asteroidsTest__Object__) */
