//
//  ViewController.m
//  SPRITEKITPROJECTNAME
//
//  Created by Steffen Itterheim on 24/01/14.
//

#import "ViewController.h"
#import "MainScene.h"

@implementation ViewController

-(void) viewWillLayoutSubviews
{
	SKView* skView = (SKView*)self.view;
	NSAssert1([skView isKindOfClass:[SKView class]], @"ViewController's view is not a SKView instance, its class is: %@", NSStringFromClass([skView class]));

	if (skView.scene == nil)
	{
		skView.showsFPS = YES;
		skView.showsNodeCount = YES;
		skView.showsDrawCount = YES;
		
		[CCBReader setSceneSize:skView.bounds.size];
		SKScene* scene = [CCBReader loadAsScene:@"MainScene.ccbi"];
		//scene.scaleMode = SKSceneScaleModeAspectFit;
		[skView presentScene:scene];
		
		[self addTestNodesToScene:scene];
	}
}

-(void) addTestNodesToScene:(SKScene*)scene
{
	SKLabelNode* label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
	label.text = @"_";
	label.fontSize = 24.0;
	label.fontColor = [SKColor magentaColor];
	label.alpha = 0.16;
	label.verticalAlignmentMode = SKLabelVerticalAlignmentModeBottom;
	[scene addChild:label];
	
	UIFont* font = [UIFont fontWithName:label.fontName size:label.fontSize];
	NSLog(@"FONT: %@ asc: %f desc: %f - heights: cap: %f x: %f", font, font.ascender, font.descender, font.capHeight, font.xHeight);
	
	/*
	SKSpriteNode* color = [SKSpriteNode spriteNodeWithColor:[SKColor redColor] size:CGSizeMake(200, 100)];
	color.position = CGPointMake(105, 51);
	[scene addChild:color];
	
	SKSpriteNode* sprite = [SKSpriteNode spriteNodeWithImageNamed:@"ccbParticleSmoke.png"];
	[color addChild:sprite];
	*/
}

-(BOOL) shouldAutorotate
{
    return YES;
}

-(NSUInteger) supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
	{
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
	else
	{
        return UIInterfaceOrientationMaskAll;
    }
}

-(void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
