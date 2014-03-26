//
//  CreditsNode.m
//  RealWorldTestProject
//
//  Created by Steffen Itterheim on 26/03/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CreditsNode.h"

@implementation CreditsNode

-(void) readerDidLoadSelf
{
	NSLog(@"readerDidLoadSelf: %p - %@", self, self);
	// center the node, this has to be done in readerDidLoadNode (or in the subclass' didLoadFromCCB) because
	// currently there's no runtime support for positionType and other "types"
	self.positionType = CCPositionTypeMake(CCPositionUnitNormalized, CCPositionUnitNormalized, CCPositionReferenceCornerBottomLeft);
	self.position = CGPointMake(0.5, 0.5);
}

-(void) readerDidLoadChildNode:(SKNode*)node
{
	NSLog(@"readerDidLoadChildNode: %p - %@ (%@)", node, node.name, NSStringFromClass([node class]));
}

@end
