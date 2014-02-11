/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import <SpriteKit/SpriteKit.h>
#import "KKNodeShared.h"

@interface KKEmitterNode : SKEmitterNode <KKNodeProtocol>

/** Scheduler targets are sorted by priority, lower priority targets are called first.
 @returns The node's priority used by the scheduler. */
@property (nonatomic, readonly) NSInteger priority;


+(id) emitterWithFile:(NSString*)file;

@end
