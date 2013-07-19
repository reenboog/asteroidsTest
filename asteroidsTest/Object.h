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
    ComponentPool _componentsToAdd;
    ComponentPool _componentsToRemove;
private:
    void maybeAddComponents();
    void maybeRemoveComponents();
protected:
    void updateComponents(Float dt);
public:
    Object();
    virtual ~Object();
    
    void applyComponent(Component *component, Bool suspend = false);
    void detachComponent(Component *component);
};

// interfaces
// movable

class Movable /*: public virtual Object */ {
protected:
    Vector2 _pos;
public:
    void setPos(Vector2 pos);
    Vector2 getPos();
    
    Movable();
    virtual ~Movable();
};

// scalable

class Scalable {
protected:
    Float _scaleX;
    Float _scaleY;
public:
    Scalable();
    virtual ~Scalable();
    
    virtual void setScaleX(Float scale);
    Float getScaleX();
    
    void setScaleY(Float scale);
    Float getScaleY();
    
    void setScale(Float scale);
    Float getScale();
};

// rotatable

class Rotatable {
protected:
    Float _rotation;
public:
    Rotatable();
    virtual ~Rotatable();
    
    void setRotation(Float rotation);
    Float getRotation();
};

// hideable

class Hideable {
protected:
    Bool _hidden;
public:
    Hideable();
    virtual ~Hideable();
    
    Bool isHidden();
    void setHidden(Bool hidden);
};

// blendable

class Blendable {
protected:
    Color4B _color;
    UChar _alpha;
    
public:
    Blendable();
    virtual ~Blendable();
    
    virtual void setColor(const Color4B &color);
    Color4B getColor();
    
    UChar getAlpha();
    virtual void setAlpha(UChar alpha);
};

// texturable

class Texturable {
    Texturable();
};

// measurable

class Measurable {
protected:
    Size2 _contentSize;
    Float _contentRadius;
protected:
    Measurable();
    virtual ~Measurable();
public:
    virtual void setContentSize(const Size2 &size);
    virtual Size2 getContentSize();
    
    virtual void setContentRadius(Float radius);
    virtual Float getContentRadius();
};

// intersectable

class Intersectable: public Movable, public Measurable {
protected:
    Intersectable();
    virtual ~Intersectable();
public:
    virtual Bool pointInArea(const Vector2 &pt);
    virtual Bool intersectsWithObject(Intersectable *obj);
};

#endif /* defined(__asteroidsTest__Object__) */
