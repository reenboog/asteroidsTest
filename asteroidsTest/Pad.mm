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
    this->addChild(_img);
}

void Pad::applyDisplacement(const Vector2 &d) {
    
}

Vector2 Pad::getValue() {
    return _value;
}