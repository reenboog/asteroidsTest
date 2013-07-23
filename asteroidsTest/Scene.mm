//
//  GameScene.cpp
//  kingTest
//
//  Created by Alex Gievsky on 18.06.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#import "Scene.h"

//#import "BoundToArea.h"
#import "Inert.h"
#import "Collider.h"

#import "Sprite.h"
#import "Label.h"
#import "Mesh.h"

#import "Common.h"

#import "SoundManager.h"

#import "Pad.h"
#import "Ship.h"
#import "Asteroid.h"

#import <iostream>
#import <sstream>

#import <mach/mach.h>

#define kAsteroidPortionSize 10
#define kAsteroidPlacementRadius 500
#define kAsteroidRespawnDelay 20
#define kLevelUpRespawnDelay 15
#define kLevelUpLabelLifeTime 7
#define kLevelUpPlacementRadius 500
#define kLevelUpMaxVelocity 100

Scene::Scene(): Node() {
    _back = nullptr;
    _ship = nullptr;
    _timeLabel = nullptr;
    _gameOver = true;
    _time = 0;
    
    random_device rd;
    srand(rd());
}

Scene::~Scene() {
    //cleanup();
}

Component *ccc = nullptr;

Bool Scene::init() {
    
    CGRect bounds = GetBounds();
    
    Bool isIpad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    
    // back
    _back = new Sprite("back.png");
    _back->setPos({bounds.size.width / 2, bounds.size.height / 2});
    _back->setAlpha(255);
    
    this->addChild(_back);
    //
    
    // parallax
    Sprite *parallax = new Sprite("parallax.png");
    parallax->setPos({bounds.size.width / 2, bounds.size.height / 2});
    parallax->setAlpha(50);
    
    parallax->applyComponent(TransformUV::runWithVelocity({0.1}));
    this->addChild(parallax);
    
    parallax = new Sprite("parallax.png");
    parallax->setPos({bounds.size.width / 2, bounds.size.height / 2});
    parallax->setAlpha(150);
    parallax->setColor({0, 0, 255, 30});
    
    parallax->applyComponent(TransformUV::runWithVelocity({0.2}));
    this->addChild(parallax);
    //
    
    // game over label
    _gameOverLabel = new Label("game over", isIpad ? 70 : 35);
    _gameOverLabel->setPos({bounds.size.width / 2, bounds.size.height / 2});
    this->addChild(_gameOverLabel);
    // health icons
    
    for(Int i = 0; i < kShipMaxHealth; ++i) {
        Sprite *icon = new Sprite("healthIcon.png");
        
        const Vector2 base = {0.13f * bounds.size.width, 0.95f * bounds.size.height};
        Vector2 pos = base.sub({(i * 1.5f) * icon->getContentRadius(), 0});
        icon->setPos(pos);
        
        _healthIcons.push_back(icon);
        this->addChild(icon);
    }
    
    // ship
    _ship = new Ship(0, [this]() {
        setHealth(_ship->getHealth());
    }, [this]() {
        _ship->stopShooting();
        gameOver();
    });
    
    _ship->setHidden(true);

    this->addChild(_ship);
    //
    
    Float maxSpeedScale = 5.0;
    if(isIpad) {
        maxSpeedScale = 10.0;
    }
    
    // pads
    _movementPad = new Pad("moveBtn.png", maxSpeedScale, [](){}, [](){}, [this](){
        _ship->setVelocity(_movementPad->getValue());
    });
    _movementPad->setPos({0.075f * bounds.size.width, 0.1f * bounds.size.height});
    
    this->addChild(_movementPad);
    
    _firePad = new Pad("fireBtn.png", maxSpeedScale, [this](){
        _ship->startShooting();
    }, [this](){
        _ship->stopShooting();
    }, [=](){
        // rotate the ship here
        Vector2 val = _firePad->getValue();
        Vector2 yAxe = {0.0, 1.0};
        
        Float angle = yAxe.angleBetween(val);
        
        _ship->setRotation(radiansToDegree(angle));
        
    });
    _firePad->setPos({0.925f * bounds.size.width, 0.1f * bounds.size.height});
    
    this->addChild(_firePad);
    // 
    
    Int fontSize = isIpad ? 40 : 15;
    
    _timeLabel = new Label("00:00", fontSize, "Commo");
    _timeLabel->setPos({bounds.size.width / 2.0f, bounds.size.height * 0.95f});
    this->addChild(_timeLabel);
    
    SoundManager::mngr()->playBackground("bgMusic");
    SoundManager::mngr()->preloadEffect("shoot0");
    SoundManager::mngr()->preloadEffect("shoot1");
    SoundManager::mngr()->preloadEffect("asteroidExplode0");
    SoundManager::mngr()->preloadEffect("asteroidExplode1");
    SoundManager::mngr()->preloadEffect("asteroidExplode2");
    SoundManager::mngr()->preloadEffect("shipExplode");
    SoundManager::mngr()->preloadEffect("shipLevelUp");
    SoundManager::mngr()->preloadEffect("shipHit");
    
    gameOver();
    
    return true;
}

void Scene::render() {
    Node::render();
}

void Scene::formatTime() {
    
    Int tempHour = 0;
    Int tempMinute = 0;
    Int tempSecond = 0;
    
    string minutesPref = "";
    string secondsPref = "";
    
    tempHour    = _time / 3600;
    tempMinute  = _time / 60 - tempHour * 60;
    tempSecond  = _time - (tempHour * 3600 + tempMinute * 60);
    
    if(tempMinute < 10) {
        minutesPref = "0";
        
    }
    
    if(tempSecond < 10) {
        secondsPref = "0";
    }
    
    std::stringstream str;
    stringstream result;
    
    result << minutesPref << tempMinute << ":" << secondsPref << tempSecond;
    
    _timeLabel->setString(result.str());
}

Bool Scene::update(Float dt) {
    
    if(_gameOver) {
        return false;
    }
        
    Node::update(dt);
    
    static float t = 0;
    t+=dt;
    if(t >10) {
        t = -99999;
        if(ccc) {
            ccc->stop();
            ccc = nullptr;
        }
    }
    
    tick(dt);
    
    return true;
}

void Scene::restart() {
    this->detachAllComponents();
    
    CGRect bounds = GetBounds();

    setScore(0);
    
    placeAsteroids();
    //placeLevelUp();
    
    setHealth(-1);
    
    this->applyComponent(ScheduledBlock::runWithDelay(kAsteroidRespawnDelay, [this]() {
        placeAsteroids();
    }));

    this->applyComponent(ScheduledBlock::runWithDelay(kLevelUpRespawnDelay, [this]() {
        placeLevelUp();
    }));

    _ship->setHidden(false);
    _ship->setPos({bounds.size.width / 2, bounds.size.height / 2});
    _ship->reborn();

    _gameOver = false;
    
    _gameOverLabel->applyComponent(GroupComponent::runWithComponents({
        FadeTo::runWithAlpha(0, 0.4),
        ScaleTo::runWithScale(0.0, 0.3)
    }));

    _time = 0;
    formatTime();
}

void Scene::placeAsteroids() {
    Float stride = 360.0 / kAsteroidPortionSize;
    Float scale = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 1.0 : 0.5;
    
    CGRect bounds = GetBounds();
    
    for(int i = 0; i < kAsteroidPortionSize; ++i) {
        Vector2 pos = {cos(degreeToRadians(i * (stride + 1))), sinf(degreeToRadians(i * (stride + 1)))};
        
        pos = pos.mul(kAsteroidPlacementRadius);
        //pos = pos.add({(Float)(rand() % kAsteroidPlacementRadius), (Float)(rand() % kAsteroidPlacementRadius)});
        pos = pos.mul(scale);
        
        pos.increase({bounds.size.width / 2, bounds.size.height / 2});
        
        Asteroid *a = new Asteroid(3, pos);
        
        this->addChild(a);
    }
}

void Scene::placeLevelUp() {
    
    CGRect bounds = GetBounds();
    
    Float scale = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 1.0 : 0.5;

    Label *label = new Label("up", 40 * scale);
    label->setTag(kLevelUpTag);
    Int angle = rand() % 360;

    Vector2 pos = {cosf(degreeToRadians(angle)), sinf(degreeToRadians(angle))};
    pos = pos.mul(kLevelUpPlacementRadius);
    pos = pos.add({bounds.size.width / 2, bounds.size.height / 2});
    pos = pos.mul(scale);
    label->setPos(pos);
    
    this->addChild(label);
    
    Vector2 velocity = {bounds.size.width / 2, bounds.size.height / 2};
    velocity.decrease(pos);
    velocity.normalize();
    velocity = velocity.mul(kLevelUpMaxVelocity * scale);
    
    label->applyComponent(Inert::runWithVelocity(velocity));
    
    label->applyComponent(SequenceComponent::runWithComponents({
        Delay::runWithTime(kLevelUpLabelLifeTime),
        GroupComponent::runWithComponents({
            ScaleTo::runWithScale(0, 0.5),
            FadeTo::runWithAlpha(0, 0.4)
        }),
        CallBlock::runWithBlock([=]() {
            label->removeFromParent();
        })
    }));
    
    label->applyComponent(Collider::runWithBlock([=](Intersectable *obj) {
        Node *node = dynamic_cast<Node *>(obj);
        if(label->isAlive() && (node->getTag() == kBullet0Tag || node->getTag() == kBullet1Tag)) {
            label->setAlive(false);

            _ship->LevelUp();
            _ship->applyComponent(SequenceComponent::runWithComponents({
                Delay::runWithTime(kShipLv1MaxTime),
                CallBlock::runWithBlock([this]() {
                    _ship->setLevel(0);
                })
            }));
            
            SoundManager::mngr()->playEffect("shipLevelUp");

            label->applyComponent(SequenceComponent::runWithComponents({
                GroupComponent::runWithComponents({
                    ScaleTo::runWithScale(0, 0.5),
                    FadeTo::runWithAlpha(0, 0.4)
                }),
                CallBlock::runWithBlock([=]() {
                    label->removeFromParent();
                })
            }));
        }
    }));
}

void Scene::gameOver() {
    _gameOver = true;
    
    _gameOverLabel->setAlpha(0);
    _gameOverLabel->setScale(0);
    _gameOverLabel->applyComponent(GroupComponent::runWithComponents({
        FadeTo::runWithAlpha(255, 0.4),
        ScaleTo::runWithScale(1.0, 0.3)
    }));
    
    this->detachAllComponents();
}

void Scene::applyPoints(Int points) {
    _score += points;
    
    setScore(_score);
}

void Scene::setScore(Int score) {
    _score = score;
    
//    std::stringstream str;
//    
//    str << _score;
//    
//    _scoreLabel->setText(str.str());
}

void Scene::setHealth(Int health) {
    for(Sprite *icon: _healthIcons) {
        icon->setHidden(false);
    }
    
    if(health == -1) {
        return;
    }
    
    Int closedIcons = kShipMaxHealth - health;
    for(Int i = 0; i < closedIcons; ++i) {
        _healthIcons[i]->setHidden(true);
    }
}

Int Scene::getScore() {
    return _score;
}

void Scene::tick(Float dt) {
    if(_gameOver) {
        return;
    }
    
    _time += dt;
    
    formatTime();
}

// touches
void Scene::touchesBegan(const Vector2Pool &touches) {
    if(_gameOver) {
        restart();
        return;
    }
    
    Int touchesCount = 0;
    for(Vector2 v: touches) {
        
        _firePad->touchBegan(v);
        _movementPad->touchBegan(v);

        //allow 2 touches only
        touchesCount++;
        if(touchesCount == 2) {
            break;
        }
    }
}

void Scene::touchesMoved(const Vector2Pool &touches) {
    if(_gameOver) {
        return;
    }
    
    Int touchesCount = 0;
    for(Vector2 v: touches) {
        
        _firePad->touchMoved(v);
        _movementPad->touchMoved(v);
        //allow 2 touches only
        touchesCount++;
        if(touchesCount == 2) {
            break;
        }
    }
}

void Scene::touchesEnded(const Vector2Pool &touches) {
    if(_gameOver) {
        return;
    }
    
    Int touchesCount = 0;
    for(Vector2 v: touches) {
        
        _firePad->touchEnded(v);
        _movementPad->touchEnded(v);
        //allow 2 touches only
        touchesCount++;
        if(touchesCount == 2) {
            break;
        }
    }
}

void Scene::touchesCancelled(const Vector2Pool &touches) {
    if(_gameOver) {
        return;
    }
    
    touchesEnded(touches);
}
