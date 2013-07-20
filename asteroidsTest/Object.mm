//
//  Object.mm
//  asteroidsTest
//
//  Created by Alex Gievsky on 16.07.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#include "Object.h"

Object::Object() {
    //
}

Object::~Object() {
    for(Component *component: _components) {
        delete component;
    }
    
    _components.clear();
}

void Object::maybeAddComponents() {
    if(!_componentsToAdd.empty()) {
        for(Component *component: _componentsToAdd) {
            _components.push_back(component);
        }
        
        _componentsToAdd.clear();
    }
}

void Object::maybeRemoveComponents() {
    if(!_componentsToRemove.empty()) {
        for(Component *component: _componentsToRemove) {
            _components.erase(remove(_components.begin(), _components.end(), component));
            delete component;
        }
        
        _componentsToRemove.clear();
    }
}

void Object::applyComponent(Component *component, Bool suspend) {
    if(component) {
        _componentsToAdd.push_back(component);
        // should I attach this in maybeAdd...?
        component->attachToTarget(this, suspend);
    }
}

void Object::detachComponent(Component *component) {
    if(component) {
        auto compIt = find(_components.begin(), _components.end(), component);
        
        if(compIt != _components.end()) {
            _componentsToRemove.push_back(component);
        }
    }
}

void Object::updateComponents(Float dt) {
    maybeAddComponents();
    
    for(Component *component: _components) {
        component->update(dt);
    }
    
    maybeRemoveComponents();
    
    for(Component *component: _components) {
        if(component->isAboutToDie()) {
            component->detachFromTarget();
        }
    }
}

// movable

Movable::Movable() {
    _pos = {0, 0};
}

Movable::~Movable() {
}

void Movable::setPos(Vector2 pos) {
    _pos = pos;
}

Vector2 Movable::getPos() {
    return _pos;
}

// sclable

Scalable::Scalable() {
    _scaleX = _scaleY = 1.0;
}

Scalable::~Scalable() {
}

void Scalable::setScaleX(Float scale) {
    _scaleX = scale;
}

Float Scalable::getScaleX() {
    return _scaleX;
}

void Scalable::setScaleY(Float scale) {
    _scaleY = scale;
}

Float Scalable::getScaleY() {
    return _scaleY;
}

void Scalable::setScale(Float scale) {
    _scaleX = _scaleY = scale;
}

Float Scalable::getScale() {
    if(_scaleX != _scaleY) {
        printf("!Trying to get scale but scaleX != scaleY");
    }
    
    return _scaleX;
}

// rotatable

Rotatable::Rotatable() {
    _rotation = 0;
}

Rotatable::~Rotatable() {
}

void Rotatable::setRotation(Float rotation) {
    _rotation = rotation;
}

Float Rotatable::getRotation() {
    return _rotation;
}

// hidable

Hideable::Hideable() {
    _hidden = false;
}

Hideable::~Hideable(){
}

Bool Hideable::isHidden() {
    return _hidden;
}

void Hideable::setHidden(Bool hidden) {
    _hidden = hidden;
}

// blendable

Blendable::Blendable() {
    _color = Color4B{255, 255, 255, 255};
    _alpha = 255;
}

Blendable::~Blendable(){
}

void Blendable::setColor(const Color4B &color) {
    _color = color;
}

Color4B Blendable::getColor() {
    return _color;
}

UChar Blendable::getAlpha() {
    return _alpha;
}

void Blendable::setAlpha(UChar alpha) {
    _alpha = alpha;
    _color.a = _alpha;
}

// measurable

Measurable::~Measurable(){
}

Measurable::Measurable() {
    _contentRadius = 0.0;
    _contentSize = {0, 0};
}

void Measurable::setContentSize(const Size2 &size) {
    _contentSize = size;
}

Size2 Measurable::getContentSize() {
    return _contentSize;
}

void Measurable::setContentRadius(Float radius) {
    _contentRadius = radius;
}

Float Measurable::getContentRadius() {
    return _contentRadius;
}

// intersectable

Intersectable::~Intersectable() {
}

Intersectable::Intersectable(): Movable(), Measurable() {
}

Bool Intersectable::pointInArea(const Vector2 &pt) {
    if((_pos.x <= pt.x && _pos.y < pt.y) && (pt.x <= _pos.x + _contentSize.w && pt.y <= _pos.y + _contentSize.h)) {
        return true;
    }
    
    return false;
}

Bool Intersectable::intersectsWithObject(Intersectable *obj) {
    Vector2 distance = this->getPos().sub(obj->getPos());
    
    return distance.length() <= (this->getContentRadius() + obj->getContentRadius());
}