//
//  ViewController.m
//  SPRITEKITPROJECTNAME
//
//  Created by Steffen Itterheim on 24/01/14.
//

#import "ViewController.h"
#import "SB+SpriteKit.h"
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
		[skView setValue:@(YES) forKey:@"_showsCulledNodesInNodeCount"];
		//[skView setValue:@(YES) forKey:@"_showsGPUStats"];
		//[skView setValue:@(YES) forKey:@"_showsCPUStats"];
		
		SKScene* scene = [CCBReader loadAsScene:@"MainScene" size:skView.bounds.size];
		//scene.anchorPoint = CGPointMake(0.5, 0.5);
		[skView presentScene:scene];
	}
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
