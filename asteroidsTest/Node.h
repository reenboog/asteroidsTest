//
//  Node.h
//  kingTest
//
//  Created by Alex Gievsky on 18.06.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#ifndef __kingTest__Node__
#define __kingTest__Node__

#import "Types.h"

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

class Node {
private:
    Vector2 _pos;
    Float _scaleX;
    Float _scaleY;
    Float _rotation;
    
    Bool _active;
    Bool _hidden;
    
    Int _tag;
    Int _z;
    
    Node *_parent;
    NodePool _children;
private:
    void reorderChildren();
    Bool isChild(Node *child);
protected:
    void applyTransform();
public:
    Node();
    virtual ~Node();
public:
    virtual void cleanup();
    
    void loop(Float dt);
    virtual void visit();
    virtual void render();
    virtual Bool update(Float dt);
    //
    Node* getParent();
    void setParent(Node *parent);
    
    Bool addChild(Node *child);

    Bool removeChild(Node *child, Bool kill = true);
    
    Bool removeFromParent(Bool die = true);
    
    void removeAllChildren(Bool killAll = true);
    //
    void setZ(Int z);
    Int getZ();
    
    Bool isHidden();
    void setHidden(Bool hidden);
    
    void setPos(Vector2 pos);
    Vector2 getPos();
    
    void setScaleX(Float scale);
    Float getScaleX();
    
    void setScaleY(Float scale);
    Float getScaleY();
    
    void setScale(Float scale);
    Float getScale();
    
    void setRotation(Float rotation);
    Float getRotation();
};

#endif /* defined(__kingTest__Node__) */
