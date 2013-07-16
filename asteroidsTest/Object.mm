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
            _components.erase(compIt);
            
            delete *compIt;
        }
    }
}

void Object::updateComponents(Float dt) {
    for(Component *component: _components) {
        component->update(dt);
    }
}