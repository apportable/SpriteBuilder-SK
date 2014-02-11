/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import <SpriteKit/SpriteKit.h>
#import "KKView.h"

@class CCScheduler;

/** Since Kobold Kit can't modify SKNode certain functionality must be implemented in each KK*Node subclass.
 To avoid copy/pasting the code all over the place, this class acts like a common parent class, like a multiple inheritance stand-in.
 
 Functionality that would normally be handled by a method in SKNode (say a custom dealloc) must be implemented by each KK*Node
 subclass and the actual functionality is in a class method in this class. */
@interface KKNodeShared : NSObject
+(void) deallocWithNode:(SKNode*)node;
+(void) sendChildrenWillMoveFromParentWithNode:(SKNode*)node;
+(void) didMoveToParentWithNode:(SKNode*)node;
+(void) willMoveFromParentWithNode:(SKNode*)node;

+(void) scheduleNode:(SKNode*)node;
+(void) unscheduleNode:(SKNode*)node;

+(void) addNodeFrameShapeToNode:(SKNode*)node;
+(void) addNodeAnchorPointShapeToNode:(SKNode*)node;
@end

// declared here again to avoid compile issues
typedef double CCTime;

// prevent compiler from complaining that this selector is undeclared
@protocol KKKoboldKitNode_UndeclaredSelector <NSObject>
-(BOOL) isKoboldKitNode;
@end

/** Implemented by all Kobold Kit node classes. */
@protocol KKNodeProtocol <NSObject>

/** Called after addChild / insertChild. The self.scene and self.parent properties are valid in this method. Equivalent to onEnter method in cocos2d.
 @WARNING: you must call [super didMoveToParent] in your own implementation! */
-(void) didMoveToParent;
/** Called after removeFromParent and other remove child methods. The self.scene and self.parent properties are still valid. Equivalent to onExit method in cocos2d.
 @WARNING: you must call [super didMoveToParent] in your own implementation! */
-(void) willMoveFromParent;

/** Sent to a scene's nodes when the scene is about to be detached from the view.
 @WARNING: you must call [super didMoveToParent] in your own implementation!
 @param view The KKView the scene will be removed from. */
-(void) sceneWillMoveFromView:(KKView*)view;
/** Sent to a scene's nodes when the scene was attached to a view.
 @WARNING: you must call [super didMoveToParent] in your own implementation!
 @param view The KKView the scene was attached to. */
-(void) sceneDidMoveToView:(KKView*)view;
/** Sent to a scene's nodes when the scene size changed.
 @WARNING: you must call [super didMoveToParent] in your own implementation!
 @param newSize The scene's new size.
 @param previousSize The scene's previous size. */
-(void) sceneDidChangeSize:(CGSize)newSize previousSize:(CGSize)previousSize;

@optional

/** Update method with delta time, automatically called when implemented.
 @param delta The delta time since the previous call to update. */
-(void) deltaUpdate:(CCTime)delta;
/** Update method with delta time that runs at a fixed interval, automatically called when implemented.
 @param delta The delta time since the previous call to update. Delta will vary less compared to the deltaUpdate: method. */
-(void) fixedUpdate:(CCTime)delta;

@end

//#define KKNODE_SHARED_HEADER \


#define KKNODE_SHARED_CODE \
{ \
	CCScheduler* _scheduler; \
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
-(void) didMoveToParent /* to be overridden by subclasses */ \
{ \
	if ([KKView drawsNodeFrames]) \
		[KKNodeShared addNodeFrameShapeToNode:self]; \
	if ([KKView drawsNodeAnchorPoints]) \
		[KKNodeShared addNodeAnchorPointShapeToNode:self]; \
} \
\
-(void) willMoveFromParent { /* to be overridden by subclasses */ } \
\
-(void) sceneWillMoveFromView:(KKView *)view \
{ \
	[KKNodeShared unscheduleNode:self]; \
} \
\
-(void) sceneDidMoveToView:(KKView *)view \
{ \
	[KKNodeShared scheduleNode:self]; \
} \
\
-(void) sceneDidChangeSize:(CGSize)newSize previousSize:(CGSize)previousSize { } \
\
/*
-(void) deltaUpdate:(CCTime)delta { NSLog(@"deltaUpdate %@: %f", NSStringFromClass([self class]), delta); } \
-(void) fixedUpdate:(CCTime)delta { NSLog(@"fixedUpdate %@: %f", NSStringFromClass([self class]), delta); } \
*/