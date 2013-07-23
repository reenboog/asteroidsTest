//
//  Asteroid.h
//  asteroidsTest
//
//  Created by Alex Gievsky on 21.07.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#ifndef __asteroidsTest__Asteroid__
#define __asteroidsTest__Asteroid__

#import "Mesh.h"
#import <random>

#define kAsteroidsMaxLevel 1

class Inert;

class Asteroid: public Mesh {
private:
    Int _level;
    Inert *_inertion;
private:
    void generateGeometry();
public:
    Asteroid(Int level, const Vector2 &pos);
    virtual ~Asteroid();
    
    Int getLevel();
    void setLevel(Int level);
    
    void setVelocity(const Vector2 &v);
    Vector2 getVelocity();
    
    void onDamage();
    void setAlive(Bool alive);

    void render();
};

#endif /* defined(__asteroidsTest__Asteroid__) */
