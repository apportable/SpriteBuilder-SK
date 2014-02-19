/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import "KKFramework.h"

@class KKScene;
@class KKModel;
@class CCScheduler;

/** Kobold Kit apps use KKView as their view. It provides additional features like the ability to push & pop scenes. */
@interface KKView : SKView
{
	@private
	NSMutableArray* _sceneStack;
}

/** Accessing the View */

/** The default view is the most recently created KKView instance. Usually this will be the Sprite Kit view used by your app, 
 unless you happen to be managing multiple views in your OS X app (multiple Sprite Kit views at the same time is functional only on OS X).
 @returns The default Kobold Kit view. */
+(instancetype) defaultView;

/** @name Scheduling */

/** @returns The scheduler that handles repeating callback blocks/selectors for the view's scene and its nodes (and other objects). */
@property (nonatomic, readonly) CCScheduler* scheduler;

/** @name Presenting Scenes */

/** The scenes currently suspended in the background.
 
 After the first call to presentScene it will always contains at least the scene that's currently presented. 
 If sceneStack.count returns 1 then there are currently no scenes in the background.
 @returns An array with 1 or more scenes currently suspended. The presented scene is always the lastObject. */
@property (atomic, readonly) NSArray* sceneStack;

/** @name View Properties */

/** The design size as set by Spritebuilder. */
@property CGSize designSize;

/** If YES, will render physics shape outlines. */
@property (nonatomic) BOOL drawsPhysicsShapes;
/** If YES, will render node outlines according to their frame property. */
@property (nonatomic) BOOL drawsNodeFrames;
/** If YES, will render a dot on the node's position. */
@property (nonatomic) BOOL drawsNodeAnchorPoints;
/** If YES, will render CPU stats. */
@property (nonatomic) BOOL showsCPUStats;
/** If YES, will render GPU stats. */
@property (nonatomic) BOOL showsGPUStats;
/** Toggles various shows*** flags on/off. If YES, will show all stats. */
@property (nonatomic) BOOL showsAllStats;

// internal use
+(BOOL) drawsPhysicsShapes;
+(BOOL) drawsNodeFrames;
+(BOOL) drawsNodeAnchorPoints;

/** Presents a scene. 
 
 Replaces the topmost scene on the scene stack.
 @param scene The scene to present. */
-(void) presentScene:(SKScene *)scene;

/** Presents a scene.
 
 Replaces the topmost scene on the scene stack.
 @param scene The scene to present.
 @param transition A transition used to animate between the two scenes. */
-(void) presentScene:(SKScene *)scene transition:(SKTransition *)transition;

/** Presents a scene.
 
 If unwindSceneStack is YES, all scenes will be removed from the scene stack before presenting the new scene. 
 Useful only in cooperation with pushScene: methods.
 @param scene The scene to present. 
 @param unwindStack If YES removes all scenes from the stack before adding the new scene. */
-(void) presentScene:(KKScene *)scene unwindStack:(BOOL)unwindStack;

/** Presents a scene.
 
 Replaces the topmost scene on the scene stack.
 Useful only in cooperation with pushScene: methods.
 @param scene The scene to present.
 @param transition A transition used to animate between the two scenes.
 @param unwindStack If YES removes all scenes from the stack before adding the new scene. */
-(void) presentScene:(KKScene *)scene transition:(KKTransition *)transition unwindStack:(BOOL)unwindStack;

/** Presents a scene, suspends the currently presented scene. 
 
 The currently presented scene will be suspended, stops animating but remains in memory. It can be presented again using one of the popScene methods.
 @param scene The scene to present. */
-(void) pushScene:(KKScene*)scene;

/** Presents a scene, suspends the currently presented scene.
 
 The currently presented scene will be suspended, stops animating but remains in memory. It can be presented again using one of the popScene methods.
 @param scene The scene to present.
 @param transition A transition used to animate between the two scenes. */
-(void) pushScene:(KKScene*)scene transition:(KKTransition*)transition;

/** Pops the topmost scene from the stack and presents the new topmost scene.
 
 If there is only one scene on the stack (the currently presented scene) then this method has no effect. */
-(void) popScene;

/** Pops the topmost scene from the stack and presents the new topmost scene.
 
 If there is only one scene on the stack (the currently presented scene) then this method has no effect.
 @param transition A transition used to animate between the two scenes. */
-(void) popSceneWithTransition:(KKTransition*)transition;

/** Pops all scenes from the stack except for the root scene, then presents the root scene.
 
 If there is only one scene on the stack (the currently presented scene) then this method has no effect. */
-(void) popToRootScene;

/** Pops all scenes from the stack except for the root scene, then presents the root scene.
 
 If there is only one scene on the stack (the currently presented scene) then this method has no effect.
 @param transition A transition used to animate between the two scenes. */
-(void) popToRootSceneWithTransition:(KKTransition*)transition;

/** Searches for the first scene with the given name in the scene stack and presents it.
 
 If there is no scene by this name on the scene stack, then this method has no effect.
 @param name The name of a scene on the stack to be presented. */
-(void) popToSceneNamed:(NSString*)name;

/** Searches for the first scene with the given name in the scene stack and presents it.
 
 If there is no scene by this name on the scene stack, then this method has no effect.
 @param name The name of a scene on the stack to be presented.
 @param transition A transition used to animate between the two scenes. */
-(void) popToSceneNamed:(NSString*)name transition:(KKTransition*)transition;

@end
