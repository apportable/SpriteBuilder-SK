//
//  NSValue+CCBReader.h
//  SB+SpriteKit
//
//  Created by Steffen Itterheim on 04/02/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCBSpriteKitCompatibility.h"

@interface NSValue (CCBReader)

#if SB_PLATFORM_IOS
+(NSValue*) valueWithSize:(CGSize)size;
+(NSValue*) valueWithPoint:(CGPoint)point;
+(NSValue*) valueWithRect:(CGRect)rect;
#endif

@end
