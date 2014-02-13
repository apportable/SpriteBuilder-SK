/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import "KKNodeShared.h"
#import "KKNode.h"
#import "KKScene.h"
#import "KKView.h"
#import "CCScheduler.h"

@implementation KKNodeShared

#pragma mark Init/Dealloc

+(void) deallocWithNode:(SKNode*)node
{
	NSLog(@"dealloc %p: %@", node, node);
	
	[((id<KKNodeProtocol>)node).scheduler unscheduleTarget:(id<CCSchedulerTarget>)node];
}

#pragma mark Node Schedule

+(CCTimer*) node:(NSObject<KKNodeProtocol>*)node schedule:(SEL)selector interval:(CCTime)interval repeat:(NSUInteger)repeat delay:(CCTime)delay
{
	NSAssert(selector, @"schedule: selector is nil");
	NSAssert(interval >= 0, @"schedule: interval is negative, must be 0 or greater");
	NSAssert(selector != @selector(frameUpdate:) && selector != @selector(fixedUpdate:) && selector != @selector(didEvaluateActions) && selector != @selector(didSimulatePhysics),
			 @"The frameUpdate: / fixedUpdate: / didEvaluateActions / didSimulatePhysics selectors are scheduled automatically when implemented.");
	NSAssert(selector != @selector(update:), @"Instead of scheduling update: implement -(void)frameUpdate:(CCTime)delta to receive once-per-frame updates.");
	NSAssert([node respondsToSelector:selector], @"schedule: selector '%@' not implemented by target: %@ (%p)", NSStringFromSelector(selector), node, node);
	
	[KKNodeShared node:node unschedule:selector];
	
	void (*imp)(id, SEL, CCTime) = (__typeof(imp))[node methodForSelector:selector];
	
	CCTimer* timer = [node.scheduler scheduleBlock:^(CCTimer *t) {
		imp(node, selector, t.deltaTime);
	} forTarget:(id<CCSchedulerTarget>)node withDelay:delay];
	
	timer.repeatCount = repeat;
	timer.repeatInterval = interval;
	timer.userData = NSStringFromSelector(selector);
	
	return timer;
}

+(void) node:(id<KKNodeProtocol>)node unschedule:(SEL)selector
{
	NSString* selectorName = NSStringFromSelector(selector);
	BOOL didInvalidate = NO;
	
	for (CCTimer* timer in [node.scheduler timersForTarget:(id<CCSchedulerTarget>)node])
	{
		if ([selectorName isEqual:timer.userData])
		{
			[timer invalidate];
			didInvalidate = YES;
		}
	}
	
	if (didInvalidate == NO)
	{
		NSLog(@"unschedule: selector %@ is not scheduled on target %@ (%p).", NSStringFromSelector(selector), node, node);
	}
}

+(void) unscheduleAllSelectorsWithNode:(id<KKNodeProtocol>)node
{
	Class stringClass = [NSString class];
	for (CCTimer* timer in [node.scheduler timersForTarget:(id<CCSchedulerTarget>)node])
	{
		if ([timer.userData isKindOfClass:stringClass])
		{
			[timer invalidate];
		}
	}
}

#pragma mark Scheduling

+(void) scheduleNode:(SKNode*)node
{
	CCScheduler* scheduler = ((id<KKNodeProtocol>)node).scheduler;
	
	if (scheduler)
	{
#if DEBUG
		BOOL update = [node respondsToSelector:@selector(frameUpdate:)];
		BOOL fixedUpdate = [node respondsToSelector:@selector(fixedUpdate:)];
		BOOL evaluateActions = [node respondsToSelector:@selector(didEvaluateActions)] && [node isKindOfClass:[SKScene class]] == NO;
		BOOL simulatePhysics = [node respondsToSelector:@selector(didSimulatePhysics)] && [node isKindOfClass:[SKScene class]] == NO;
		if (update || fixedUpdate || evaluateActions || simulatePhysics)
		{
			NSLog(@"Scheduling%@%@%@%@ for node %@ (%p)",
				  update ? @" frameUpdate:" : @"", fixedUpdate ? @" fixedUpdate:" : @"",
				  evaluateActions ? @" didEvaluateActions" : @"", simulatePhysics ? @" didSimulatePhysics" : @"",
				  NSStringFromClass([node class]), node);
		}
#endif

		[scheduler scheduleTarget:(id<CCSchedulerTarget>)node];
		[scheduler setPaused:node.paused target:(id<CCSchedulerTarget>)node];
	}
}

+(void) pauseSchedulerForNode:(SKNode*)node paused:(BOOL)paused
{
	CCScheduler* scheduler = ((id<KKNodeProtocol>)node).scheduler;
	[scheduler setPaused:paused target:(id<CCSchedulerTarget>)node];
}

#pragma mark Move to/from Parent

+(void) didMoveToParentWithNode:(SKNode*)node
{
	if ([node respondsToSelector:@selector(isKoboldKitNode)])
	{
		[(id<KKNodeProtocol>)node didMoveToParent];
		[KKNodeShared scheduleNode:node];
		
		if ([KKView drawsNodeFrames])
			[KKNodeShared addNodeFrameShapeToNode:node];
		if ([KKView drawsNodeAnchorPoints])
			[KKNodeShared addNodeAnchorPointShapeToNode:node];
	}
}

+(void) willMoveFromParentWithNode:(SKNode*)node
{
	if ([node respondsToSelector:@selector(isKoboldKitNode)])
	{
		[(id<KKNodeProtocol>)node willMoveFromParent];
		[KKNodeShared pauseSchedulerForNode:node paused:YES];
	}
}

+(void) sendChildrenWillMoveFromParentWithNode:(SKNode*)node
{
	if ([node respondsToSelector:@selector(isKoboldKitNode)])
	{
		CCScheduler* scheduler = node.kkScene.kkView.scheduler;
		
		for (SKNode* child in node.children)
		{
			if ([child respondsToSelector:@selector(isKoboldKitNode)])
			{
				[(id<KKNodeProtocol>)child willMoveFromParent];
				[scheduler setPaused:YES target:(id<CCSchedulerTarget>)child];
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

+(void) forgotToCallToSuperMethodWithName:(NSString*)methodName node:(SKNode*)node
{
	[NSException raise:NSInternalInconsistencyException format:@"Class %@ implements %@ but does not call [super %@]", NSStringFromClass([node class]), methodName, methodName];
}

@end
