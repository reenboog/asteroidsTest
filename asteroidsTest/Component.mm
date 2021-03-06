//
//  Component.mm
//  asteroidsTest
//
//  Created by Alex Gievsky on 16.07.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#import "Component.h"
#import "Object.h"

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

// blink

Component * Blink::runWithBlinks(Int blinks, float inTime) {
    
    Float delay = 0.5 * inTime / blinks;
    ComponentPool sequence;
    for(Int i = 0; i < blinks; ++i) {
        sequence.push_back(Hider::runWithHidden(true));
        sequence.push_back(Delay::runWithTime(delay * i));
        sequence.push_back(Hider::runWithHidden(false));
        sequence.push_back(Delay::runWithTime(delay * i));
    }
    return SequenceComponent::runWithComponents(sequence);
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

void Delay::setTime(Float time) {
    _time = time;
}

Float Delay::getTime() {
    return _time;
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
    _delta = _endPos.sub(_startPos);
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
    _endPos = _startPos.add(_endPos);
    _delta = _endPos.sub(_startPos);
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
    _endScale = {scaleX, scaleY};
    
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

    _startScale = {t->getScaleX(), t->getScaleY()};
    _delta = _endScale.sub(_startScale);
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

SequenceComponent::~SequenceComponent() {
    //printf("- ComponentSequence destroyed\n");
}

SequenceComponent::SequenceComponent(const ComponentPool &components): Component() {
    _components = components;

    _current = nullptr;
    
    //printf("+ ComponentSequence created\n");
}

Component * SequenceComponent::runWithComponents(const ComponentPool &components) {
    return new SequenceComponent(components);
}

void SequenceComponent::setUp() {
}

void SequenceComponent::stop() {
    Component::stop();
    
    if(_current) {
        _current->stop();
    }
}

void SequenceComponent::tick(Float dt) {
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

GroupComponent::~GroupComponent() {
}

GroupComponent::GroupComponent(const ComponentPool &components): InstantUse() {
    _components = components;
}

Component * GroupComponent::runWithComponents(const ComponentPool &components) {
    return new GroupComponent(components);
}

void GroupComponent::setUp() {
    //
}

void GroupComponent::doSomething() {
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

// scheduledCallBlock

ScheduledBlock::~ScheduledBlock() {
}

ScheduledBlock::ScheduledBlock(Float delay, Void_VoidFunc block): Delay(delay) {
    _block = block;
}

Component * ScheduledBlock::runWithDelay(Float delay, Void_VoidFunc block) {
    return new ScheduledBlock(delay, block);
}

void ScheduledBlock::tick(Float dt) {
    _currentTime += dt;
    
    if(_currentTime >= _time) {
        _currentTime = 0.0;
        _block();
    }
}
