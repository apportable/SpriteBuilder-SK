/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import "SKNode+KoboldKit.h"
#import "KKScene.h"
#import "KKNode.h"
#import "KKMacros.h"
#import "KKView.h"

@implementation SKNode (KoboldKit)

#pragma mark Properties

@dynamic kkScene;
-(KKScene*) kkScene
{
	NSAssert(self.scene, @"self.scene property is (still) nil. The scene property is only valid after the node has been added as child to another node.");
	NSAssert1([self.scene isKindOfClass:[KKScene class]], @"scene (%@) is not a KKScene object", self.scene);
	return (KKScene*)self.scene;
}

#pragma mark Position

-(void) centerOnNode:(SKNode*)node
{
    CGPoint cameraPositionInScene = [node.scene convertPoint:node.position fromNode:node.parent];
    node.parent.position = CGPointMake(node.parent.position.x - cameraPositionInScene.x,
                                       node.parent.position.y - cameraPositionInScene.y);
}

#pragma mark Physics

-(void) addPhysicsBodyDrawNodeWithPath:(CGPathRef)path
{
	SKShapeNode* shape = [SKShapeNode node];
	shape.path = path;
	shape.antialiased = NO;
	if (self.physicsBody.dynamic)
	{
		shape.lineWidth = 1.0;
		shape.fillColor = [SKColor colorWithRed:1 green:0 blue:0.2 alpha:0.2];
	}
	else
	{
		shape.lineWidth = 2.0;
		shape.glowWidth = 4.0;
		shape.strokeColor = [SKColor magentaColor];
	}
	[self addChild:shape];
}

-(SKPhysicsBody*) physicsBodyWithEdgeLoopFromPath:(CGPathRef)path
{
	SKPhysicsBody* physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromPath:path];
	physicsBody.dynamic = NO;
	self.physicsBody = physicsBody;
	if ([KKView drawsPhysicsShapes])
	{
		[self addPhysicsBodyDrawNodeWithPath:path];
	}
	return physicsBody;
}

-(SKPhysicsBody*) physicsBodyWithEdgeChainFromPath:(CGPathRef)path
{
	SKPhysicsBody* physicsBody = [SKPhysicsBody bodyWithEdgeChainFromPath:path];
	physicsBody.dynamic = NO;
	self.physicsBody = physicsBody;
	if ([KKView drawsPhysicsShapes])
	{
		[self addPhysicsBodyDrawNodeWithPath:path];
	}
	return physicsBody;
}

-(SKPhysicsBody*) physicsBodyWithRectangleOfSize:(CGSize)size
{
	SKPhysicsBody* physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:size];
	self.physicsBody = physicsBody;
	if ([KKView drawsPhysicsShapes])
	{
		CGPathRef path = CGPathCreateWithRect(CGRectMake(-(size.width * 0.5), -(size.height * 0.5), size.width, size.height), nil);
		[self addPhysicsBodyDrawNodeWithPath:path];
		CGPathRelease(path);
	}
	return physicsBody;
}

-(SKPhysicsBody*) physicsBodyWithCircleOfRadius:(CGFloat)radius
{
	SKPhysicsBody* physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:radius];
	self.physicsBody = physicsBody;
	if ([KKView drawsPhysicsShapes])
	{
		CGPathRef path = CGPathCreateWithEllipseInRect(self.frame, nil);
		[self addPhysicsBodyDrawNodeWithPath:path];
		CGPathRelease(path);
	}
	return physicsBody;
}

@end


#pragma mark SK*Node Categories

@implementation SKSpriteNode (KoboldKit)
@end
@implementation SKCropNode (KoboldKit)
@end
@implementation SKEffectNode (KoboldKit)
@end
@implementation SKEmitterNode (KoboldKit)
@end
@implementation SKLabelNode (KoboldKit)
@end
@implementation SKShapeNode (KoboldKit)
@end
@implementation SKVideoNode (KoboldKit)
@end
