//
//  Node.h
//  kingTest
//
//  Created by Alex Gievsky on 18.06.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#ifndef __kingTest__Node__
#define __kingTest__Node__

#include "Types.h"
#include "Object.h"

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

class Node: public Object, public Movable, public Scalable, public Rotatable, public Hideable {
private:
    Bool _alive;
    
    Int _tag;
    Int _z;
    
    Node *_parent;
    NodePool _children;
    
    NodePool _childrenToAdd;
    NodePool _childrenToRemove;
private:
    void reorderChildren();
    Bool isChild(Node *child);
    
    void maybeAddChildren();
    void maybeRemoveChildren();
    
    Bool isAlive();
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

    Bool removeChild(Node *child);
    Bool removeFromParent();
    void removeAllChildren();
    //
    void setZ(Int z);
    Int getZ();    
};

#endif /* defined(__kingTest__Node__) */
