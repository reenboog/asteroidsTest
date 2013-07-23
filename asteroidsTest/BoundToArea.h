//
//  BoundToArea.h
//  asteroidsTest
//
//  Created by Alex Gievsky on 19.07.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#ifndef __asteroidsTest__BoundToArea__
#define __asteroidsTest__BoundToArea__

#import "Component.h"
#import "Object.h"

class BoundToArea: public Component, public InstanceCollector<BoundToArea> {
protected:
    Vector2 _initialPos;
    Rect4 _area;
protected:
    virtual ~BoundToArea();
    BoundToArea(const Rect4 &area);
    
    void setUp();
    void tick(Float dt);
public:
    static Component * runWithArea(const Rect4 &area);
};

inline BoundToArea::~BoundToArea(){
}

inline BoundToArea::BoundToArea(const Rect4 &area): Component(), InstanceCollector<BoundToArea>(this) {
    _area = area;
}

inline Component * BoundToArea::runWithArea(const Rect4 &area) {
    return new BoundToArea(area);
}

inline void BoundToArea::setUp() {
    _initialPos = dynamic_cast<Movable *>(_target)->getPos();
}

inline void BoundToArea::tick(Float dt) {
    Movable *t = dynamic_cast<Movable *>(_target);
    Vector2 pos = t->getPos();
    
    Vector2 newPos = pos;
    
    if(pos.x < _area.x) {
        newPos.x = _area.x;
    } else if(pos.x > _area.x + _area.w) {
        newPos.x = _area.x + _area.w;
    }
    
    if(pos.y < _area.y) {
        newPos.y = _area.y;
    } else if(pos.y > _area.y + _area.h) {
        newPos.y = _area.y + _area.h;
    }

    t->setPos(newPos);
}

template class InstanceCollector<BoundToArea>;

#endif /* defined(__asteroidsTest__BoundToArea__) */
