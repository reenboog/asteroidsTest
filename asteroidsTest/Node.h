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
#import "Object.h"

//#import <OpenGLES/ES1/gl.h>
//#import <OpenGLES/ES1/glext.h>

class Node: public Object, public Scalable, public Rotatable, public Hideable, public Intersectable {
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
    Bool isAlive();
    virtual void setAlive(Bool alive);
    //
    Node* getParent();
    void setParent(Node *parent);
    
    void setTag(Int tag);
    Int getTag();
    
    Bool addChild(Node *child);
    
    // a bit better interseciton check according to an average of scaleX & scaleY
    Float getContentRadius();
    
    Bool intersectsWithObject(Intersectable *obj);
    
    // world to local
    Vector2 getLocationInLocalSpace(const Vector2 &pos);
    // local to world
    Vector2 getAbsolutePos();
    Float getAbsoluteRotation();

    Float getAbsoluteScaleX();
    Float getAbsoluteScaleY();

    Bool removeChild(Node *child);
    Bool removeFromParent();
    void removeAllChildren();
    //
    void setZ(Int z);
    Int getZ();    
};

#endif /* defined(__kingTest__Node__) */
