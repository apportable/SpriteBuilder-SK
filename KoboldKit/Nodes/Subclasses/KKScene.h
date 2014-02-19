/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import <SpriteKit/SpriteKit.h>
#import "KKPhysicsContactEventDelegate.h"
#import "KKNodeShared.h"
#import "CCBCocosTypes.h"

@class KKView;
@class CCScheduler;

/** Scene Graph dump options. */
typedef enum
{
	KKSceneGraphDumpAll = 0,
} KKSceneGraphDumpOptions;

// internal use
typedef enum
{
	KKMainLoopStageInit = 0,
	KKMainLoopStageDidUpdate,
	KKMainLoopStageDidEvaluateActions,
	KKMainLoopStageDidSimulatePhysics,
} KKMainLoopStage;

/** KKScene is the scene class used in Kobold Kit projects. KKScene updates the controllers and behaviors, receives and
 dispatches events (input, physics). */
@interface KKScene : SKScene <SKPhysicsContactDelegate>
{
	@private
	NSMutableArray* _inputObservers;
	NSMutableArray* _physicsContactObservers;
	
	NSTimeInterval _lastUpdateTime;
	
	__weak KKView* _kkView;
	
	// used to detect missing super calls
	KKMainLoopStage _mainLoopStage;
}

KKNODE_SHARED_HEADER

/** @returns The number of frames rendered since the start of the app. Useful if you need to lock your game's update cycle to the framerate.
 For example by comparing against frameCount this allows you to perform certain actions n frames from now, instead of n seconds. */
@property (nonatomic, readonly) NSUInteger frameCount;

/** @returns The view cast to a KKView object. */
@property (nonatomic, weak, readonly) KKView* kkView;

/** Returns the scene graph as a string.
 @param options Determines what will be included in the dump.
 @returns A string containing the textual dump of the scene graph. */
-(NSString*) stringFromSceneGraph:(KKSceneGraphDumpOptions)options;
/** Logs the scene graph to the debug console. Uses NSLog.
 @param options Determines what will be included in the dump. */
-(void) logSceneGraph:(KKSceneGraphDumpOptions)options;

@end
