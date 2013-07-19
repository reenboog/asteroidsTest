//
//  Pad.h
//  asteroidsTest
//
//  Created by Alex Gievsky on 20.07.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#ifndef __asteroidsTest__Pad__
#define __asteroidsTest__Pad__

#include "Sprite.h"

#define kMaxPadDisplacement 200

class Pad: public Node {
private:
    Sprite *_img;
    
    Vector2 _value;
    
    Void_VoidFunc _block;
public:
    virtual ~Pad();
    Pad(const string &file, Void_VoidFunc block);
    
    void applyDisplacement(const Vector2 &d);
    Vector2 getValue();
};

#endif /* defined(__asteroidsTest__Pad__) */
