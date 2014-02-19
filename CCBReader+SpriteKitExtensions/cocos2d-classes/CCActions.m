//
//  CCActions.m
//  SB+KoboldKit
//
//  Created by Steffen Itterheim on 19/02/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCActions.h"
#import "CCBSpriteKitCompatibility.h"


@implementation CCActionSequence

+(id) actionOne:(id)anAction two:(id)anotherAction
{
	NSAssert(anAction, @"CCActionSequence actionOne:two: - first action is nil");
	NSAssert(anotherAction, @"CCActionSequence actionOne:two: - second action is nil");
	return [CCActionSequence actionWithArray:@[anAction, anotherAction]];
}

+(id) actionWithArray:(NSArray*)actions
{
#if DEBUG
	for (id a in actions)
	{
		NSAssert3([a isKindOfClass:[SKAction class]], @"object %@ (%@) from sequence %@ is not a SKAction", a, NSStringFromClass([a class]), actions);
	}
#endif
	
	return [SKAction sequence:actions];
}

@end



@implementation CCActionDelay

+(id) actionWithDuration:(CGFloat)duration
{
	return [SKAction waitForDuration:duration];
}

@end



@implementation CCActionCallFunc

+(id) actionWithTarget:(id)target selector:(SEL)selector
{
	NSAssert1(target, @"CCActionCallFunc: target is nil, can't perform selector: %@", NSStringFromSelector(selector));
	NSAssert1(selector, @"CCActionCallFunc: can't perform nil selector on target: %@", target);
	
	return [SKAction performSelector:selector onTarget:target];
}

@end