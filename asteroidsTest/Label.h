//
//  Label.h
//  asteroidsTest
//
//  Created by Alex Gievsky on 15.07.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#import "Sprite.h"

@class Texture2D;

class Label: public Sprite {
private:
    Texture2D *_tex;
    
    string _string;
    string _font;

    Float _fontSize;
public:
    Label(const string &str, Float size = 20, const string &font = "Commo");
    ~Label();
    
    void setString(const string &str);
    string getString();
    
    void render();
};