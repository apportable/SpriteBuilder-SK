/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import <SpriteKit/SpriteKit.h>
#import "KKNodeShared.h"
#import "CCBCocosTypes.h"

@class CCColor;

@interface KKSpriteNode : SKSpriteNode <KKNodeProtocol>
KKNODE_SHARED_HEADER

@property (nonatomic) CCColor* startColor;
@property (nonatomic) CCColor* endColor;

@end
