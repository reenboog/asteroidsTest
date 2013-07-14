//
//  FileUtils.m
//  asteroidsTest
//
//  Created by Alex Gievsky on 14.07.13.
//  Copyright (c) 2013 reenboog. All rights reserved.
//

#import "FilesUtils.h"

@implementation FilesUtils

+ (NSString *) getFileName: (NSString *) fileName skipIdioms: (BOOL) skip {
    if(!skip && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        NSString *nameWithoutExtension = [fileName stringByDeletingPathExtension];
        NSString *extension = [fileName pathExtension];
        NSString *newName = [NSString stringWithFormat:@"%@-ipad.%@", nameWithoutExtension, extension];        
        return newName;
    }
    return fileName;
}

@end
