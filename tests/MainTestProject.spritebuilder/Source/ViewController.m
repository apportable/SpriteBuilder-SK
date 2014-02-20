//
//  ViewController.m
//  SPRITEKITPROJECTNAME
//
//  Created by Steffen Itterheim on 24/01/14.
//

#import "ViewController.h"
#import "MainScene.h"
#import "SB+KoboldKit.h"

@implementation ViewController

-(void) presentFirstScene
{
	KKView* kkView = self.kkView;
	kkView.showsFPS = YES;
	kkView.showsNodeCount = YES;
	kkView.showsDrawCount = YES;
	kkView.showsCPUStats = YES;
	kkView.showsGPUStats = YES;
	
	[CCBReader setSceneSize:kkView.bounds.size];
	KKScene* scene = [CCBReader loadAsScene:@"MainScene.ccbi"];

	[scene logSceneGraph:KKSceneGraphDumpAll];
	
	[kkView presentScene:scene];
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
