//
//  Common.h
//  asteroidsTest
//
//  Created by Alex Gievsky on 14.07.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#ifndef asteroidsTest_Common_h
#define asteroidsTest_Common_h

#define offsetof(t, d) __builtin_offsetof(t, d)

#define degreeToRadians(a) ((a) * 0.01745329252f)
#define radiansToDegree(a) ((a) * 57.29577951f)

#define kShipTag        1000
#define kAsteroidTag    1001
#define kBullet0Tag     1002
#define kBullet1Tag     1003
#define kLevelUpTag     1004

CGRect GetBounds();

#endif
