//
//  MyScene.m
//  SPRITEKITPROJECTNAME
//
//  Created by Steffen Itterheim on 24/01/14.
//

#import "MainScene.h"
#import "KKScene.h"
#import "KKView.h"
#import "CCScheduler.h"

@implementation MainScene

-(void) dealloc
{
	NSLog(@"dealloc: %@ scheduler: %@", self, self.scheduler);
}

-(void) didMoveToParent
{
	[super didMoveToParent];

	CCTimer* t;
	t = [self schedule:@selector(scheduledSelectorRepeat:) interval:0.111 repeat:9 delay:1];
	NSLog(@"timer: %@", t);
	t = [self schedule:@selector(scheduledSelector:) interval:3];
	NSLog(@"timer: %@", t);
	t = [self scheduleOnce:@selector(scheduledOnce:) delay:2];
	NSLog(@"timer: %@", t);
	
	t = [self scheduleBlock:^(CCTimer *timer) {
		NSLog(@"[%u] scheduledBlock: %@", (unsigned int)self.kkScene.frameCount, timer);
	} delay:2.5];
	NSLog(@"timer: %@", t);
	
	
	KKSpriteNode* sprite = [KKSpriteNode spriteNodeWithColor:[SKColor magentaColor] size:CGSizeMake(32, 32)];
	sprite.position = CGPointMake(400, 111);
	[self addChild:sprite];
	
	sprite.color = [SKColor greenColor];
	sprite.size = CGSizeMake(120, 2);
}

-(void) scheduledOnce:(CCTime)delta
{
	NSLog(@"[%u] scheduledOnce: %f", (unsigned int)self.kkScene.frameCount, delta);
}

-(void) scheduledSelector:(CCTime)delta
{
	NSLog(@"[%u] scheduledSelector: %f", (unsigned int)self.kkScene.frameCount, delta);
}

-(void) scheduledSelectorRepeat:(CCTime)delta
{
	NSLog(@"[%u] scheduledSelectorRepeat: %f", (unsigned int)self.kkScene.frameCount, delta);
}

-(void) frameUpdate:(CCTime)delta
{
	if (self.kkScene.frameCount <= 4)
	{
		NSLog(@"[%u] frameUpdate %@: %f", (unsigned int)self.kkScene.frameCount, NSStringFromClass([self class]), delta);
	}
}

-(void) fixedUpdate:(CCTime)delta
{
	if (self.kkScene.frameCount <= 4)
	{
		NSLog(@"[%u] fixedUpdate %@: %f", (unsigned int)self.kkScene.frameCount, NSStringFromClass([self class]), delta);
	}
}

-(void) didEvaluateActions
{
	if (self.kkScene.frameCount <= 4)
	{
		NSLog(@"[%u] didEvaluateActions %@", (unsigned int)self.kkScene.frameCount, NSStringFromClass([self class]));
	}
}

-(void) didSimulatePhysics
{
	if (self.kkScene.frameCount <= 4)
	{
		NSLog(@"[%u] didSimulatePhysics %@", (unsigned int)self.kkScene.frameCount, NSStringFromClass([self class]));
	}
}

@end
