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
	// does nothing
	[NSException raise:NSInternalInconsistencyException format:@"this method should never be called, it only exists to avoid CCBReader compile errors"];
	return nil;
}

-(void) removeActionByTag:(int)tag target:(id)target
{
	// does nothing
	[NSException raise:NSInternalInconsistencyException format:@"this method should never be called, it only exists to avoid CCBReader compile errors"];
}

@end
