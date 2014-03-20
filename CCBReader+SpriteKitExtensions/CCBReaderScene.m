//
//  CCBReaderScene.m
//  SB+SpriteKit
//
//  Created by Steffen Itterheim on 20/03/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCBReaderScene.h"

@implementation CCBReaderScene

-(void) update:(NSTimeInterval)currentTime
{
	// forward to children as needed
	for (SKNode* child in self.children)
	{
		if ([child respondsToSelector:@selector(update:)])
		{
			[(id)child update:currentTime];
		}
	}
}

-(void) didEvaluateActions
{
	// forward to children as needed
	for (SKNode* child in self.children)
	{
		if ([child respondsToSelector:@selector(didEvaluateActions)])
		{
			[(id)child didEvaluateActions];
		}
	}
}

-(void) didSimulatePhysics
{
	// forward to children as needed
	for (SKNode* child in self.children)
	{
		if ([child respondsToSelector:@selector(didSimulatePhysics)])
		{
			[(id)child didSimulatePhysics];
		}
	}
}

@end
