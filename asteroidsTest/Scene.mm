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

#import <iostream>
#import <sstream>

Scene::Scene() {
    _back = nullptr;
    _timeLabel = nullptr;
    _gameOver = true;
}

Scene::~Scene() {
    //cleanup();
}

Bool Scene::init() {
    
    _back = new Sprite("res/back.png");
    _back->setPos({400, 400});
    _back->setRotation(30);
    //_back->setHidden(true);
    
    this->addChild(_back);
    
    _timeLabel = new Label("This is a sample text. No kidding?", 50);
    _timeLabel->setPos({100, 200});
    this->addChild(_timeLabel);

    
//    SoundManager::mngr()->playBackground("md-1.mp3");
//    SoundManager::mngr()->preloadEffect("btnClick.wav");
//    SoundManager::mngr()->preloadEffect("chipBreak.wav");
//    SoundManager::mngr()->preloadEffect("lvlComplete.wav");
    
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
    
    _back->setPos({_back->getPos().x + dt * 30, _back->getPos().y});
    
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