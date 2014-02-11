/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import "KKFramework.h"

@class KKScene;

/** Kobold Kit extensions to SKNode. Adds access to controller, model and behaviors. */
@interface SKNode (KoboldKit)

/** @name Changing the Node's Position */

/** Changes the receiver's position so that it is centered on the given node.
 @param node The node to center on. */
-(void) centerOnNode:(SKNode*)node;

/** @name Accessing the KKScene */

/** Returns the node's scene object, cast to KKScene. Use this instead of scene to use KKScene's methods and properties. */
@property (atomic, readonly) KKScene* kkScene;

/** @name Creating physics bodies */

/** Creates a physics Body with edge loop shape. Also assigns the physics body to the node's self.physicsBody property.
 @param path The CGPath with edge points.
 @returns The newly created SKPhysicsBody. */
-(SKPhysicsBody*) physicsBodyWithEdgeLoopFromPath:(CGPathRef)path;
/** Creates a physics Body with edge chain shape. Also assigns the physics body to the node's self.physicsBody property.
 @param path The CGPath with chain points.
 @returns The newly created SKPhysicsBody. */
-(SKPhysicsBody*) physicsBodyWithEdgeChainFromPath:(CGPathRef)path;
/** Creates a physics Body with rectangle shape. Also assigns the physics body to the node's self.physicsBody property.
 @param size The size of the rectangle.
 @returns The newly created SKPhysicsBody. */
-(SKPhysicsBody*) physicsBodyWithRectangleOfSize:(CGSize)size;
/** Creates a physics Body with circle shape. Also assigns the physics body to the node's self.physicsBody property.
 @param radius The circle radius.
 @returns The newly created SKPhysicsBody. */
-(SKPhysicsBody*) physicsBodyWithCircleOfRadius:(CGFloat)radius;

@end

#pragma mark SK*Node Categories

@interface SKSpriteNode (KoboldKit)
@end
@interface SKCropNode (KoboldKit)
@end
@interface SKEffectNode (KoboldKit)
@end
@interface SKEmitterNode (KoboldKit)
@end
@interface SKLabelNode (KoboldKit)
@end
@interface SKShapeNode (KoboldKit)
@end
@interface SKVideoNode (KoboldKit)
@end
