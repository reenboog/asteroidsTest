//
//  Component.mm
//  asteroidsTest
//
//  Created by Alex Gievsky on 16.07.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#include "Component.h"
#include "Object.h"
#include "Sprite.h"

//#import "Node.h"


// base component

Component::Component() {
    _target = nullptr;
    _aboutToDie = false;
    
    //printf("+ Component created\n");
}

Component::~Component() {
    //printf("- Component destroyed\n");
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
    _aboutToDie = true;

    //detachFromTarget();
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
    Component::stop();
}

Bool Component::isRunning() {
    return _running;
}

Bool Component::isAboutToDie() {
    return _aboutToDie;
}

Object * Component::getTarget() {
    return _target;
}

// instantUse

InstantUse::~InstantUse(){
}

InstantUse::InstantUse(): Component() {
}

void InstantUse::tick(Float dt) {
    doSomething();
    
    done();
}

// hider
Hider::~Hider(){
}

Hider::Hider(Bool hidden): InstantUse() {
    _hidden = hidden;
}

void Hider::setUp() {
}

Component * Hider::runWithHidden(Bool hidden) {
    return new Hider(hidden);
}

void Hider::doSomething(){
    dynamic_cast<Hideable *>(_target)->setHidden(_hidden);
}

// delay

Delay::Delay(Float time): Component() {
    _time = time;
    _currentTime = 0.0;
    
    //printf("+ Delay created\n");
}

Delay::~Delay() {
    //printf("- Delay destroyed\n");
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
    
    //printf("+ MoveTo created\n");
}

MoveTo::~MoveTo() {
    //printf("- MoveTo destroyed\n");
}

Component * MoveTo::runWithPosition(const Vector2 &pos, Float time) {
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
    //printf("+ MoveBy created\n");
}

MoveBy::~MoveBy() {
    //printf("- MoveBy destroyed\n");
}

Component * MoveBy::runWithPositionDelta(const Vector2 &pos, Float time) {
    return new MoveBy(pos, time);
}

void MoveBy::setUp() {
    // assume, _endPos keeps our delta
    _startPos = dynamic_cast<Movable *>(_target)->getPos();
    _endPos = _startPos + _endPos;
    _delta = _endPos - _startPos;
}

// transformUV

TransformUV::~TransformUV() {
}

TransformUV::TransformUV(const Vector2 &v) {
    _velocity = v;
}

Component * TransformUV::runWithVelocity(const Vector2 &v) {
    return new TransformUV(v);
}

void TransformUV::setUp() {
    Sprite *t = dynamic_cast<Sprite *>(_target);
    _originalRect = t->getUV();
}

void TransformUV::tick(Float dt) {
    Sprite *t = dynamic_cast<Sprite *>(_target);
    UVRect uv = t->getUV();
    
    // bug: clamp texture coords to [0..1]!
    // uv overflow is possible!
    uv._0.u += _velocity.x * dt;
    uv._0.u += _velocity.y * dt;
    uv._1.u += _velocity.x * dt;
    uv._1.u += _velocity.y * dt;
    
    t->setUV(uv);
}

// rotateTo

RotateTo::~RotateTo() {
}

RotateTo::RotateTo(Float angle, Float time): Delay(time) {
    _endRotation = angle;
}

Component * RotateTo::runWithRotation(Float angle, Float time) {
    return new RotateTo(angle, time);
}

void RotateTo::setUp() {
    _startRotation = dynamic_cast<Rotatable *>(_target)->getRotation();
    _delta = _endRotation - _startRotation;
}

void RotateTo::tick(Float dt) {
    Bool finished = false;
    
    _currentTime += dt;
    
    if(_currentTime >= _time) {
        _currentTime = _time;
        finished = true;
    }
    
    Float percentage = _currentTime / _time;
    Float r = _startRotation + _delta * percentage;
    
    dynamic_cast<Rotatable *>(_target)->setRotation(r);
    
    if(finished) {
        done();
    }
}

// rotateBy

RotateBy::~RotateBy() {
}

RotateBy::RotateBy(Float angle, Float time): RotateTo(angle, time) {
}

Component * RotateBy::runWithRotationDelta(Float angle, Float time) {
    return new RotateBy(angle, time);
}

void RotateBy::setUp() {
    _startRotation = dynamic_cast<Rotatable *>(_target)->getRotation();
    _endRotation = _startRotation + _endRotation;
    _delta = _endRotation - _startRotation;
}

// scaleTo

ScaleTo::ScaleTo(Float scaleX, Float scaleY, Float time): Delay(time) {
    _endScale = Vector2{scaleX, scaleY};
    
    //printf("+ ScaleTo created\n");
}

ScaleTo::~ScaleTo() {
    //printf("- ScaleTo destroyed\n");
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
    
    //printf("scale time %f:, detla: %f\n", _currentTime, dt);
    
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
    
    //printf("+ FadeTo created\n");
}

FadeTo::~FadeTo() {
    //printf("- FadeTo destroyed\n");
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

// componentSequence

ComponentSequence::~ComponentSequence() {
    //printf("- ComponentSequence destroyed\n");
}

ComponentSequence::ComponentSequence(const ComponentPool &components): Component() {
    _components = components;

    _current = nullptr;
    
    //printf("+ ComponentSequence created\n");
}

Component * ComponentSequence::runWithComponents(const ComponentPool &components) {
    return new ComponentSequence(components);
}

void ComponentSequence::setUp() {
}

void ComponentSequence::stop() {
    Component::stop();
    
    if(_current) {
        _current->stop();
    }
}

void ComponentSequence::tick(Float dt) {
    if(_components.empty()) {
        done();
    } else {
        if(_current == nullptr) {
            _current = _components[0];
            _target->applyComponent(_current);
        }
        
        if(_current->isAboutToDie()) {
            _current = nullptr;
            
            _components.erase(_components.begin());
        }
    }
}

// spawn

ComponentGroup::~ComponentGroup() {
}

ComponentGroup::ComponentGroup(const ComponentPool &components): InstantUse() {
    _components = components;
}

Component * ComponentGroup::runWithComponents(const ComponentPool &components) {
    return new ComponentGroup(components);
}

void ComponentGroup::setUp() {
    //
}

void ComponentGroup::doSomething() {
    for(Component *component: _components) {
        _target->applyComponent(component);
    }
}

// callBlock

CallBlock::~CallBlock() {
}

CallBlock::CallBlock(Void_VoidFunc block): InstantUse() {
    _block = block;
}

Component * CallBlock::runWithBlock(Void_VoidFunc block) {
    return new CallBlock(block);
}

void CallBlock::setUp() {
    //
}

void CallBlock::doSomething() {
    _block();
}
