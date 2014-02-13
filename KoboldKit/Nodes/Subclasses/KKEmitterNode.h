/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import <SpriteKit/SpriteKit.h>
#import "KKNodeShared.h"

@interface KKEmitterNode : SKEmitterNode <KKNodeProtocol>
KKNODE_SHARED_HEADER

+(id) emitterWithFile:(NSString*)file;

@end
