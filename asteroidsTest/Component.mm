//
//  Component.mm
//  asteroidsTest
//
//  Created by Alex Gievsky on 16.07.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#include "Component.h"
#include "Object.h"

//#import "Node.h"


// base component

Component::Component() {
    _target = nullptr;
    
    printf("+ Component created\n");
}

Component::~Component() {
    //
    
    printf("- Component destroyed\n");
}

void Component::attachToTarget(Object *target, Bool suspend) {
    _target = target;
    
    setUp();
    
    if(!suspend) {
        run();
    }
}

void Component::detachFromTarget() {
    if(_target) {
        _target->detachComponent(this);
        //_target = nullptr;
        //_running = false;
    }
}

void Component::run() {
    _running = true;
}

void Component::stop() {
    _running = false;
    detachFromTarget();
}

void Component::pause() {
    _running = false;
}

void Component::update(Float dt) {
    if(_running) {
        tick(dt);
    }
}

void Component::done() {
    //_running = false;
    //detachFromTarget();
    stop();
}

// delay

Delay::Delay(Float time): Component() {
    _time = time;
}

Component * Delay::runWithTime(Float time) {
    return new Delay(time);
}

void Delay::setUp() {
    _currentTime = 0.0;
}

void Delay::tick(Float dt) {
    _currentTime += dt;
    
    if(_currentTime >= _time) {
        done();
    }
}

// moveTo

MoveTo::MoveTo(const Vector2 &pos, Float time): Delay(time) {
    _endPos = pos;
}

Component * MoveTo::runWithPositionAndDuration(const Vector2 &pos, Float time) {
    return new MoveTo(pos, time);
}

void MoveTo::setUp() {
    // using dynamic_cast is not the best idea
    // but it's better than virtual inheritance in our case
    _startPos = dynamic_cast<Movable *>(_target)->getPos();
    _delta = _endPos - _startPos;
}

void MoveTo::tick(Float dt) {
    Bool finished = false;
    
    _currentTime += dt;
    
    if(_currentTime >= _time) {
        _currentTime = _time;
        finished = true;
    }
    
    Float percentage = _currentTime / _time;

    Vector2 pos{_startPos.x + _delta.x * percentage, _startPos.y + _delta.y * percentage};

    dynamic_cast<Movable *>(_target)->setPos(pos);
    
    if(finished) {
        done();
    }
}

// move by

MoveBy::MoveBy(const Vector2 &pos, Float time): MoveTo(pos, time) {
    //
}

Component * MoveBy::runWithPositionDeltaAndDuration(const Vector2 &pos, Float time) {
    return new MoveBy(pos, time);
}

void MoveBy::setUp() {
    // assume, _endPos keeps our delta
    _startPos = dynamic_cast<Movable *>(_target)->getPos();
    _endPos = _startPos + _endPos;
    _delta = _endPos - _startPos;
}

// scaleTo

ScaleTo::ScaleTo(Float scaleX, Float scaleY, Float time): Delay(time) {
    _endScale = Vector2{scaleX, scaleY};
}

Component * ScaleTo::runWithScale(Float scale, Float time) {
    return ScaleTo::runWithScaleXY(scale, scale, time);
}

Component * ScaleTo::runWithScaleXY(Float scaleX, Float scaleY, Float time) {
    return new ScaleTo(scaleX, scaleY, time);
}

void ScaleTo::setUp() {
    // using dynamic_cast is not the best idea
    // but it's better than virtual inheritance in our case
    Scalable *t = dynamic_cast<Scalable *>(_target);

    _startScale = Vector2{t->getScaleX(), t->getScaleY()};
    _delta = _endScale - _startScale;
}

void ScaleTo::tick(Float dt) {
    Bool finished = false;
    
    _currentTime += dt;
    
    if(_currentTime >= _time) {
        _currentTime = _time;
        finished = true;
    }
    
    Float percentage = _currentTime / _time;
    
    Vector2 scale{_startScale.x + _delta.x * percentage, _startScale.y + _delta.y * percentage};
    
    Scalable *t = dynamic_cast<Scalable *>(_target);
    
    t->setScaleX(scale.x);
    t->setScaleY(scale.y);
    
    if(finished) {
        done();
    }
}

// fadeTo

FadeTo::FadeTo(UChar alpha, Float time): Delay(time) {
    _endAlpha = alpha;
}

Component * FadeTo::runWithAlpha(UChar alpha, Float time) {
    return new FadeTo(alpha, time);
}

void FadeTo::setUp() {
    Blendable *t = dynamic_cast<Blendable *>(_target);
    
    _startAlpha = t->getAlpha();
    _delta = _endAlpha - _startAlpha;
}

void FadeTo::tick(Float dt) {
    Bool finished = false;
    
    _currentTime += dt;
    
    if(_currentTime >= _time) {
        _currentTime = _time;
        finished = true;
    }
    
    Float percentage = _currentTime / _time;
    
    UChar alpha = _startAlpha + _delta * percentage;
    
    //printf("alpha = %i\n", (int) alpha);
    
    Blendable *t = dynamic_cast<Blendable *>(_target);
    t->setAlpha(alpha);
    
    if(finished) {
        done();
    }
}