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

class Mesh: public Node {
private:
    Float _lineWidth;
    Color4B _color;
    
    VertexPosColorPool _vertices;
public:
    Mesh();
    ~Mesh();
    
    void render();
    
    Bool setVertex(UInt index, const VertexPosColor &vertex, Bool skipColor = true);
    
    void setLineWidth(Float width);
    Float getLineWidth();
    
    void setColor(const Color4B &color);
    Color4B getColor();
};

#endif /* defined(__asteroidsTest__Mesh__) */
