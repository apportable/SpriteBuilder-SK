/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import <SpriteKit/SpriteKit.h>
#import "KKNodeShared.h"

/** In Kobold Kit KKNode must be used in place of SKNode to ensure that KK messaging works (ie didMoveToParent, willMoveFromParent, etc). */
@interface KKNode : SKNode <KKNodeProtocol>

/** Scheduler targets are sorted by priority, lower priority targets are called first.
 @returns The node's priority used by the scheduler. */
@property (nonatomic, readonly) NSInteger priority;

@end
