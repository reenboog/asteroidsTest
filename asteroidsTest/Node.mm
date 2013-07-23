//
//  Node.cpp
//  kingTest
//
//  Created by Alex Gievsky on 18.06.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#import "Node.h"

Node::Node(): Scalable(), Rotatable(), Hideable(), Intersectable() {
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

Float Node::getContentRadius() {
    Float avScale = (getScaleX() + getScaleX()) / 2.0;
    
    return Measurable::getContentRadius() * avScale;
}

Vector2 Node::getLocationInLocalSpace(const Vector2 &pos) {
    
    Vector2 p = getAbsolutePos();
    
    return pos.sub(p);
}

Bool Node::intersectsWithObject(Intersectable *obj) {
    Vector2 distance = this->getAbsolutePos().sub(((Node *)obj)->getAbsolutePos());
    
    return distance.length() <= (this->getContentRadius() + obj->getContentRadius());
}

Vector2 Node::getAbsolutePos() {
    Vector2 v = _pos;
    
    //v = v.rotate(_rotation);
    
    if(_parent) {
        /// an old version with no effect of rotation and scaling
        /// return _pos.add(_parent->getAbsolutePos());
        ///

        v = v.rotate(_parent->getAbsoluteRotation());
        v.x *= _parent->getAbsoluteScaleX();
        v.y *= _parent->getAbsoluteScaleY();
        
        v = v.add(_parent->getAbsolutePos());
        
        return v;
    }
    
    return v;
}

Float Node::getAbsoluteRotation() {
    if(_parent) {
        return _rotation + _parent->getAbsoluteRotation();
    }
    return _rotation;
}

Float Node::getAbsoluteScaleX() {
    if(_parent) {
        return _scaleX * _parent->getAbsoluteScaleX();
    }
    
    return _scaleX;
}

Float Node::getAbsoluteScaleY() {
    if(_parent) {
        return _scaleY * _parent->getAbsoluteScaleY();
    }
    
    return _scaleX;
}

void Node::setParent(Node *newParent) {
    //assume we don't share any children wetween parents
    //to keep simplicity
    _parent = newParent;
}

void Node::setTag(Int tag) {
    _tag = tag;
}

Int Node::getTag() {
    return _tag;
}

void Node::maybeAddChildren() {
    if(!_childrenToAdd.empty()) {
        
        for(Node *child: _childrenToAdd) {
            _children.push_back(child);
            //child->setParent(this);
        }
    
        reorderChildren();
        
        _childrenToAdd.clear();
    }
}

Bool Node::addChild(Node *child) {
    if(isChild(child) || find(_childrenToAdd.begin(), _childrenToAdd.end(), child) != _childrenToAdd.end()) {
        return false;
    }

    child->setParent(this);
    _childrenToAdd.push_back(child);
    
    return true;
}

void Node::maybeRemoveChildren() {
    if(!_childrenToRemove.empty()) {
        for(Node *child: _childrenToRemove) {
            _children.erase(remove(_children.begin(), _children.end(), child));
            
            child->setParent(nullptr);
            
            delete child;
        }
        
        _childrenToRemove.clear();
    }
}

Bool Node::isAlive() {
    return _alive;
}

void Node::setAlive(Bool alive) {
    _alive = alive;
}

Bool Node::removeChild(Node *child) {
    if(!isChild(child) || find(_childrenToRemove.begin(), _childrenToRemove.end(), child) != _childrenToRemove.end()) {
        return false;
    }
    
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