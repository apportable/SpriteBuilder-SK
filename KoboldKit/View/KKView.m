/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import "KKView.h"
#import "KKScene.h"
#import "CCScheduler.h"

static BOOL _drawsPhysicsShapes = NO;
static BOOL _drawsNodeFrames = NO;
static BOOL _drawsNodeAnchorPoints = NO;

static __weak KKView* _defaultView = nil;

@implementation KKView

+(instancetype) defaultView
{
	return _defaultView;
}

-(id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	{
		[self initDefaults];
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self)
	{
		[self initDefaults];
	}
	return self;
}

-(id) init
{
	self = [super init];
	if (self)
	{
		[self initDefaults];
	}
	return self;
}

-(void) initDefaults
{
	// this assert may be too restrictive but I want to know the exact situation if and when this ever happens (besides users trying to create "split-view" apps)
	NSAssert1(_defaultView == nil, @"An instance of KKView (%p) already exists! You can only have one Sprite Kit view at any one time on iOS.", _defaultView);
	
	[_defaultView end];
	_defaultView = self;
	
	_sceneStack = [NSMutableArray array];
	_scheduler = [[CCScheduler alloc] init];
}

-(void) end
{
	_scheduler.paused = YES;
	_scheduler = nil;
	_sceneStack = nil;
}

#pragma mark Present Scene

-(void) presentScene:(SKScene *)scene
{
	[self presentScene:scene transition:nil];
}

-(void) presentScene:(SKScene *)scene transition:(SKTransition *)transition
{
	if (_sceneStack.count > 0)
	{
		[_sceneStack removeLastObject];
	}
	[_sceneStack addObject:scene];

	[self doPresentScene:scene transition:transition];
}

-(void) presentScene:(KKScene *)scene unwindStack:(BOOL)unwindStack
{
	[self presentScene:scene transition:nil unwindStack:unwindStack];
}

-(void) presentScene:(KKScene *)scene transition:(KKTransition *)transition unwindStack:(BOOL)unwindStack
{
	if (unwindStack)
	{
		[_sceneStack removeAllObjects];
		[_sceneStack addObject:scene];
	}

	[self doPresentScene:scene transition:transition];
}

-(void) doPresentScene:(SKScene*)scene transition:(SKTransition*)transition
{
	transition ? [super presentScene:scene transition:transition] : [super presentScene:scene];
}

#pragma mark Push/Pop Scene

-(void) pushScene:(KKScene*)scene
{
	[self pushScene:scene transition:nil];
}

-(void) pushScene:(KKScene*)scene transition:(KKTransition*)transition
{
	self.scene.paused = YES;
	[_sceneStack addObject:self.scene];
	
	transition ? [super presentScene:scene transition:transition] : [super presentScene:scene];
}

-(void) popScene
{
	[self popSceneWithTransition:nil];
}

-(void) popSceneWithTransition:(KKTransition*)transition
{
	if (_sceneStack.count > 1)
	{
		KKScene* scene = [_sceneStack lastObject];
		[_sceneStack removeLastObject];
		
		transition ? [super presentScene:scene transition:transition] : [super presentScene:scene];
		scene.paused = NO;
	}
}

-(void) popToRootScene
{
	[self popToRootSceneWithTransition:nil];
}

-(void) popToRootSceneWithTransition:(KKTransition*)transition
{
	if (_sceneStack.count > 1)
	{
		KKScene* scene = [_sceneStack firstObject];
		if (scene)
		{
			[_sceneStack removeAllObjects];
			[_sceneStack addObject:scene];
			
			transition ? [super presentScene:scene transition:transition] : [super presentScene:scene];
			scene.paused = NO;
		}
	}
}

-(void) popToSceneNamed:(NSString*)name
{
	[self popToSceneNamed:name transition:nil];
}

-(void) popToSceneNamed:(NSString*)name transition:(KKTransition*)transition
{
	if (_sceneStack.count > 1)
	{
		NSMutableIndexSet* indexes = [NSMutableIndexSet indexSet];
		for (NSUInteger i = _sceneStack.count - 2; i == 0; i--)
		{
			[indexes addIndex:i];
			KKScene* scene = [_sceneStack objectAtIndex:i];
			if ([scene.name isEqualToString:name])
			{
				[_sceneStack removeObjectsAtIndexes:indexes];
				[_sceneStack addObject:scene];
				
				transition ? [super presentScene:scene transition:transition] : [super presentScene:scene];
				scene.paused = NO;
				break;
			}
		}
	}
}

#pragma mark Debug

@dynamic drawsPhysicsShapes;
+(BOOL) drawsPhysicsShapes
{
	return _drawsPhysicsShapes;
}
-(BOOL) drawsPhysicsShapes
{
	return _drawsPhysicsShapes;
}
-(void) setDrawsPhysicsShapes:(BOOL)drawsPhysicsShapes
{
	_drawsPhysicsShapes = drawsPhysicsShapes;
}

@dynamic drawsNodeFrames;
+(BOOL) drawsNodeFrames
{
	return _drawsNodeFrames;
}
-(BOOL) drawsNodeFrames
{
	return _drawsNodeFrames;
}
-(void) setDrawsNodeFrames:(BOOL)drawsNodeFrames
{
	_drawsNodeFrames = drawsNodeFrames;
}

@dynamic drawsNodeAnchorPoints;
+(BOOL) drawsNodeAnchorPoints
{
	return _drawsNodeAnchorPoints;
}
-(BOOL) drawsNodeAnchorPoints
{
	return _drawsNodeAnchorPoints;
}
-(void) setDrawsNodeAnchorPoints:(BOOL)drawsNodeAnchorPoints
{
	_drawsNodeAnchorPoints = drawsNodeAnchorPoints;
}

@dynamic showsCPUStats;
-(void) setShowsCPUStats:(BOOL)showsCPUStats
{
	[self setValue:[NSNumber numberWithBool:showsCPUStats] forKey:@"_showsCPUStats"];
}
-(BOOL) showsCPUStats
{
	return [[self valueForKey:@"_showsCPUStats"] boolValue];
}

@dynamic showsGPUStats;
-(void) setShowsGPUStats:(BOOL)showsGPUStats
{
	[self setValue:[NSNumber numberWithBool:showsGPUStats] forKey:@"_showsGPUStats"];
}
-(BOOL) showsGPUStats
{
	return [[self valueForKey:@"_showsGPUStats"] boolValue];
}

@dynamic showsAllStats;
-(void) setShowsAllStats:(BOOL)showsAllStats
{
	self.showsCPUStats = showsAllStats;
	self.showsGPUStats = showsAllStats;
	self.showsDrawCount = showsAllStats;
	self.showsNodeCount = showsAllStats;
	self.showsFPS = showsAllStats;
}
-(BOOL) showsAllStats
{
	return self.showsCPUStats && self.showsGPUStats && self.showsDrawCount && self.showsNodeCount && self.showsFPS;
}

@end
