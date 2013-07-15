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

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

using namespace std;

typedef char Char;
typedef unsigned char UChar;
typedef int Int;
typedef bool Bool;
typedef float Float;
typedef double Double;

class Node;

class Vector2 {
public:
    Float x, y;
    
    Bool operator == (const Vector2 &r) {
        return x == r.x && y == r.y;
    }
    
    Vector2 operator +(const Vector2 &r) {
        Vector2 result{x + r.x, y + r.y};
        return result;
    }
    
    Vector2& operator +=(const Vector2 &r) {
        x = x + r.x;
        y = y + r.y;
        
        return *this;
    }
    
    Vector2 operator -() const {
        Vector2 result = *this;
        result.x = -x;
        result.y = -y;
        
        return result;
    }
    
    Vector2& operator -=(const Vector2 &r) {
        *this += -r;
        return *this;
    }
};
    
class Vector3 {
public:
    Float x, y, z;
};

#define v2(x, y) (Vector2{(Float)x, (Float)y})

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
    Int w, h;
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
    
struct Vertex {
    Vector3 pos;
    Color4B color;
    UV uv;
};
    
struct Quad {
    Vertex tl;
    Vertex bl;
    Vertex tr;
    Vertex br;
};
    
typedef vector<Node *> NodePool;
typedef map<string, Texture> TextureMap;


#endif