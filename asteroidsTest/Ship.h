//
//  Ship.h
//  asteroidsTest
//
//  Created by Alex Gievsky on 21.07.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#ifndef __asteroidsTest__Ship__
#define __asteroidsTest__Ship__

#import "Node.h"

#define kShipLv1MaxTime 5
#define kShipMaxHealth 3

class Sprite;
class ScheduledBlock;
class Inert;

class Ship: public Node {
private:
    Bool _useShield;
    SpritePool _images;
    Int _level;
    Int _health;
    Void_VoidFunc _onDeathBlock;
    Void_VoidFunc _onDamageBlock;
    
    ScheduledBlock *_shotComponent;
    Inert *_inertion;
public:
    virtual ~Ship();
    Ship(Int level, Void_VoidFunc onDamage, Void_VoidFunc onDeath);
    
    void onDamage();
    void respawn();
    
    void die();
    void reborn();
    
    Bool useShield();
    
    void setHealth(Int health);
    Int getHealth();
    
    void setVelocity(const Vector2 &v);
    
    void setAlive(Bool alive);
    
    void fire();
    
    void startShooting();
    void stopShooting();

    Int getLevel();
    void setLevel(Int level);
    
    void LevelUp();
};

#endif /* defined(__asteroidsTest__Ship__) */
