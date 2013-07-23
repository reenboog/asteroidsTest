//
//  Pad.h
//  asteroidsTest
//
//  Created by Alex Gievsky on 20.07.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#ifndef __asteroidsTest__Pad__
#define __asteroidsTest__Pad__

#import "Sprite.h"

#define kMaxPadDisplacement 30

class Pad: public Node {
private:
    Sprite *_img;
    
    Vector2 _value;
    Float _maxScale;
    
    Void_VoidFunc _touchBeganBlock;
    Void_VoidFunc _touchEndedBlock;
    Void_VoidFunc _touchMovedBlock;
public:
    virtual ~Pad();
    Pad(const string &file, Float maxScale, Void_VoidFunc began, Void_VoidFunc ended, Void_VoidFunc moved);
    
    void touchBegan(const Vector2 &v);
    void touchMoved(const Vector2 &v);
    void touchEnded(const Vector2 &v);

    Vector2 getValue();
};

#endif /* defined(__asteroidsTest__Pad__) */
