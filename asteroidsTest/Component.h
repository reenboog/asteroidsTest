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
    Bool _aboutToDie;
protected:
    Component();
    // components can be deleted by their parent Objects only or other components
    virtual ~Component();
    
    void detachFromTarget();
    void attachToTarget(Object *target, Bool suspend = false);
    void done();
    
    virtual void setUp() = 0;
    
    void update(Float dt);

    void maybeDie();
public:
    Bool isRunning();
    Bool isAboutToDie();
    
    virtual void tick(Float dt) = 0;
    
    void run();
    virtual void stop();
    void pause();
};

// instantUse

class InstantUse: public Component {
protected:
    InstantUse();
    virtual ~InstantUse();
    
    void tick(Float dt);
    virtual void doSomething() = 0;
};

// hider

class Hider: public InstantUse {
private:
    Bool _hidden;
protected:
    Hider(Bool hidden);
    virtual ~Hider();

    void setUp();
    void doSomething();

public:
    static Component * runWithHidden(Bool hidden);
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
    virtual ~Delay();
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
    virtual ~MoveTo();
public:
    static Component * runWithPosition(const Vector2 &pos, Float time);
private:
    //do not allow instantiating with this method directly
    static Component * runWithTime(Float time) {return nullptr;};
};

class MoveBy: public MoveTo {
protected:
    MoveBy(const Vector2 &pos, Float time);
    virtual ~MoveBy();

    void setUp();
public:
    static Component * runWithPositionDelta(const Vector2 &pos, Float time);
private:
    static Component * runWithPosition(const Vector2 &pos, Float time) {return nullptr;};
};

// rotateTo

class RotateTo: public Delay {
protected:
    Float _endRotation;
    Float _startRotation;
    Float _delta;
protected:
    void tick(Float dt);
    void setUp();
    
    RotateTo(Float angle, Float time);
    virtual ~RotateTo();
public:
    static Component * runWithRotation(Float angle, Float time);
private:
    //do not allow instantiating with this method directly
    static Component * runWithTime(Float time) {return nullptr;};
};

// rotateBy

class RotateBy: public RotateTo {
protected:
    RotateBy(Float angle, Float time);
    virtual ~RotateBy();
    
    void setUp();
public:
    static Component * runWithRotationDelta(Float angle, Float time);
private:
    static Component * runWithRotation(Float angle, Float time) {return nullptr;};
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
    virtual ~ScaleTo();
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
    virtual ~FadeTo();
public:
    static Component * runWithAlpha(UChar alpha, Float time);
private:
    //do not allow instantiating with this method directly
    static Component * runWithTime(Float time) {return nullptr;};
};

// sequence

class ComponentSequence: public Component {
private:
    ComponentPool _components;
    Component *_current;
protected:
    ComponentSequence(const ComponentPool &components);
    ~ComponentSequence();
    
    void tick(Float dt);
    void setUp();
public:
    void stop();
    
    static Component * runWithComponents(const ComponentPool &components);
};

// spawn

class ComponentGroup: public InstantUse {
private:
    ComponentPool _components;
protected:
    ComponentGroup(const ComponentPool &components);
    ~ComponentGroup();
    
    void doSomething();
    void setUp();
public:
    void stop();
    
    static Component * runWithComponents(const ComponentPool &components);
};

#endif /* defined(__asteroidsTest__Component__) */
