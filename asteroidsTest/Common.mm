//
//  Common.mm
//  asteroidsTest
//
//  Created by Alex Gievsky on 16.07.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#include <stdio.h>

CGRect GetBounds() {
    CGRect bounds = [[UIScreen mainScreen] bounds];
    
    // we're in landscape mode
    bounds = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.height, bounds.size.width);
    
    return bounds;
}