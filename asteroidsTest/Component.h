//
//  Component.h
//  asteroidsTest
//
//  Created by Alex Gievsky on 16.07.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#ifndef __asteroidsTest__Component__
#define __asteroidsTest__Component__

#import "Types.h"

// base component class
class Object;

class Component {
    friend class Object;
protected:
    // weak ref
    Object *_target;
    Bool _running;
protected:
    Component();
    // components can be deleted by their parent Objects only or other components
    virtual ~Component();
    
    void detachFromTarget();
    void attachToTarget(Object *target, Bool suspend = false);
    void done();
    
    virtual void tick(Float dt) = 0;
    virtual void setUp() = 0;
    
    void update(Float dt);
public:
    void run();
    void stop();
    void pause();
};

// delay 

class Delay: public Component {
protected:
    Float _time;
    Float _currentTime;
protected:
    void tick(Float dt);
    void setUp();
    
    Delay(Float time);
public:
    static Component * runWithTime(Float time);
};

// moveTo 

class MoveTo: public Delay {
protected:
    Vector2 _endPos;
    Vector2 _startPos;
    Vector2 _delta;
protected:
    void tick(Float dt);
    void setUp();
    
    MoveTo(const Vector2 &pos, Float time);
public:
    static Component * runWithPositionAndDuration(const Vector2 &pos, Float time);
private:
    //do not allow instantiating with this method directly
    static Component * runWithTime(Float time) {return nullptr;};
};

class MoveBy: public MoveTo {
protected:
    MoveBy(const Vector2 &pos, Float time);
public:
    void setUp();

    static Component * runWithPositionDeltaAndDuration(const Vector2 &pos, Float time);
private:
    static Component * runWithPositionAndDuration(const Vector2 &pos, Float time) {return nullptr;};
};

// scaleTo

class ScaleTo: public Delay {
protected:
    Vector2 _endScale;
    Vector2 _startScale;
    Vector2 _delta;
protected:
    void tick(Float dt);
    void setUp();
    
    ScaleTo(Float scaleX, Float scaleY, Float time);
public:
    static Component *runWithScale(Float scale, Float time);
    static Component *runWithScaleXY(Float scaleX, Float scaleY, Float time);
private:
    //do not allow instantiating with this method directly
    static Component * runWithTime(Float time) {return nullptr;};
};

// fadeTo

class FadeTo: public Delay {
protected:
    UChar _endAlpha;
    UChar _startAlpha;
    Short _delta;
protected:
    void tick(Float dt);
    void setUp();
    
    FadeTo(UChar alpha, Float time);
public:
    static Component * runWithAlpha(UChar alpha, Float time);
private:
    //do not allow instantiating with this method directly
    static Component * runWithTime(Float time) {return nullptr;};
};

#endif /* defined(__asteroidsTest__Component__) */
