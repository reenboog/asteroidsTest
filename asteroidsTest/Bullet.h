//
//  Bullet.h
//  asteroidsTest
//
//  Created by Alex Gievsky on 22.07.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#ifndef __asteroidsTest__Bullet__
#define __asteroidsTest__Bullet__

#import "Mesh.h"
#import "Inert.h"
#import "Collider.h"

//#import "Types.h"

class Bullet: public Mesh {
private:
    Float _lifeTime;
    Float _pointSize;
    Bool _smoothed;
    //Void_VoidBlock _onCollideBlock;
public:
    Bullet(Float lifeTime, Float size, Color4B color, const Vector2 &velocity, Bool smoothed, Void_IntersectableFunc onCollision);
    ~Bullet();
    
    void render();
};

#endif /* defined(__asteroidsTest__Bullet__) */
