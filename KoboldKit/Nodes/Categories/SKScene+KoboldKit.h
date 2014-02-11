/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import <SpriteKit/SpriteKit.h>

/** SKScene category methods for Kobold Kit */
@interface SKScene (KoboldKit)

/** Enumerates all physics bodies in the world by passing an INFINITY rect to enumerateBodiesInRect.
 @param block The block that is called for every physics body. */
-(void) enumerateBodiesUsingBlock:(void (^)(SKPhysicsBody *body, BOOL *stop))block;


@end
