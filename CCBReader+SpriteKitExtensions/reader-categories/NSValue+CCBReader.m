//
//  NSValue+CCBReader.m
//  SB+SpriteKit
//
//  Created by Steffen Itterheim on 04/02/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSValue+CCBReader.h"

@implementation NSValue (CCBReader)

#if SB_PLATFORM_IOS
+(NSValue*) valueWithSize:(CGSize)size
{
	return [NSValue valueWithCGSize:size];
}

+(NSValue*) valueWithPoint:(CGPoint)point
{
	return [NSValue valueWithCGPoint:point];
}

+(NSValue*) valueWithRect:(CGRect)rect
{
	return [NSValue valueWithCGRect:rect];
}
#endif

@end
