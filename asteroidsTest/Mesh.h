//
//  Mesh.h
//  asteroidsTest
//
//  Created by Alex Gievsky on 16.07.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#ifndef __asteroidsTest__Mesh__
#define __asteroidsTest__Mesh__

#import "Node.h"

class Mesh: public Node, public Blendable {
private:
    Float _lineWidth;
    
    VertexPosColorPool _vertices;
private:
    void recalcContentRadius();
public:
    Mesh();
    ~Mesh();
    
    void render();
    
    Bool setVertex(UInt index, const VertexPosColor &vertex, Bool skipColor = true);
    
    void setLineWidth(Float width);
    Float getLineWidth();
    
    //void setContentRadius(Float radius);
    Bool pointInArea(const Vector2 &pt);
    
    void setColor(const Color4B &color);
    void setAlpha(UChar alpha);
};

#endif /* defined(__asteroidsTest__Mesh__) */
