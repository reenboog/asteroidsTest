//
//  GameScene.h
//  kingTest
//
//  Created by Alex Gievsky on 18.06.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#ifndef __kingTest__GameScene__
#define __kingTest__GameScene__

#include "Node.h"

class Sprite;
class Field;
class Label;

class Scene: public Node {
private:
    //logic
    Int _score;

    Bool _gameOver;
    
    Sprite *_back;
public:
    Scene();
    ~Scene();
public:
    virtual Bool init();
    
    virtual void render();
    virtual Bool update(Float dt);
    
    void restart();
    void gameOver();

    //score logic
    void applyPoints(Int points);

    void setScore(Int score);
    Int getScore();
    
    //time logic
    void tick(Float dt);
};

#endif /* defined(__kingTest__GameScene__) */