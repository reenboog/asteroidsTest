//
//  Types.h
//  asteroidsTest
//
//  Created by Alex Gievsky on 14.07.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#ifndef __asteroidsTest__Types__
#define __asteroidsTest__Types__

#import <vector>
#import <string>
#import <map>
#import <algorithm>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "Common.h"

using namespace std;

typedef char Char;
typedef unsigned char UChar;
typedef short Short;
typedef unsigned int UInt;
typedef int Int;
typedef bool Bool;
typedef float Float;
typedef double Double;

class Node;
class Sprite;
class Component;
class Intersectable;

typedef function<void()> Void_VoidFunc;
typedef function<void(Intersectable *)> Void_IntersectableFunc;

class Vector2 {
public:
    Float x, y;
    
    Float length() const {
        return sqrtf(x * x + y * y);
    }
    
    Bool equals(const Vector2 &r) const {
        return x == r.x && y == r.y;
    }
    
    Vector2 add(const Vector2 &r) const {
        Vector2 result{x + r.x, y + r.y};
        return result;
    }
    
    Vector2& increase(const Vector2 &r) {
        x = x + r.x;
        y = y + r.y;
        
        return *this;
    }
    
    Vector2 mul(Float s) const {
        return Vector2{x * s, y * s};
    }
    
    Vector2 neg() const {
        Vector2 result = *this;
        result.x = -x;
        result.y = -y;
        
        return result;
    }
    
    Float dot(const Vector2 &v) const {
        return x * v.x + y * v.y;
    }
    
    Float angleBetween(const Vector2 &v) const {
        Vector2 a = this->normalized();
        Vector2 b = v.normalized();

        float angle = atan2f(a.x * b.y - a.y * b.x, a.dot(b));
        if(fabs(angle) < FLT_EPSILON ) {
            return 0.f;
        } else {
            return angle;
        }
    }
    
    Vector2 rotate(const Vector2 &pivot, Float angle) {
        Vector2 r = this->sub(pivot);
        float t = r.x;
        float cosa = cosf(degreeToRadians(-angle)), sina = sinf(degreeToRadians(-angle));

        r.x =  t * cosa - r.y * sina;
        r.y = t * sina + r.y * cosa;
        r.increase(pivot);

        return r;
    }
    
    Vector2 rotate(Float angle) {
        return rotate({0.0, 0.0}, angle);
    }
    
    void normalize() {
        Float length = this->length();
        x /= length;
        y /= length;
    }
    
    Vector2 normalized() const{
        Vector2 v = *this;
        v.normalize();
        
        return v;
    }
    
    Vector2& decrease(const Vector2 &r) {
        this->increase(r.neg());
        return *this;
    }
    
    Vector2 sub(const Vector2 &r) const {
        return Vector2{x - r.x, y - r.y};
    }
};
    
class Vector3 {
public:
    Float x, y, z;
};

inline Float cut(Float num, Float min, Float max) {
    if(num < min)
    {
        num = min;
    } else if(num > max) {
        num = max;
    }
    return num;
}

struct Size2 {
    Float w, h;
    
    Size2 mul(Float s) {
        return Size2{w * s, h * s};
    }
};

struct Rect4 {
    Float x, y, w, h;
};

struct UV {
    Float u, v;
};

struct UVRect {
    UV _0;
    UV _1;
};
    
struct Texture {
    GLuint texture;
    GLint width;
    GLint height;
};
    
struct Color4B {
    UChar r;
    UChar g;
    UChar b;
    UChar a;
};

struct VertexPosColor {
    Vector3 pos;
    Color4B color;
};
    
struct VertexPosColorUV {
    Vector3 pos;
    Color4B color;
    UV uv;
};
    
struct Quad {
    VertexPosColorUV tl;
    VertexPosColorUV bl;
    VertexPosColorUV tr;
    VertexPosColorUV br;
};
    
typedef vector<Node *> NodePool;
typedef vector<Sprite *> SpritePool;
typedef map<string, Texture> TextureMap;
typedef vector<VertexPosColor> VertexPosColorPool;
typedef vector<Component *> ComponentPool;
typedef vector<Vector2> Vector2Pool;

#endif