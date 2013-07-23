//
//  Pad.mm
//  asteroidsTest
//
//  Created by Alex Gievsky on 20.07.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#import "Pad.h"

Pad::~Pad() {
}

Pad::Pad(const string &file, Float maxScale, Void_VoidFunc began, Void_VoidFunc ended, Void_VoidFunc moved): Node() {
    _touchBeganBlock = began;
    _touchEndedBlock = ended;
    _touchMovedBlock = moved;
    _maxScale = maxScale;
    
    _img = new Sprite(file);
    _img->setContentSize(_img->getContentSize().mul(3));
    _img->setAlpha(100);
    this->addChild(_img);
}

void Pad::touchBegan(const Vector2 &d) {
    //
    Vector2 localTouchCoords = this->getLocationInLocalSpace(d);
    
    if(_img->pointInArea(localTouchCoords)) {
        _img->setAlpha(60);
        _touchBeganBlock();
    }
}

void Pad::touchMoved(const Vector2 &d) {
    Vector2 localTouchCoords = this->getLocationInLocalSpace(d);
    
    if(_img->pointInArea(localTouchCoords)) {
        Float touchLength = localTouchCoords.length();
        
        localTouchCoords.normalize();
        localTouchCoords = localTouchCoords.mul(MIN(touchLength, kMaxPadDisplacement));
        
        _img->setPos(localTouchCoords);
        
        _value = _img->getPos().mul(_maxScale);
        
        _touchMovedBlock();
    }
}

void Pad::touchEnded(const Vector2 &d) {
    //
    Vector2 localTouchCoords = this->getLocationInLocalSpace(d);
    
    if(_img->pointInArea(localTouchCoords)) {
        _img->setAlpha(100);
        _touchEndedBlock();
    }
}

Vector2 Pad::getValue() {
    return _value;
}

