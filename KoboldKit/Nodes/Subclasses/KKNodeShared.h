/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import <SpriteKit/SpriteKit.h>
#import "KKView.h"
#import "KKNodeProtocol.h"
#import "SKNode+KoboldKit.h"

@class CCScheduler;

/** Since Kobold Kit can't modify SKNode certain functionality must be implemented in each KK*Node subclass.
 To avoid copy/pasting the code all over the place, this class acts like a common parent class, like a multiple inheritance stand-in.
 
 Functionality that would normally be handled by a method in SKNode (say a custom dealloc) must be implemented by each KK*Node
 subclass and the actual functionality is in a class method in this class. */
@interface KKNodeShared : NSObject
+(void) deallocWithNode:(SKNode*)node;


+(CCTimer*) node:(NSObject<KKNodeProtocol>*)node schedule:(SEL)selector interval:(CCTime)interval repeat:(NSUInteger)repeat delay:(CCTime)delay;
+(void) node:(id<KKNodeProtocol>)node unschedule:(SEL)selector;
+(void) unscheduleAllSelectorsWithNode:(id<KKNodeProtocol>)node;

+(void) scheduleNode:(SKNode*)node;
+(void) pauseSchedulerForNode:(SKNode*)node paused:(BOOL)paused;

+(void) didMoveToParentWithNode:(SKNode*)node;
+(void) willMoveFromParentWithNode:(SKNode*)node;
+(void) sendChildrenWillMoveFromParentWithNode:(SKNode*)node;

+(void) addNodeFrameShapeToNode:(SKNode*)node;
+(void) addNodeAnchorPointShapeToNode:(SKNode*)node;
+(void) forgotToCallToSuperMethodWithName:(NSString*)methodName node:(SKNode*)node;
@end

// prevent compiler from complaining that this selector is undeclared
@protocol KKKoboldKitNode_UndeclaredSelector <NSObject>
-(BOOL) isKoboldKitNode;
@end


#define KKNODE_SHARED_HEADER \
@property (nonatomic, weak, readonly) CCScheduler* scheduler; \
@property (nonatomic, readonly) NSInteger priority; \

#define KKNODE_SHARED_CODE \
{ \
	__weak CCScheduler* _scheduler; \
} \
\
-(CCScheduler*) scheduler \
{ \
	if (_scheduler == nil) \
	{ \
		_scheduler = [KKView defaultView].scheduler; \
		NSAssert(_scheduler, @"[KKView defaultView].scheduler is nil!"); \
	} \
	return _scheduler; \
} \
\
-(BOOL) isKoboldKitNode \
{ \
	return YES; \
} \
\
-(void) dealloc { \
	[KKNodeShared deallocWithNode:self]; \
} \
\
-(void) addChild:(SKNode*)node { \
	[super addChild:node]; \
	[KKNodeShared didMoveToParentWithNode:node]; \
} \
\
-(void) insertChild:(SKNode*)node atIndex:(NSInteger)index { \
	[super insertChild:node atIndex:index]; \
	[KKNodeShared didMoveToParentWithNode:node]; \
} \
\
-(void) removeFromParent { \
	[KKNodeShared willMoveFromParentWithNode:self]; \
	[super removeFromParent]; \
} \
\
-(void) removeAllChildren { \
	[KKNodeShared sendChildrenWillMoveFromParentWithNode:self]; \
	[super removeAllChildren]; \
} \
\
-(void) removeChildrenInArray:(NSArray*)array { \
	[KKNodeShared sendChildrenWillMoveFromParentWithNode:self]; \
	[super removeChildrenInArray:array]; \
} \
\
-(void) setPaused:(BOOL)paused \
{ \
	if (self.paused != paused) \
	{ \
		[super setPaused:paused]; \
		[KKNodeShared pauseSchedulerForNode:self paused:paused]; \
	} \
} \
\
-(void) didMoveToParent { [KKNodeShared scheduleNode:self]; } /* to be overridden by subclasses */ \
-(void) willMoveFromParent { [KKNodeShared pauseSchedulerForNode:self paused:YES]; } /* to be overridden by subclasses */ \
-(void) scene:(KKScene*)scene didChangeSize:(CGSize)newSize previousSize:(CGSize)previousSize { } /* to be overridden by subclasses */ \
-(void) scene:(KKScene*)scene didMoveToView:(KKView *)view { } /* to be overridden by subclasses */ \
-(void) scene:(KKScene*)scene willMoveFromView:(KKView *)view { } /* to be overridden by subclasses */ \
\
-(CCTimer*) schedule:(SEL)selector interval:(CCTime)seconds \
{ \
	return [self schedule:selector interval:seconds repeat:NSUIntegerMax delay:0]; \
} \
-(CCTimer*) scheduleOnce:(SEL)selector delay:(CCTime)delay \
{ \
	return [self schedule:selector interval:0.0 repeat:0 delay:delay]; \
} \
-(CCTimer*) schedule:(SEL)selector interval:(CCTime)interval repeat:(NSUInteger)repeat delay:(CCTime)delay \
{ \
	return [KKNodeShared node:(NSObject<KKNodeProtocol>*)self schedule:selector interval:interval repeat:repeat delay:delay]; \
} \
-(CCTimer*) scheduleBlock:(CCTimerBlock)block delay:(CCTime)delay \
{ \
	return [_scheduler scheduleBlock:block forTarget:(id<CCSchedulerTarget>)self withDelay:delay]; \
} \
-(void) unschedule:(SEL)selector \
{ \
	[KKNodeShared node:(id<KKNodeProtocol>)self unschedule:selector]; \
} \
-(void) unscheduleAllSelectors \
{ \
	[KKNodeShared unscheduleAllSelectorsWithNode:(id<KKNodeProtocol>)self]; \
} \
-(NSInteger) priority \
{ \
	return 0; \
} \
/*
-(void) frameUpdate:(CCTime)delta { NSLog(@"frameUpdate %@: %f", NSStringFromClass([self class]), delta); } \
-(void) fixedUpdate:(CCTime)delta { NSLog(@"fixedUpdate %@: %f", NSStringFromClass([self class]), delta); } \
*/