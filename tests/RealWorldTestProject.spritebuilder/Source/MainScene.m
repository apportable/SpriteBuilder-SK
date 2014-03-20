//
//  MyScene.m
//  SPRITEKITPROJECTNAME
//
//  Created by Steffen Itterheim on 24/01/14.
//

#import "MainScene.h"

@implementation MainScene

-(void) didLoadFromCCB
{
	NSLog(@"didLoadFromCCB: %p - %@", self, self);
}

-(void) readerDidLoadSelf
{
	NSLog(@"readerDidLoadSelf: %p - %@", self, self);
}

-(void) readerDidLoadChildNode:(SKNode*)node
{
	NSLog(@"readerDidLoadChildNode: %p - %@", node, node);

	if ([node.name isEqualToString:@"creditsNode"])
	{
		// center the node, this has to be done in readerDidLoadNode (or in the subclass' didLoadFromCCB) because
		// currently there's no runtime support for positionType and other "types"
		node.positionType = CCPositionTypeMake(CCPositionUnitNormalized, CCPositionUnitNormalized, CCPositionReferenceCornerBottomLeft);
		node.position = CGPointMake(0.5, 0.5);
	}
}

-(void) playGameButton:(id)sender
{
	SKScene* scene = [CCBReader loadAsScene:@"FappulousScene"];
	[self.scene.view presentScene:scene transition:[SKTransition doorsOpenHorizontalWithDuration:1.0]];
}

-(void) showCreditsButton:(id)sender
{
	NSLog(@"sneder: %@", sender);
	
	SBButtonNode* buttonNode = (SBButtonNode*)sender;
	if (buttonNode.state & SBControlStateSelected)
	{
		[self addChild:[CCBReader load:@"Credits"]];
		buttonNode.label.text = @"Hide Amazing Credits :(";
	}
	else
	{
		[[self childNodeWithName:@"creditsNode"] removeFromParent];
		buttonNode.label.text = @"Show Boring Credits";
	}
}

-(void) update:(NSTimeInterval)currentTime
{
	NSLog(@"update: %f", currentTime);
}

@end
