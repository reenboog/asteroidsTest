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

Bool Scene::init() {
    
    CGRect bounds = GetBounds();
    
    Bool isIpad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    
    _back = new Sprite("back.png");
    _back->setPos({400, 400});
    _back->setRotation(30);
    _back->setAlpha(255);
    _back->setRotation(-40);

    _back->applyComponent(ComponentGroup::runWithComponents({
                                                            RotateTo::runWithRotation(40, 1),
                                                            MoveTo::runWithPosition({10, 10}, 1),
                                                            FadeTo::runWithAlpha(20, 1),
                                                            ScaleTo::runWithScale(0.3, 1)
                                                            }));
    this->addChild(_back);
    
    Mesh *m = new Mesh();
    
    m->setPos({300, 200});
    m->setRotation(5);
    m->setLineWidth(5);
    m->setVertex(0, {{-100, -100, 0}, {200, 200, 200, 255}});
    m->setVertex(1, {{300, 300, 0}, {200, 200, 0, 255}}, false);
    m->setVertex(2, {{-200, 400, 0}, {0, 200, 0, 255}}, false);
    m->setVertex(3, {{-100, -100, 0}, {200, 200, 200, 255}});
    
    m->applyComponent(ComponentSequence::runWithComponents({
        MoveBy::runWithPositionDelta({100, 100}, 2),
        Hider::runWithHidden(true),
        Delay::runWithTime(2),
        Hider::runWithHidden(false),
        FadeTo::runWithAlpha(20, 1)
    }));
    
    this->addChild(m);
    
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