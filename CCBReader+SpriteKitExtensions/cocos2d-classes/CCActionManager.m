//
//  CCActionManager.m
//  SB+KoboldKit
//
//  Created by Steffen Itterheim on 19/02/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCActionManager.h"
#import "CCBSpriteKitCompatibility.h"

@implementation CCActionManager

#pragma mark Action Manager

-(SKAction*) getActionByTag:(int)tag target:(id)target
{
	SKNode* targetNode = (SKNode*)target;
	NSAssert2([targetNode isKindOfClass:[SKNode class]], @"CCActionManager: target %@ (%@) is not a node class", target, NSStringFromClass([target class]));
	
	SKAction* action = [targetNode actionForKey:[NSString stringWithFormat:@"tag:%i", tag]];
	return action;
}

-(void) removeActionByTag:(int)tag target:(id)target
{
	SKNode* targetNode = (SKNode*)target;
	NSAssert2([targetNode isKindOfClass:[SKNode class]], @"CCActionManager: target %@ (%@) is not a node class", target, NSStringFromClass([target class]));
	
	[targetNode removeActionForKey:[NSString stringWithFormat:@"tag:%i", tag]];
}

@end
