//
//  GameScene.cpp
//  kingTest
//
//  Created by Alex Gievsky on 18.06.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#include "Scene.h"
#include "Sprite.h"

Scene::Scene() {
    _back = nullptr;
    _gameOver = true;
}

Scene::~Scene() {
    cleanup();
}

Bool Scene::init() {
    
    _back = new Sprite("res/back.png");
    _back->setPos(v2(755 / 2, 300));
    _back->setRotation(0);
        
    this->addChild(_back);
    
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

Bool Scene::update(Float dt) {
    
    if(_gameOver) {
        return false;
    }
    
    Node::update(dt);
    
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
    
}