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
        detachComponent(component);
    }
    
    _components.clear();
}

void Object::applyComponent(Component *component) {
    if(component) {
        _components.push_back(component);
        component->attachToTarget(this);
    }
}

void Object::detachComponent(Component *component) {
    if(component) {
        auto compIt = find(_components.begin(), _components.end(), component);
        
        if(compIt != _components.end()) {
            delete *compIt;
            _components.erase(compIt);
        }
    }
}

void Object::updateComponents(Float dt) {
    for(Component *component: _components) {
        component->update(dt);
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