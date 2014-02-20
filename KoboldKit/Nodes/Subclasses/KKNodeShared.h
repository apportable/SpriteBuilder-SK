/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import <SpriteKit/SpriteKit.h>
#import "KKView.h"
#import "KKNodeProtocol.h"
#import "SKNode+KoboldKit.h"
#import "SKAction+CCBReader.h"

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

+(void) setSizeFromContentSizeForNode:(id<KKNodeProtocol>)node;

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
@property (nonatomic) CGPoint anchorPoint; \
@property (nonatomic) CGSize contentSize; \
@property (nonatomic) CCPositionType positionType; \
@property (nonatomic) CCScaleType scaleType; \
@property (nonatomic) CCSizeType contentSizeType; \

#define KKNODE_SHARED_CODE \
{ \
	__weak CCScheduler* _scheduler; \
	CGSize _contentSize; \
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
-(void) setPaused:(BOOL)paused /* IMPORTANT: subclasses must call the super method when overriding this method! */ \
{ \
	if (self.paused != paused) \
	{ \
		[super setPaused:paused]; \
		[KKNodeShared pauseSchedulerForNode:self paused:paused]; \
	} \
} \
\
-(void) didMoveToParent /* IMPORTANT: subclasses must call the super method when overriding this method! */ \
{ \
	[KKNodeShared setSizeFromContentSizeForNode:self]; \
	[KKNodeShared scheduleNode:self]; \
} \
-(void) willMoveFromParent { [KKNodeShared pauseSchedulerForNode:self paused:YES]; } /* IMPORTANT: subclasses must call the super method when overriding this method! */ \
-(void) scene:(KKScene*)scene didChangeSize:(CGSize)newSize previousSize:(CGSize)previousSize { } /* IMPORTANT: subclasses must call the super method when overriding this method! */ \
-(void) scene:(KKScene*)scene didMoveToView:(KKView *)view /* IMPORTANT: subclasses must call the super method when overriding this method! */ \
{ \
	[KKNodeShared setSizeFromContentSizeForNode:self]; \
} \
-(void) scene:(KKScene*)scene willMoveFromView:(KKView *)view { } /* IMPORTANT: subclasses must call the super method when overriding this method! */ \
\
\
-(CCTimer*) schedule:(SEL)selector interval:(CCTime)seconds \
{ \
	return [self schedule:selector interval:seconds repeat:NSUIntegerMax delay:0]; \
} \
-(CCTimer*) scheduleOnce:(SEL)selector delay:(CCTime)delay \
{ \
	return [self schedule:selector interval:INFINITY repeat:0 delay:delay]; \
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
\
-(void) setContentSize:(CGSize)size \
{ \
	_contentSize = size; \
	[KKNodeShared setSizeFromContentSizeForNode:self]; \
} \
-(CGSize) contentSize \
{ \
	if (CGSizeEqualToSize(_contentSize, CGSizeZero)) \
		return self.frame.size; \
	return _contentSize; \
} \
\
-(void) setContentSizeType:(CCSizeType)type \
{ \
	_contentSizeType = type; \
	[KKNodeShared setSizeFromContentSizeForNode:self]; \
} \
\
/*
-(void) frameUpdate:(CCTime)delta { NSLog(@"frameUpdate %@: %f", NSStringFromClass([self class]), delta); } \
-(void) fixedUpdate:(CCTime)delta { NSLog(@"fixedUpdate %@: %f", NSStringFromClass([self class]), delta); } \
*/

#define KKNODE_SHARED_ADD_ANCHORPOINT \
@dynamic anchorPoint; \
-(void) setAnchorPoint:(CGPoint)anchorPoint \
{ \
} \
-(CGPoint) anchorPoint \
{ \
	return CGPointZero; \
} \

#define KKNODE_SHARED_OVERRIDE_ANCHORPOINT \
@dynamic anchorPoint; \
-(void) setAnchorPoint:(CGPoint)anchorPoint \
{ \
} \
-(CGPoint) anchorPoint \
{ \
	return [super anchorPoint]; \
} \
