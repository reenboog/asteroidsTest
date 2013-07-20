//
//  Pad.mm
//  asteroidsTest
//
//  Created by Alex Gievsky on 20.07.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#include "Pad.h"

Pad::~Pad() {
}

Pad::Pad(const string &file, Void_VoidFunc block): Node() {
    _block = block;
    
    _img = new Sprite(file);
    _img->setContentSize(_img->getContentSize().mul(3));
    this->addChild(_img);
}

void Pad::applyDisplacement(const Vector2 &d) {
    //
    Vector2 localTouchCoords = this->getLocationInLocalSpace(d);
    
    if(_img->pointInArea(localTouchCoords)) {
        Float touchLength = localTouchCoords.length();

        localTouchCoords.normalize();
        localTouchCoords = localTouchCoords.mul(MIN(touchLength, kMaxPadDisplacement));
        
        _img->setPos(localTouchCoords);
        
        _value = _img->getPos();
    }
    
    _block();
}

Vector2 Pad::getValue() {
    return _value;
}