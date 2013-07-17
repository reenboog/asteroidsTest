//
//  Node.cpp
//  kingTest
//
//  Created by Alex Gievsky on 18.06.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#include "Node.h"

Node::Node(): Movable(), Scalable(), Rotatable(), Hideable() {
    _alive = true;
    
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
    maybeRemoveChildren();
    maybeAddChildren();
    
    for(Node *node: _children) {
        node->loop(dt);
    }
    
    updateComponents(dt);
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

void Node::maybeAddChildren() {
    if(!_childrenToAdd.empty()) {
        
        for(Node *child: _childrenToAdd) {
            _children.push_back(child);
            child->setParent(this);
        }
    
        reorderChildren();
        
        _childrenToAdd.clear();
    }
}

Bool Node::addChild(Node *child) {
    if(isChild(child)) {
        return false;
    }
    
    _childrenToAdd.push_back(child);
    
    return true;
}

void Node::maybeRemoveChildren() {
    if(!_childrenToRemove.empty()) {
        for(Node *child: _childrenToRemove) {
            _children.erase(remove(_children.begin(), _children.end(), child));
            delete child;
        }
        
        _childrenToRemove.clear();
    }
}

Bool Node::removeChild(Node *child) {
    if(!isChild(child)) {
        return false;
    }
    
    child->setParent(nullptr);
    
    _childrenToRemove.push_back(child);
    
    return true;
}

void Node::removeAllChildren() {
    for(Node *child: _children) {
        child->setParent(nullptr);
    }
    
    for(Node *child: _children) {
        _childrenToRemove.push_back(child);
    }
}

Bool Node::removeFromParent() {
    if(_parent) {
        return _parent->removeChild(this);
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