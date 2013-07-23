//
//  GameScene.h
//  kingTest
//
//  Created by Alex Gievsky on 18.06.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#ifndef __kingTest__GameScene__
#define __kingTest__GameScene__

#import "Node.h"

class Sprite;
class Field;
class Label;
class Pad;
class Ship;

class Scene: public Node, public Touchable {
private:
    //logic
    Int _score;

    Bool _gameOver;
    
    Float _time;
    
    Sprite *_back;
    Ship *_ship;
    Label *_timeLabel;
    Label *_gameOverLabel;
    
    SpritePool _healthIcons;
    
    Size2 _bounds;
    
    // pads
    Pad *_movementPad;
    Pad *_firePad;
public:
    Scene();
    ~Scene();
public:
    virtual Bool init();
    
    virtual void render();
    virtual Bool update(Float dt);
    
    void restart();
    void placeAsteroids();
    void placeLevelUp();
    void gameOver();
    
    void setHealth(Int health);

    // score logic
    void applyPoints(Int points);

    void setScore(Int score);
    Int getScore();
    
    // time logic
    void tick(Float dt);
    
    // touches
    void touchesBegan(const Vector2Pool &touches);
    void touchesMoved(const Vector2Pool &touches);
    void touchesEnded(const Vector2Pool &touches);
    void touchesCancelled(const Vector2Pool &touches);

private:
    void formatTime();
};

#endif /* defined(__kingTest__GameScene__) */