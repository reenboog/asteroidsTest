//
//  BoundToArea.h
//  asteroidsTest
//
//  Created by Alex Gievsky on 19.07.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#ifndef __asteroidsTest__BoundToArea__
#define __asteroidsTest__BoundToArea__

#include "Component.h"
#include "Object.h"

class BoundToArea: public Component, public InstanceCollector<BoundToArea> {
protected:
    Vector2 _initialPos;
    Vector2 _areaPos;
    Size2 _areaSize;
protected:
    virtual ~BoundToArea();
    BoundToArea(const Vector2 &pos, const Size2 &size);
    
    void setUp();
    void tick(Float dt);
public:
    static Component * runWithArea(const Vector2 &pos, const Size2 &size);
};

BoundToArea::~BoundToArea(){
}

BoundToArea::BoundToArea(const Vector2 &pos, const Size2 &size): Component(), InstanceCollector<BoundToArea>(this) {
    _areaPos = pos;
    _areaSize = size;
}

Component * BoundToArea::runWithArea(const Vector2 &pos, const Size2 &size) {
    return new BoundToArea(pos, size);
}

void BoundToArea::setUp() {
    _initialPos = dynamic_cast<Movable *>(_target)->getPos();
}

void BoundToArea::tick(Float dt) {
    Movable *t = dynamic_cast<Movable *>(_target);
    Vector2 pos = t->getPos();
    
    if(pos.x < _areaPos.x || pos.y < _areaPos.y || pos.x > _areaPos.x + _areaSize.w || pos.y > _areaPos.y + _areaSize.h) {
        t->setPos(_initialPos);
    }
}

template class InstanceCollector<BoundToArea>;

#endif /* defined(__asteroidsTest__BoundToArea__) */
