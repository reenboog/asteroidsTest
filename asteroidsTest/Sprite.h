//
//  Sprite.h
//  match3Test
//
//  Created by Alex Gievsky on 18.06.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#ifndef __match3Test__Sprite__
#define __match3Test__Sprite__

#import "Node.h"
#import "Types.h"
#import "Component.h"

// assume we have this vertex order:
// 3---2
// |   |
// 4---1

class Sprite: public Node, public Blendable {
protected:
    string _file;
    
    Texture _texture;
    
    Quad _quad;
    
    Vector2 _anchorPoint;
protected:
    Sprite();
    
    void loadTexture(string file, Float x, Float y, Float width, Float height);
    void updateQuad();
public:
    ~Sprite();
    
    Sprite(string file);
    Sprite(string file, Int x, Int y, Int w, Int h);
public:
    virtual void cleanup();
    
    virtual void render();
    virtual Bool update(Float dt);
    
    // set up uv-coords of 2 diagonal corners:
    // 1---
    // |   |
    //  ---2
    void setUV(Float u0, Float v0, Float u1, Float v1);
    void setUV(const UVRect &uv);
    UVRect getUV();
    
    Bool pointInArea(const Vector2 &pt);
    
    void setColor(const Color4B &color);
    void setAlpha(UChar alpha);
    
    Vector2 getAnchorPoint();
    void setAnchorPoint(Vector2 anchor);
};

// transformUV
// can be applied to sprites only
class TransformUV: public Component {
protected:
    Vector2 _velocity;
    // calling setUV with this component activated will
    // produce undesired behaviour
    UVRect _originalRect;
protected:
    TransformUV(const Vector2 &v);
    ~TransformUV();
    
    void setUp();
    void tick(Float dt);
public:
    static Component * runWithVelocity(const Vector2 &v);
};

#endif /* defined(__match3Test__Sprite__) */
