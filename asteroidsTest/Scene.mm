//
//  GameScene.cpp
//  kingTest
//
//  Created by Alex Gievsky on 18.06.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#import "Scene.h"
#import "Sprite.h"
#import "Label.h"
#import "Mesh.h"

#import "Common.h"

#import "SoundManager.h"

#import "Inert.h"
#import "BoundToArea.h"
#import "Collider.h"
#import "Pad.h"

#import <iostream>
#import <sstream>

#import <mach/mach.h>

Scene::Scene(): Node() {
    _back = nullptr;
    _timeLabel = nullptr;
    _gameOver = true;
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
    
    // pads
    _movementPad = new Pad("moveBtn.png", [](){});
    _movementPad->setPos({0.075f * bounds.size.width, 0.1f * bounds.size.height});
    
    this->addChild(_movementPad);
    
    _firePad = new Pad("fireBtn.png", [](){});
    _firePad->setPos({0.925f * bounds.size.width, 0.1f * bounds.size.height});
    
    this->addChild(_firePad);
    
    
    //
    Sprite *s = new Sprite("ships.png");
    s->setPos({bounds.size.width / 2, bounds.size.height / 2});
    
    this->addChild(s);
    
  

    
    Int fontSize = isIpad ? 40 : 15;
    
    _timeLabel = new Label("This is a sample text. No kidding?", fontSize, "Commo");
    _timeLabel->setPos({bounds.size.width / 2.0f, bounds.size.height * 0.95f});
    this->addChild(_timeLabel);
    
    SoundManager::mngr()->playBackground("bgMusic");
    SoundManager::mngr()->preloadEffect("shoot0");
    SoundManager::mngr()->preloadEffect("shoot1");
    
    restart();
    
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
    
    //_back->setPos({_back->getPos().x + dt * 30, _back->getPos().y});
    
    tick(dt);
    
    return true;
}

void Scene::restart() {
    setScore(0);
    
    _gameOver = false;
}

void Scene::gameOver() {
    _gameOver = true;
    
    //SoundManager::mngr()->playEffect("lvlComplete.wav");
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

Int Scene::getScore() {
    return _score;
}

void Scene::tick(Float dt) {
    _time += dt;
    
    formatTime();
}

// touches
void Scene::touchesBegan(const Vector2Pool &touches) {
    for(Vector2 v: touches) {
        //printf("touch: %f, %f\n", v.x, v.y);
        Vector2 l = _firePad->getLocationInLocalSpace(v);
        
        printf("location: %f, %f\n", l.x, l.y);
    }

}

void Scene::touchesMoved(const Vector2Pool &touches) {
}

void Scene::touchesEnded(const Vector2Pool &touches) {
    
}

void Scene::touchesCancelled(const Vector2Pool &touches) {
    
}
