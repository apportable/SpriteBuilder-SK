/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import "KKNodeShared.h"
#import "SKNode+KoboldKit.h"
#import "KKNode.h"
#import "KKScene.h"
#import "CCScheduler.h"

@implementation KKNodeShared

+(void) deallocWithNode:(SKNode*)node
{
	NSLog(@"dealloc: %@", node);
}

+(void) scheduleNode:(SKNode*)node
{
	if (node.scene)
	{
		KKScene* scene = node.kkScene;
		CCScheduler* scheduler = scene.scheduler;
		
		if ([scheduler isTargetScheduled:(id<CCSchedulerTarget>)node] == NO)
		{
			NSLog(@"Scheduling%@%@ for node %@ (%p)",
				  [node respondsToSelector:@selector(deltaUpdate:)] ? @" deltaUpdate:" : @"",
				  [node respondsToSelector:@selector(fixedUpdate:)] ? @" fixedUpdate:" : @"",
				  NSStringFromClass([node class]), node);
			[scheduler scheduleTarget:(id<CCSchedulerTarget>)node];
			[scheduler setPaused:node.paused target:(id<CCSchedulerTarget>)node];
		}
	}
}

// TODO: pause/resume schedulers when paused property changes

+(void) unscheduleNode:(SKNode*)node
{
	[node.kkScene.scheduler unscheduleTarget:(id<CCSchedulerTarget>)node];
}

+(void) didMoveToParentWithNode:(SKNode*)node
{
	if ([node respondsToSelector:@selector(isKoboldKitNode)])
	{
		[(id<KKNodeProtocol>)node didMoveToParent];
		[self scheduleNode:node];
	}
}

+(void) willMoveFromParentWithNode:(SKNode*)node
{
	if ([node respondsToSelector:@selector(isKoboldKitNode)])
	{
		[(id<KKNodeProtocol>)node willMoveFromParent];
		[self unscheduleNode:node];
	}
}

+(void) sendChildrenWillMoveFromParentWithNode:(SKNode*)node
{
	if ([node respondsToSelector:@selector(isKoboldKitNode)])
	{
		CCScheduler* scheduler = node.kkScene.scheduler;
		
		for (SKNode* child in node.children)
		{
			if ([child respondsToSelector:@selector(isKoboldKitNode)])
			{
				[(id<KKNodeProtocol>)child willMoveFromParent];
				[scheduler unscheduleTarget:(id<CCSchedulerTarget>)child];
			}
		}
	}
}

#pragma mark Debug

+(void) addNodeFrameShapeToNode:(SKNode*)node
{
	SKShapeNode* shape = [SKShapeNode node];
	CGPathRef path = CGPathCreateWithRect(node.frame, nil);
	shape.path = path;
	CGPathRelease(path);
	shape.antialiased = NO;
	shape.lineWidth = 1.0;
	shape.strokeColor = [SKColor orangeColor];
	[node addChild:shape];
}

+(void) addNodeAnchorPointShapeToNode:(SKNode*)node
{
	SKShapeNode* shape = [SKShapeNode node];
	CGRect center = CGRectMake(-1, -1, 2, 2);
	CGPathRef path = CGPathCreateWithRect(center, nil);
	shape.path = path;
	CGPathRelease(path);
	shape.antialiased = NO;
	shape.lineWidth = 1.0;
	[node addChild:shape];
	
	id sequence = [SKAction sequence:@[[SKAction runBlock:^{
		shape.strokeColor = [SKColor colorWithRed:KKRANDOM_0_1() green:KKRANDOM_0_1() blue:KKRANDOM_0_1() alpha:1.0];
	}], [SKAction waitForDuration:0.2]]];
	[shape runAction:[SKAction repeatActionForever:sequence]];
}

@end
