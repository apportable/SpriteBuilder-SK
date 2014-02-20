//
//  KKNodeProtocol.h
//  SB+KoboldKit
//
//  Created by Steffen Itterheim on 12/02/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCBCocosTypes.h"

@class CCScheduler;
@class CCTimer;

// declared here again to avoid compile issues
typedef double CCTime;
typedef void (^CCTimerBlock)(CCTimer* timer);

/** Implemented by all Kobold Kit node classes. Informally implements CCSchedulerTarget protocol. */
@protocol KKNodeProtocol <NSObject>

@required

/** Called after addChild / insertChild. The self.scene and self.parent properties are valid in this method. Equivalent to onEnter method in cocos2d.
 @WARNING: you must call [super didMoveToParent] from your implementation! */
-(void) didMoveToParent;
/** Called after removeFromParent and other remove child methods. The self.scene and self.parent properties are still valid. Equivalent to onExit method in cocos2d.
 @WARNING: you must call [super willMoveFromParent] from your implementation! */
-(void) willMoveFromParent;

/** Sent to a scene's nodes when the scene is about to be detached from the view.
 @WARNING: you must call [super scene:willMoveFromView:] from your implementation!
 @param view The KKView the scene will be removed from. */
-(void) scene:(KKScene*)scene willMoveFromView:(KKView*)view;
/** Sent to a scene's nodes when the scene was attached to a view.
 @WARNING: you must call [super scene:didMoveToView:] from your implementation!
 @param view The KKView the scene was attached to. */
-(void) scene:(KKScene*)scene didMoveToView:(KKView*)view;
/** Sent to a scene's nodes when the scene size changed.
 @WARNING: you must call [super scene:didChangeSize:previousSize:] from your implementation!
 @param newSize The scene's new size.
 @param previousSize The scene's previous size. */
-(void) scene:(KKScene*)scene didChangeSize:(CGSize)newSize previousSize:(CGSize)previousSize;

/** Schedules a custom selector with an interval time (in seconds). If the selector is already scheduled only the interval will be updated.
 @param selector The @selector that will run on a schedule.
 @param seconds How often (in seconds) the selector will run. If interval is 0 the selector will run every frame, 
 but you should consider implementing frameUpdate: or fixedUpdate: for "every-frame" updates.
 @returns A CCTimer object that allows you to customize the scheduled selector or inspect its status. */
-(CCTimer*) schedule:(SEL)selector interval:(CCTime)seconds;

/** Schedules a custom selector with an interval time (in seconds). If the selector is already scheduled only the interval will be updated.
 Allows you to limit the number of times the selector should repeatedly run and an initial delay that may be different from the interval.
 For example: "wait (delay) for 10 seconds, then run selector every 2 seconds (interval) and stop after 5 times (repeatCount)".
 
 @param selector The @selector that will run on a schedule.
 @param seconds How often (in seconds) the selector will run. If interval is 0 the selector will run every frame,
 but you should consider implementing frameUpdate: or fixedUpdate: for "every-frame" updates.
 @param repeatCount How many times the selector should run. When the selector has run 'repeatCount' times the selector will be automatically unscheduled.
 @param delay The delay before the selector runs for the first time after scheduling.
 @returns A CCTimer object that allows you to customize the scheduled selector or inspect its status. */
-(CCTimer*) schedule:(SEL)selector interval:(CCTime)seconds repeat:(NSUInteger)repeatCount delay:(CCTime)delay;

/** Schedules a block to run once, after a given time (delay). If the block is already scheduled the delay will be updated.
 
 @param block The block that will run once.
 @param delay The delay after which the block runs once. A delay of 0 means the block will run in the next update cycle,
 which may be the current or (more likely) the next frame, depending on where and when you schedule the block.
 @returns A CCTimer object that allows you to customize the scheduled block or inspect its status. */
-(CCTimer*) scheduleBlock:(CCTimerBlock)block delay:(CCTime)delay;

/** Schedules a selector to run once, after a given time (delay). If the selector is already scheduled the delay will be updated.
 
 @param selector The selector that will run once.
 @param delay The delay after which the selector runs once. A delay of 0 means the selector will run in the next update cycle,
 which may be the current or (more likely) the next frame, depending on where and when you schedule the selector.
 @returns A CCTimer object that allows you to customize the scheduled selector or inspect its status. */
-(CCTimer*) scheduleOnce:(SEL)selector delay:(CCTime)delay;

/** Unschedules a selector. Does nothing if the selector isn't currently scheduled.
 @param selector The selector to unschedule. */
-(void) unschedule:(SEL)selector;

/** Unschedules all scheduled selectors and blocks of a node. Does nothing if no selectors/blocks are scheduled. */
-(void) unscheduleAllSelectors;

/** @returns The view's scheduler object. */
@property (nonatomic, readonly, weak) CCScheduler* scheduler;

/** Scheduler targets are sorted by priority, lower priority targets are called first. For example priority -1 selectors run before priority 0 selectors.
 You should not change the priority (and specifically don't change it at runtime) unless you understand what you're doing and you've exhausted all other
 options to prioritize scheduled updates. The priority is mainly used to ensure that engine code runs in a specific order, so you should refrain from
 using priority values that are exactly or close to NSIntegerMin and NSIntegerMax to ensure engine classes can still reliably prioritize their work.
 
 To change this value you are required to implement the priority getter in your node subclass and return a constant, non-zero value, for example:
 
 -(void) priority { return -5; }
 
 @returns The node's priority used by the scheduler. Defaults to 0. */
@property (nonatomic, readonly) NSInteger priority;

/** @returns The node's contentSize is usually the same as size but may have a different meaning depending on contentSizeType. */
@property (nonatomic) CGSize contentSize;
/** @returns The node's contentSizeType determines how contentSize is interpreted. */
@property (nonatomic) CCSizeType contentSizeType;

/** @returns The node's anchorPoint. Will return 0,0 for SK nodes that don't originally implement the anchorPoint property. */
@property (nonatomic) CGPoint anchorPoint;

/// redefinition of regular SKNode properties/methods
@property (nonatomic, readonly) SKNode* parent;
@property (nonatomic, readonly) CGRect frame;

@optional

/** Framerate-dependent update method. Runs before a frame is renderered. Automatically called when implemented.
 @param delta The delta time since the previous call to update. Will vary depending on framerate. */
-(void) frameUpdate:(CCTime)delta;
/** Framerate-independent update method that runs at a fixed interval. The fixedUpdate: method may run multiple times per frame,
 in particular when the framerate drops below 60 fps. Automatically called when implemented.
 @param delta The delta time since the previous run of fixedUpdate. Delta will vary little compared to the frameUpdate: method which is framerate-dependent. */
-(void) fixedUpdate:(CCTime)delta;

/** Runs when the scene received the didEvaluateActions method. Automatically called when implemented. */
-(void) didEvaluateActions;
/** Runs when the scene received the didSimulatePhysics method. Automatically called when implemented. */
-(void) didSimulatePhysiscs;

@end
