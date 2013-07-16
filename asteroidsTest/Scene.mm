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
    
    _back->applyComponent(MoveBy::runWithPositionDeltaAndDuration({300, 300}, 5));
    //_back->setHidden(true);
    this->addChild(_back);
    
    Int fontSize = isIpad ? 40 : 15;
    
    _timeLabel = new Label("This is a sample text. No kidding?", fontSize, "Commo");
    _timeLabel->setPos({bounds.size.width / 2.0f, bounds.size.height * 0.95f});
    this->addChild(_timeLabel);
    
    //_timeLabel->applyComponent(Delay::runWithTime(5));

    
    SoundManager::mngr()->playBackground("bgMusic");
    SoundManager::mngr()->preloadEffect("shoot0");
    SoundManager::mngr()->preloadEffect("shoot1");
    
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
    
    static float sec = 0;
    sec += dt;
    
    static float sec1 = 0;
    sec1 += dt;

    
    if(sec > 2) {
        sec = 0;
        SoundManager::mngr()->playEffect("shoot0");
    }
    
//    if(sec1 > 3) {
//        sec1 = 0;
//        //SoundManager::mngr()->playEffect("shoot1");
//        struct task_basic_info info;
//        mach_msg_type_number_t size = sizeof(info);
//        kern_return_t kerr = task_info(mach_task_self(),
//                                       TASK_BASIC_INFO,
//                                       (task_info_t)&info,
//                                       &size);
//        if( kerr == KERN_SUCCESS ) {
//            NSLog(@"Memory in use (in bytes): %u", info.resident_size);
//        } else {
//            NSLog(@"Error with task_info(): %s", mach_error_string(kerr));
//        }
//    }
    
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