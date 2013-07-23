//
//  Ship.cpp
//  asteroidsTest
//
//  Created by Alex Gievsky on 21.07.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#import "Ship.h"
#import "BoundToArea.h"
#import "Common.h"
#import "Bullet.h"
#import "Sprite.h"

#import <sstream>
#import <iostream>
//#import "Asteroid.h"

#import "SoundManager.h"

#define kBulletDelay 0.2

Ship::~Ship() {
    //
}

Ship::Ship(Int level, Void_VoidFunc onDamageBlock, Void_VoidFunc onDeathBlock): Node() {
    _useShield = false;
    _shotComponent = nullptr;
    _health = kShipMaxHealth;
    _onDeathBlock = onDeathBlock;
    _onDamageBlock = onDamageBlock;
    _inertion = nullptr;
    
    setAlive(false);

    _level = -1;
    
    this->setTag(kShipTag);

    Bool isIpad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;

    Int w = 32, h = 32;
    
    if(isIpad) {
        w = h = 64;
    }
    
    Sprite *ship = new Sprite("ships.png", 0, 0, w, h);
    ship->setHidden(true);
    
    _images.push_back(ship);

    this->addChild(ship);
    
    ship = new Sprite("ships.png", w, 0, w, h);
    ship->setHidden(true);
    
    _images.push_back(ship);

    this->addChild(ship);
    
    setLevel(level);
    
    CGRect bounds = GetBounds();
    
    this->applyComponent(BoundToArea::runWithArea({0.0, 0.0, bounds.size.width, bounds.size.height}));

    _inertion = (Inert *)Inert::runWithVelocity({0.0, 0.0});
    this->applyComponent(_inertion);
    
    this->applyComponent(Collider::runWithBlock([this](Intersectable *obj){
        Node *node = dynamic_cast<Node *>(obj);
        if(this->isAlive() && node->isAlive() && node->getTag() == kAsteroidTag) {
            onDamage();
        }
    }));
    
    setContentRadius(_images[0]->getContentRadius() * 0.7);
}

Int Ship::getLevel() {
    return  _level;
}

void Ship::setLevel(Int level) {
    if(_level != -1) {
        _images[_level]->setHidden(true);
    }
    
    _level = level;
    
    if(_level > 1) {
        _level = 1;
    }

    _images[_level]->setHidden(false);
}

void Ship::LevelUp() {
    if(isAlive()) {
        setLevel(_level + 1);
    }
}

void Ship::onDamage() {
    setAlive(false);
    setHealth(_health - 1);
    
    _onDamageBlock();
}

void Ship::respawn() {
    _useShield = true;
    
    setLevel(0);
    
    this->applyComponent(SequenceComponent::runWithComponents({
        Blink::runWithBlinks(3, 0.5),
        CallBlock::runWithBlock([this](){
            _useShield = false;
            setAlive(true);
        })
    }));
}

void Ship::die() {
    _images[_level]->applyComponent(GroupComponent::runWithComponents({
        ScaleTo::runWithScale(5, 0.5),
        FadeTo::runWithAlpha(0, 0.4),
        RotateTo::runWithRotation(360 * 4, 0.6)
    }));
}

void Ship::reborn() {
    _images[_level]->setScale(1.0);
    _images[_level]->setRotation(0);
    _images[_level]->setAlpha(255);

    setLevel(0);
    
    _images[_level]->setAlpha(0);
    _images[_level]->setScale(5);
    _images[_level]->setRotation(360 * 4);
    
    _images[_level]->applyComponent(SequenceComponent::runWithComponents({
        GroupComponent::runWithComponents({
            ScaleTo::runWithScale(1, 0.5),
            FadeTo::runWithAlpha(255, 0.7),
            RotateTo::runWithRotation(0, 0.6),
        }),
        CallBlock::runWithBlock([this]() {
            _health = kShipMaxHealth;
//            setAlive(true);
            respawn();
        })
    }));
}

Bool Ship::useShield() {
    return _useShield;
}

Int Ship::getHealth() {
    return _health;
}

void Ship::setVelocity(const Vector2 &v) {
    _inertion->setVelocity(v);
}

void Ship::setHealth(Int health) {
    _health = health;
    
    if(_health <= 0) {
        _health = 0;
        SoundManager::mngr()->playEffect("shipExplode");
        die();

        _onDeathBlock();
    } else {
        SoundManager::mngr()->playEffect("shipHit");
        respawn();
    }
}

void Ship::startShooting() {
    if(_shotComponent) {
        _shotComponent->stop();
    }
    
    _shotComponent = (ScheduledBlock *)ScheduledBlock::runWithDelay(kBulletDelay * (_level + 1), [this](){
        fire();
    });
    
    this->applyComponent(_shotComponent);
}

void Ship::fire() {
    auto bulletFeedback = [](Intersectable *obj){
        Node *node = dynamic_cast<Node *>(obj);
        if(node->isAlive() && node->getTag() == kAsteroidTag) {
            node->setAlive(false);

            stringstream explosion;
            explosion << "asteroidExplode" << rand() % 3;
            SoundManager::mngr()->playEffect(explosion.str());
        }
    };

    if(_level == 0) {
        //Float lifeTime, Float size, Color4B color, const Vector2 &velocity, Void_VoidFunc onCollision): Mesh() {
        Vector2 pos = this->getAbsolutePos();
        Vector2 dir = {0, 20};
        dir = dir.rotate(-this->getRotation());
        
        Bullet *b = new Bullet(1.0, 10.0, {100, 100, 255, 200}, dir.mul(30), false, bulletFeedback);
        b->setPos(pos.add(dir));
        getParent()->addChild(b);
        
        if(_level == 0) {
            b->setTag(kBullet0Tag);
        } else if(_level == 1) {
            b->setTag(kBullet1Tag);
        }
        
        SoundManager::mngr()->playEffect("shoot1");
    } else if(_level == 1) {
        Vector2 basePos = this->getAbsolutePos();
        Vector2 baseDir = {0, 20};
        
        Int tag = _level == 0 ? kBullet0Tag : kBullet1Tag;
        
        baseDir = baseDir.rotate(-getRotation());

        Vector2 dir = baseDir.rotate(-45);
                
        Bullet *b = new Bullet(2.0, 10.0, {255, 100, 100, 200}, dir.mul(30), true, bulletFeedback);
        b->setPos(basePos.add(dir));
        b->setTag(tag);
        getParent()->addChild(b);
        
        dir = baseDir;
        b = new Bullet(2.0, 10.0, {255, 100, 100, 200}, dir.mul(30), true, bulletFeedback);
        
        b->setPos(basePos.add(dir));
        b->setTag(tag);
        getParent()->addChild(b);
        
        dir = baseDir.rotate(45);
        b = new Bullet(2.0, 10.0, {255, 100, 100, 200}, dir.mul(30), true, bulletFeedback);
        
        b->setPos(basePos.add(dir));
        b->setTag(tag);
        getParent()->addChild(b);
        
        SoundManager::mngr()->playEffect("shoot0");
    }
}

void Ship::setAlive(Bool alive) {
    Node::setAlive(alive);
}

void Ship::stopShooting() {
    if(_shotComponent) {
        _shotComponent->stop();
        _shotComponent = nullptr;
    }
}