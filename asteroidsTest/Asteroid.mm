//
//  Asteroid.mm
//  asteroidsTest
//
//  Created by Alex Gievsky on 21.07.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#import "Asteroid.h"
#import "Common.h"
#import "Component.h"
#import "Inert.h"
#import "Collider.h"

#define kAsteroidMaxVelocity 100
#define kAsteroidSizeScale 17
#define kAsteroidMinSegments 5
#define kAsteroidMaxLifeTime 5
#define kAsteroidLineWidth 2

Asteroid::~Asteroid() {
    
}

Asteroid::Asteroid(Int level, const Vector2 &pos): Mesh() {
    this->setTag(kAsteroidTag);
    this->setPos(pos);
    
    Int segments = kAsteroidMinSegments + rand() % kAsteroidMinSegments;
    
    Bool isIpad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;

    float sizeScale = 0.5;
    if(isIpad) {
        sizeScale = 1;
    }
    
    Float stride = 360.0 / segments;
    
    for(Int i = 0; i < segments; ++i) {
        Float x = cosf(degreeToRadians(stride * (i + 1)));
        Float y = sinf(degreeToRadians(stride * (i + 1)));
        
        x *= (level + 1) * sizeScale * (kAsteroidSizeScale + rand() % (kAsteroidSizeScale / 2));
        y *= (level + 1) * sizeScale * (kAsteroidSizeScale + rand() % (kAsteroidSizeScale / 2));
        
        setVertex(i, {{x, y, 0}, {30, 30, 30, 200}});
    }
    
    // decrease radius a bit
    setContentRadius(getContentRadius() * 0.7);
    setLineWidth(kAsteroidLineWidth);
    
    CGRect bounds = GetBounds();
    Vector2 inertion = {bounds.size.width / 2, bounds.size.height / 2};
    inertion.decrease(getPos());
    
    Int multiplier = rand() % 2 ? -1 : 1;
    Vector2 randDir = inertion.mul(0.5);
    //randDir = {1.0f * (rand() % static_cast<Int>(randDir.x + 1)), 1.0f * (rand() % static_cast<Int>(randDir.y + 1))};
    randDir = randDir.mul(multiplier);
    
    inertion.increase(randDir);
    inertion.normalize();
    inertion = inertion.mul(kAsteroidMaxVelocity);

    _inertion = (Inert *)Inert::runWithVelocity(inertion);

    this->applyComponent(_inertion);
    this->applyComponent(Collider::runWithBlock([=](Intersectable *obj){
        Node *node = dynamic_cast<Node *>(obj);
        
        if(node->isAlive() && (node->getTag() == kBullet0Tag || node->getTag() == kBullet1Tag)) {
            node->setAlive(false);
            node->removeFromParent();
        }
    }));
    
    setLevel(level);
    
    //self-destroy in few seconds
    this->applyComponent(SequenceComponent::runWithComponents({
        Delay::runWithTime(kAsteroidMaxLifeTime + rand() % kAsteroidMaxLifeTime),
        CallBlock::runWithBlock([this](){
            setAlive(false);
        })
    }));
}

void Asteroid::setLevel(Int level) {
    _level = level;
}

Int Asteroid::getLevel() {
    return _level;
}

void Asteroid::setVelocity(const Vector2 &v) {
    _inertion->setVelocity(v);
}

Vector2 Asteroid::getVelocity() {
    return _inertion->getVelocity();
}

void Asteroid::setAlive(Bool alive) {
    // check level status here
    Node::setAlive(alive);
    
    onDamage();
}

void Asteroid::onDamage() {
    this->applyComponent(SequenceComponent::runWithComponents({
        GroupComponent::runWithComponents({
            FadeTo::runWithAlpha(0, 0.2),
            ScaleTo::runWithScale(0.001, 0.3)
        }),
        CallBlock::runWithBlock([=](){
            if(_level != 0) {
                Asteroid *a = new Asteroid(_level - 1, getPos());
                this->getParent()->addChild(a);

                if(rand() % 2) {
                    Asteroid *b = new Asteroid(_level - 1, getPos());
                    b->setVelocity(a->getVelocity().mul(-1));
                    
                    this->getParent()->addChild(b);
                }
            }
            
            this->removeFromParent();
        })
    }));
}

void Asteroid::render() {
    if(_vertices.size() < 3) {
        return;
    }
    
    Node::render();
    
    glLineWidth(_lineWidth);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    Int offset = (Int)_vertices.data();
    Int diff = offsetof(VertexPosColor, pos);
#define kMeshVertexStride sizeof(VertexPosColor)
	glVertexPointer(3, GL_FLOAT, kMeshVertexStride, (void *) (offset + diff));
    
    diff = offsetof(VertexPosColor, color);
    
    vector<Color4B> colors;
    
    // sad but true...
    for(int i = 0; i < _vertices.size(); ++i) {
        colors.push_back({0, 0, 0, 150});
    }
    
    Int colorOffset = (Int)colors.data();
	glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(Color4B), (void *)(colorOffset));
    
	glDrawArrays(GL_TRIANGLE_FAN, 0, _vertices.size());
    
    glColorPointer(4, GL_UNSIGNED_BYTE, kMeshVertexStride, (void *)(offset + diff));
    glDrawArrays(GL_LINE_LOOP, 0, _vertices.size());
    
    glDisable(GL_BLEND);
}

