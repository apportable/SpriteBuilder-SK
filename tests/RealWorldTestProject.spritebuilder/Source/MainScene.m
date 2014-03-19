//
//  MyScene.m
//  SPRITEKITPROJECTNAME
//
//  Created by Steffen Itterheim on 24/01/14.
//

#import "MainScene.h"

@interface SKNode (didLoadFromCCB_Hook)
@end
@implementation SKNode (didLoadFromCCB_Hook)
// instead of subclassing SKNode a category will do to hook into CCB loading notifications for a node,
// however you need to manually filter the desired node(s) based on one or more of their properties (usually name).
-(void) didLoadFromCCB
{
	NSLog(@"didLoad: %@", self);
	if ([self.name isEqualToString:@"creditsNode"])
	{
		// center the node, this has to be done in didLoadFromCCB because currently there's no runtime support for positionType and other "types"
		self.positionType = CCPositionTypeMake(CCPositionUnitNormalized, CCPositionUnitNormalized, CCPositionReferenceCornerBottomLeft);
		self.position = CGPointMake(0.5, 0.5);
	}
}
@end

@implementation MainScene

-(void) playGameButton:(id)sender
{
	SKScene* scene = [CCBReader loadAsScene:@"FappulousScene.ccbi"];
	[self.scene.view presentScene:scene];
}

-(void) showCreditsButton:(id)sender
{
	NSLog(@"sneder: %@", sender);
	
	SBButtonNode* buttonNode = (SBButtonNode*)sender;
	if (buttonNode.state & SBControlStateSelected)
	{
		[self addChild:[[CCBReader reader] load:@"Credits"]];
		buttonNode.label.text = @"Hide Amazing Credits :(";
	}
	else
	{
		[[self childNodeWithName:@"creditsNode"] removeFromParent];
		buttonNode.label.text = @"Show Boring Credits";
	}
}

@end
