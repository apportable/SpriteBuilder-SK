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
	/*
	SKSpriteNode* s = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithFile:@"ccbResources/ccbButtonNormal.png"]];
	s.position = CGPointMake(320, 60);
	s.color = [SKColor greenColor];
	s.colorBlendFactor = 1.0;
	//s.size = CGSizeMake(200, 80);
	s.xScale = 251.0 / s.texture.size.width;
	s.yScale = 24.0 / s.texture.size.height;
	s.centerRect = CGRectMake(0.33, 0.33, 0.33, 0.33);
	[scene addChild:s];
	NSLog(@"test: %@", s.debugDescription);
	*/
	
	/*
	SBButtonNode* button = [SBButtonNode buttonWithTitle:@"Hello SpriteBuilder Button!"];
	button.position = CGPointMake(100, 85);
	button.label.fontColor = [SKColor purpleColor];
	button.runBlock = ^(id sender){
		NSLog(@"button block ran ... with sender: %@", sender);
	};
	[scene addChild:button];
	*/
	
	/*
	SKLabelNode* label = [SKLabelNode labelNodeWithFontNamed:@"Courier"];
	label.text = @"XXXX";
	label.position = CGPointMake(288.353668, 338.165710);
	[scene addChild:label];
	*/
	
	/*
	SKLabelNode* label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
	label.text = @"_";
	label.fontSize = 24.0;
	label.fontColor = [SKColor magentaColor];
	label.alpha = 0.16;
	label.verticalAlignmentMode = SKLabelVerticalAlignmentModeBottom;
	[scene addChild:label];
	
	UIFont* font = [UIFont fontWithName:label.fontName size:label.fontSize];
	NSLog(@"FONT: %@ asc: %f desc: %f - heights: cap: %f x: %f", font, font.ascender, font.descender, font.capHeight, font.xHeight);
	*/
	
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
