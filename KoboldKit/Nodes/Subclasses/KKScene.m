/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import "KKScene.h"
#import "KKNode.h"
#import "KKView.h"
#import "SKNode+KoboldKit.h"
#import "KKViewOriginNode.h"
#import "KKNodeShared.h"
#import "CCScheduler.h"
#import "CCBSpriteKitCompatibility.h"

static NSUInteger KKSceneFrameCount = 0;

@implementation KKScene
KKNODE_SHARED_CODE
KKNODE_SHARED_OVERRIDE_ANCHORPOINT

#pragma mark Init / Dealloc

-(id) initWithSize:(CGSize)size
{
	self = [super initWithSize:size];
	if (self)
	{
		[self initDefaults];
	}
	return self;
}

-(id) init
{
#if TARGET_OS_IPHONE
	CGSize windowSize = [UIApplication sharedApplication].keyWindow.frame.size;
#else
	CGSize windowSize = [NSApplication sharedApplication].keyWindow.frame.size;
#endif
	
	self = [super initWithSize:windowSize];
	if (self)
	{
		NSLog(@"WARNING: scene (%@) created without specifying size. Using window size: {%.0f, %.0f}. Use sceneWithSize: initializer to prevent this warning.", self, windowSize.width, windowSize.height);
		[self initDefaults];
	}
	return self;
}

-(void) initDefaults
{
	self.physicsWorld.contactDelegate = self;
	
	const NSUInteger kInitialCapacity = 4;
	_inputObservers = [NSMutableArray arrayWithCapacity:kInitialCapacity];
	_physicsContactObservers = [NSMutableArray arrayWithCapacity:kInitialCapacity];
	
	_mainLoopStage = KKMainLoopStageDidSimulatePhysics;
}

@dynamic kkView;
-(KKView*) kkView
{
	NSAssert(_kkView, @"Scene's view not yet available (scene not presented)");
	return _kkView;
}

@dynamic frameCount;
-(NSUInteger) frameCount
{
	return KKSceneFrameCount;
}

#pragma mark Update

-(void) update:(NSTimeInterval)currentTime
{
	NSAssert(_mainLoopStage == KKMainLoopStageDidSimulatePhysics, @"Main Loop Error: it seems your scene implements didSimulatePhysics but does not call [super didSimulatePhysics]");
	_mainLoopStage = KKMainLoopStageDidUpdate;
	
	KKSceneFrameCount++;
	
	CCTime delta = (_lastUpdateTime == 0) ? 0 : currentTime - _lastUpdateTime;
	[_kkView.scheduler update:delta];
	_lastUpdateTime = currentTime;
}

-(void) didEvaluateActions
{
	NSAssert(_mainLoopStage == KKMainLoopStageDidUpdate, @"Main Loop Error: it seems your scene implements update: but does not call [super update:currentTime]");
	_mainLoopStage = KKMainLoopStageDidEvaluateActions;

	[_kkView.scheduler didEvaluateActions];
}

-(void) didSimulatePhysics
{
	NSAssert(_mainLoopStage == KKMainLoopStageDidEvaluateActions, @"Main Loop Error: it seems your scene implements didEvaluateActions: but does not call [super didEvaluateActions]");
	_mainLoopStage = KKMainLoopStageDidSimulatePhysics;

	[_kkView.scheduler didSimulatePhysics];
}

#pragma mark Move to/from View

-(void) didMoveToView:(SKView *)view
{
	NSLog(@"KKScene:%@ didMoveToView:%@", self, view);

	NSAssert1([self.view isKindOfClass:[KKView class]], @"Scene's view (%@) is not a KKView class", self.view);
	_kkView = (KKView*)self.view;

	CCScheduler* scheduler = _kkView.scheduler;
	[scheduler setPaused:self.paused target:(id<CCSchedulerTarget>)self];
	
	// send this to all nodes
	[self scene:self didMoveToView:_kkView];
	[self enumerateChildNodesWithName:@"//*" usingBlock:^(SKNode *node, BOOL *stop) {
		if ([node respondsToSelector:@selector(scene:didMoveToView:)])
		{
			[(id<KKNodeProtocol>)node scene:self didMoveToView:_kkView];
		}
		
		[scheduler setPaused:node.paused target:(id<CCSchedulerTarget>)node];
	}];
}

-(void) willMoveFromView:(SKView *)view
{
	NSLog(@"KKScene:%@ willMoveFromView:%@", self, view);

	CCScheduler* scheduler = _kkView.scheduler;
	[scheduler setPaused:YES target:(id<CCSchedulerTarget>)self];

	// send this to all nodes
	[self scene:self willMoveFromView:_kkView];
	[self enumerateChildNodesWithName:@"//*" usingBlock:^(SKNode *node, BOOL *stop) {
		if ([node respondsToSelector:@selector(scene:willMoveFromView:)])
		{
			[(id<KKNodeProtocol>)node scene:self willMoveFromView:_kkView];
		}

		[scheduler setPaused:YES target:(id<CCSchedulerTarget>)node];
	}];
	
	_kkView = nil;
}

#pragma mark Change Size

-(void) didChangeSize:(CGSize)previousSize
{
	NSLog(@"KKScene:%@ didChangeSize:{%f, %f}", self, self.size.width, self.size.height);

	// send this to all nodes
	CGSize currentSize = self.size;
	[self scene:self didChangeSize:currentSize previousSize:previousSize];
	[self enumerateChildNodesWithName:@"//*" usingBlock:^(SKNode *node, BOOL *stop) {
		if ([node respondsToSelector:@selector(scene:didChangeSize:previousSize:)])
		{
			[(id<KKNodeProtocol>)node scene:self didChangeSize:currentSize previousSize:previousSize];
		}
	}];
}

/*
#pragma mark Physics Contact Observer

-(void) addPhysicsContactEventsObserver:(id<KKPhysicsContactEventDelegate>)observer
{
	if (observer && observer != (id)self)
	{
		dispatch_async(dispatch_get_main_queue(), ^{
			if ([_physicsContactObservers indexOfObject:observer] == NSNotFound)
			{
				[_physicsContactObservers addObject:observer];
			}
		});
	}
}

-(void) removePhysicsContactEventsObserver:(id<KKPhysicsContactEventDelegate>)observer
{
	if (observer)
	{
		dispatch_async(dispatch_get_main_queue(), ^{
			[_physicsContactObservers removeObject:observer];
		});
	}
}


#pragma mark Input Observer

-(void) addInputEventsObserver:(id)observer
{
	if (observer && observer != self)
	{
		dispatch_async(dispatch_get_main_queue(), ^{
			if ([_inputObservers indexOfObject:observer] == NSNotFound)
			{
				[_inputObservers addObject:observer];
			}
		});
	}
}

-(void) removeInputEventsObserver:(id)observer
{
	if (observer)
	{
		dispatch_async(dispatch_get_main_queue(), ^{
			[_inputObservers removeObject:observer];
		});
	}
}

#pragma mark Touches

DEVELOPER_FIXME("remove calls to respondsToSelector by separating observers into individual touch event arrays")

#if TARGET_OS_IPHONE

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
	
	for (id observer in _inputObservers)
	{
		if ([observer respondsToSelector:@selector(touchesBegan:withEvent:)])
		{
			[observer touchesBegan:touches withEvent:event];
		}
	}
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesMoved:touches withEvent:event];
	
	for (id observer in _inputObservers)
	{
		if ([observer respondsToSelector:@selector(touchesMoved:withEvent:)])
		{
			[observer touchesMoved:touches withEvent:event];
		}
	}
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];
	
	for (id observer in _inputObservers)
	{
		if ([observer respondsToSelector:@selector(touchesEnded:withEvent:)])
		{
			[observer touchesEnded:touches withEvent:event];
		}
	}
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesCancelled:touches withEvent:event];
	
	for (id observer in _inputObservers)
	{
		if ([observer respondsToSelector:@selector(touchesCancelled:withEvent:)])
		{
			[observer touchesCancelled:touches withEvent:event];
		}
	}
}

#else // OS X

-(void) mouseDown:(NSEvent*)theEvent
{
	[super mouseDown:theEvent];
	
	for (id observer in _inputObservers)
	{
		if ([observer respondsToSelector:@selector(mouseDown:)])
		{
			[observer mouseDown:theEvent];
		}
	}
}

-(void) mouseDragged:(NSEvent*)theEvent
{
	[super mouseDragged:theEvent];

	for (id observer in _inputObservers)
	{
		if ([observer respondsToSelector:@selector(mouseDragged:)])
		{
			[observer mouseDragged:theEvent];
		}
	}
}

-(void) mouseMoved:(NSEvent*)theEvent
{
	[super mouseMoved:theEvent];

	for (id observer in _inputObservers)
	{
		if ([observer respondsToSelector:@selector(mouseMoved:)])
		{
			[observer mouseMoved:theEvent];
		}
	}
}

-(void) mouseUp:(NSEvent*)theEvent
{
	[super mouseUp:theEvent];

	for (id observer in _inputObservers)
	{
		if ([observer respondsToSelector:@selector(mouseUp:)])
		{
			[observer mouseUp:theEvent];
		}
	}
}

#endif

#pragma mark Physics Contact

-(void) didBeginContact:(SKPhysicsContact *)contact
{
	SKPhysicsBody* bodyA = contact.bodyA;
	SKPhysicsBody* bodyB = contact.bodyB;
	SKNode* nodeA = bodyA.node;
	SKNode* nodeB = bodyB.node;
	for (id<KKPhysicsContactEventDelegate> observer in _physicsContactObservers)
	{
		SKNode* observerNode = observer.node;
		if (observerNode == nodeA)
		{
			[observer didBeginContact:contact otherBody:bodyB];
		}
		else if (observerNode == nodeB)
		{
			[observer didBeginContact:contact otherBody:bodyA];
		}
	}
}

-(void) didEndContact:(SKPhysicsContact *)contact
{
	SKPhysicsBody* bodyA = contact.bodyA;
	SKPhysicsBody* bodyB = contact.bodyB;
	SKNode* nodeA = bodyA.node;
	SKNode* nodeB = bodyB.node;
	for (id<KKPhysicsContactEventDelegate> observer in _physicsContactObservers)
	{
		SKNode* observerNode = observer.node;
		if (observerNode == nodeA)
		{
			[observer didEndContact:contact otherBody:bodyB];
		}
		else if (observerNode == nodeB)
		{
			[observer didEndContact:contact otherBody:bodyA];
		}
	}
}
*/

#pragma mark AnchorPoint
/*
-(void) setAnchorPoint:(CGPoint)anchorPoint
{
	[super setAnchorPoint:anchorPoint];
	
	// update all view origin nodes
	[self enumerateChildNodesWithName:@"//KKViewOriginNode" usingBlock:^(SKNode *node, BOOL *stop) {
		KKViewOriginNode* originNode = (KKViewOriginNode*)node;
		[originNode updatePositionFromSceneFrame];
	}];
}
*/

#pragma mark Debugging

-(NSString*) stringFromSceneGraph:(KKSceneGraphDumpOptions)options
{
	__block NSInteger currentBranch = 1;
	NSMutableDictionary* parentNodes = [NSMutableDictionary dictionary];
	[parentNodes setObject:[NSNumber numberWithInteger:currentBranch] forKey:[NSNumber numberWithUnsignedInteger:[self hash]]];
	
	NSMutableString* dump = [NSMutableString stringWithCapacity:4096];
	[dump appendFormat:@"\n%@%@ (%p), parent: %@%@ (%p)\n",
	 NSStringFromClass([self class]), self.name.length ? [NSString stringWithFormat:@" '%@'", self.name] : @"", self,
	 NSStringFromClass([self.parent class]), self.parent.name.length ? [NSString stringWithFormat:@" '%@'", self.parent.name] : @"", self.parent];
	
	[self enumerateChildNodesWithName:@"//*" usingBlock:^(SKNode *node, BOOL *stop) {
		NSString* tabs = @"";
		
		if (node.parent)
		{
			NSNumber* parentNodeBranchNumber = [parentNodes objectForKey:[NSNumber numberWithUnsignedInteger:[node.parent hash]]];
			if (parentNodeBranchNumber == nil)
			{
				currentBranch++;
				parentNodeBranchNumber = [NSNumber numberWithInteger:currentBranch];
				[parentNodes setObject:parentNodeBranchNumber forKey:[NSNumber numberWithUnsignedInteger:[node.parent hash]]];
			}
			
			NSInteger numTabs = [parentNodeBranchNumber integerValue];
			if (numTabs > 0)
			{
				const NSUInteger tabLength = 4;
				tabs = [tabs stringByPaddingToLength:numTabs * tabLength withString:@" " startingAtIndex:0];
			}
		}
		
		[dump appendFormat:@"%@%@%@ (%p), parent: %@%@ (%p)\n", tabs,
		 NSStringFromClass([node class]), node.name.length ? [NSString stringWithFormat:@" '%@'", node.name] : @"", node,
		 NSStringFromClass([node.parent class]), node.parent.name.length ? [NSString stringWithFormat:@" '%@'", node.parent.name] : @"", node.parent];
	}];

	[dump appendString:@"\n"];
		
	return dump;
}

-(void) logSceneGraph:(KKSceneGraphDumpOptions)options
{
	NSString* dump = [self stringFromSceneGraph:options];
	NSLog(@"\nDump of scene graph:\n%@", dump);
}

@end
