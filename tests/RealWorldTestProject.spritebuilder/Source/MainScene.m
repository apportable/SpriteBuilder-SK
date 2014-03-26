//
//  MyScene.m
//  SPRITEKITPROJECTNAME
//
//  Created by Steffen Itterheim on 24/01/14.
//

#import "MainScene.h"

@implementation MainScene

-(void) readerDidLoadSelf
{
	NSLog(@"readerDidLoadSelf: %p - %@ (%@)", self, self.name, NSStringFromClass([self class]));
}

-(void) readerDidLoadChildNode:(SKNode*)node
{
	NSLog(@"readerDidLoadChildNode: %p - %@ (%@)", node, node.name, NSStringFromClass([node class]));
}

-(void) changeLabelText:(id)sender
{
	NSLog(@"sender: %@", sender);
	SBButtonNode* buttonNode = (SBButtonNode*)sender;
	buttonNode.label.text = [NSString stringWithFormat:@"%d", arc4random_uniform(INT_MAX)];
}

-(void) playGameButton:(id)sender
{
	NSLog(@"sender: %@", sender);
	SKScene* scene = [CCBReader loadAsScene:@"FappulousScene"];
	[self.scene.view presentScene:scene transition:[SKTransition doorsOpenHorizontalWithDuration:1.0]];
}

-(void) showCreditsButton:(id)sender
{
	NSLog(@"sender: %@", sender);
	
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
	//NSLog(@"update: %f", currentTime);
}

@end
