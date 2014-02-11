/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import "SKScene+KoboldKit.h"
#import "SKNode+KoboldKit.h"

@implementation SKScene (KoboldKit)

-(void) enumerateBodiesUsingBlock:(void (^)(SKPhysicsBody *body, BOOL *stop))block
{
	[self.physicsWorld enumerateBodiesInRect:CGRectMake(-INFINITY, -INFINITY, INFINITY, INFINITY) usingBlock:block];
}

@end
