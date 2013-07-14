//
//  Node.cpp
//  kingTest
//
//  Created by Alex Gievsky on 18.06.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#include "Node.h"

Node::Node() {
    _pos = {0, 0};
    _scaleX = _scaleY = 1.0;
    _rotation = 0;
    
    _active = true;
    _hidden = false;
    
    _tag = 0;
    _z = 0;
    
    _parent = nullptr;
}

Node::~Node() {
    cleanup();
}

void Node::cleanup() {
    for(Node *child: _children) {
        delete child;
    }
    
    _children.clear();
}

void Node::visit() {
    
    if(_hidden) {
        return;
    }
    
    glPushMatrix();
    
    applyTransform();
    
//    if(!_children.empty()) {
//        _children[0]->visit();
//    }
    
//    //let's keep all the children unsorted fo simplicity
    for(Node *node: _children) {
        if(node->getZ() < 0) {
            node->visit();
        }
    }
        
    render();
    
    //sorry, but too lazy to calculate the displaceent of the first positive element
    //let's leave this for another test
    for(Node *node: _children) {
        if(node->getZ() >= 0) {
            node->visit();
        }
    }
    
    glPopMatrix();
}

void Node::render() {
    //override me
}

void Node::loop(Float dt) {
    for(Node *node: _children) {
        node->loop(dt);
    }
    
    update(dt);
}

Bool Node::update(Float dt) {
    return true;
}

void Node::reorderChildren() {
    sort(_children.begin(), _children.end(),
         [](Node *a, Node *b) {
             return a->getZ() < b->getZ();
         });
}

Bool Node::isChild(Node *child) {
    return find(_children.begin(), _children.end(), child) != _children.end();;
}

void Node::applyTransform() {
    glTranslatef(_pos.x, _pos.y, 0.0);
    glRotatef(_rotation, 0, 0, 1);
    glScalef(_scaleX, _scaleY, 1.0);
}

Node* Node::getParent() {
    return _parent;
}

void Node::setParent(Node *newParent) {
    //assume we don't share any children wetween parents
    //to keep simplicity
    _parent = newParent;
}

Bool Node::addChild(Node *child) {
    
    if(isChild(child)) {
        return false;
    }
    
    _children.push_back(child);
    child->setParent(this);
    
    reorderChildren();
        
    return true;
}

Bool Node::removeChild(Node *child, Bool kill) {
    if(!isChild(child)) {
        return false;
    }
    
    child->setParent(nullptr);
    
    auto it = find(_children.begin(), _children.end(), child);
    
    _children.erase(it);
    
    if(kill) {
        delete child;
    }

    return true;
}

void Node::removeAllChildren(bool killAll) {
    for(Node *child: _children) {
        child->setParent(nullptr);

        if(killAll) {
            delete child;
        }
    }
    
    _children.clear();
}

Bool Node::removeFromParent(Bool die) {
    if(_parent) {
        return _parent->removeChild(this, die);
    } else {
        return false;
    }
}

void Node::setZ(Int z) {
    _z = z;
    
    if(_parent) {
        _parent->reorderChildren();
    }
}

Int Node::getZ() {
    return _z;
}

Bool Node::isHidden() {
    return _hidden;
}

void Node::setHidden(Bool hidden) {
    _hidden = hidden;
}

void Node::setPos(Vector2 pos) {
    _pos = pos;
}

Vector2 Node::getPos() {
    return _pos;
}

void Node::setScaleX(Float scale) {
    _scaleX = scale;
}

Float Node::getScaleX() {
    return _scaleX;
}

void Node::setScaleY(Float scale) {
    _scaleY = scale;
}

Float Node::getScaleY() {
    return _scaleY;
}

void Node::setScale(Float scale) {
    _scaleX = _scaleY = scale;
}

Float Node::getScale() {
    if(_scaleX != _scaleY) {
        printf("!Trying to get scale but scaleX != scaleY");
    }
    
    return _scaleX;
}

void Node::setRotation(Float rotation) {
    _rotation = rotation;
}

Float Node::getRotation() {
    return _rotation;
}