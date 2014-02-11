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

// TODO: pause/resume scheduler when scene is pushed/popped
// TODO: pause/resume scheduler when scene paused changes

static NSUInteger KKSceneFrameCount = 0;

@implementation KKScene
KKNODE_SHARED_CODE

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
	_scheduler = [[CCScheduler alloc] init];

	self.physicsWorld.contactDelegate = self;
	
	const NSUInteger kInitialCapacity = 4;
	_inputObservers = [NSMutableArray arrayWithCapacity:kInitialCapacity];
	_sceneUpdateObservers = [NSMutableArray arrayWithCapacity:kInitialCapacity];
	_sceneDidEvaluateActionsObservers = [NSMutableArray arrayWithCapacity:kInitialCapacity];
	_sceneDidSimulatePhysicsObservers = [NSMutableArray arrayWithCapacity:kInitialCapacity];
	_physicsContactObservers = [NSMutableArray arrayWithCapacity:kInitialCapacity];
	
	_mainLoopStage = KKMainLoopStageDidSimulatePhysics;
}

@dynamic kkView;
-(KKView*) kkView
{
	NSAssert1([self.view isKindOfClass:[KKView class]], @"Scene's view (%@) is not a KKView class", self.view);
	return (KKView*)self.view;
}

@dynamic frameCount;
-(NSUInteger) frameCount
{
	return KKSceneFrameCount;
}

#pragma mark Update

-(void) update:(NSTimeInterval)currentTime
{
	NSAssert(_mainLoopStage == KKMainLoopStageDidSimulatePhysics, @"Main Loop Error: it seems you implemented didSimulatePhysics but did not call [super didSimulatePhysics]");
	_mainLoopStage = KKMainLoopStageDidUpdate;
	
	KKSceneFrameCount++;
	
	for (id observer in _sceneUpdateObservers)
	{
		[observer update:currentTime];
	}
	
	CCTime delta = currentTime - _lastUpdateTime;
	if (_lastUpdateTime == 0)
	{
		delta = 0;
	}
	
	[_scheduler update:delta];
	_lastUpdateTime = currentTime;
}

-(void) didEvaluateActions
{
	NSAssert(_mainLoopStage == KKMainLoopStageDidUpdate, @"Main Loop Error: it seems you implemented update: but did not call [super update:currentTime]");
	_mainLoopStage = KKMainLoopStageDidEvaluateActions;

	for (id observer in _sceneDidEvaluateActionsObservers)
	{
		[observer didEvaluateActions];
	}
}

-(void) didSimulatePhysics
{
	NSAssert(_mainLoopStage == KKMainLoopStageDidEvaluateActions, @"Main Loop Error: it seems you implemented didEvaluateActions: but did not call [super didEvaluateActions]");
	_mainLoopStage = KKMainLoopStageDidSimulatePhysics;

	for (id observer in _sceneDidSimulatePhysicsObservers)
	{
		[observer didSimulatePhysics];
	}
}

#pragma mark Move to/from View

-(void) willMoveFromView:(SKView *)view
{
	NSLog(@"KKScene:%@ willMoveFromView:%@", self, view);

	// send this to all nodes
	[self enumerateChildNodesWithName:@"//*" usingBlock:^(SKNode *node, BOOL *stop) {
		if ([node respondsToSelector:@selector(sceneWillMoveFromView:)])
		{
			[(id<KKNodeProtocol>)node sceneWillMoveFromView:(KKView*)view];
		}
	}];
}

-(void) didMoveToView:(SKView *)view
{
	NSLog(@"KKScene:%@ didMoveToView:%@", self, view);

	// send this to all nodes
	[self enumerateChildNodesWithName:@"//*" usingBlock:^(SKNode *node, BOOL *stop) {
		if ([node respondsToSelector:@selector(sceneDidMoveToView:)])
		{
			[(id<KKNodeProtocol>)node sceneDidMoveToView:(KKView*)view];
		}
	}];
}

#pragma mark Change Size

-(void) didChangeSize:(CGSize)previousSize
{
	NSLog(@"KKScene:%@ didChangeSize:{%f, %f}", self, self.size.width, self.size.height);

	// send this to all nodes
	[self enumerateChildNodesWithName:@"//*" usingBlock:^(SKNode *node, BOOL *stop) {
		if ([node respondsToSelector:@selector(sceneDidChangeSize:previousSize:)])
		{
			[(id<KKNodeProtocol>)node sceneDidChangeSize:self.size previousSize:previousSize];
		}
	}];
}

/*
#pragma mark Scene Events Observer

-(void) addSceneEventsObserver:(id)observer
{
	// prevent users from registering the scene, because it will always call these methods if implemented
	if (observer && observer != self)
	{
		dispatch_async(dispatch_get_main_queue(), ^{
			if ([observer respondsToSelector:@selector(update:)] &&
				[_sceneUpdateObservers indexOfObject:observer] == NSNotFound)
			{
				[_sceneUpdateObservers addObject:observer];
			}
			if ([observer respondsToSelector:@selector(didEvaluateActions)] &&
				[_sceneDidEvaluateActionsObservers indexOfObject:observer] == NSNotFound)
			{
				[_sceneDidEvaluateActionsObservers addObject:observer];
			}
			if ([observer respondsToSelector:@selector(didSimulatePhysics)] &&
				[_sceneDidSimulatePhysicsObservers indexOfObject:observer] == NSNotFound)
			{
				[_sceneDidSimulatePhysicsObservers addObject:observer];
			}
			if ([observer respondsToSelector:@selector(willMoveFromView:)] &&
				[_sceneWillMoveFromViewObservers indexOfObject:observer] == NSNotFound)
			{
				[_sceneWillMoveFromViewObservers addObject:observer];
			}
			if ([observer respondsToSelector:@selector(didMoveToView:)] &&
				[_sceneDidMoveToViewObservers indexOfObject:observer] == NSNotFound)
			{
				[_sceneDidMoveToViewObservers addObject:observer];
			}
		});
	}
}

-(void) removeSceneEventsObserver:(id)observer
{
	if (observer)
	{
		dispatch_async(dispatch_get_main_queue(), ^{
			[_sceneUpdateObservers removeObject:observer];
			[_sceneDidEvaluateActionsObservers removeObject:observer];
			[_sceneDidSimulatePhysicsObservers removeObject:observer];
			[_sceneWillMoveFromViewObservers removeObject:observer];
			[_sceneDidMoveToViewObservers removeObject:observer];
			[_physicsContactObservers removeObject:observer];
		});
	}
}

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

-(void) setAnchorPoint:(CGPoint)anchorPoint
{
	[super setAnchorPoint:anchorPoint];
	
	// update all view origin nodes
	[self enumerateChildNodesWithName:@"//KKViewOriginNode" usingBlock:^(SKNode *node, BOOL *stop) {
		KKViewOriginNode* originNode = (KKViewOriginNode*)node;
		[originNode updatePositionFromSceneFrame];
	}];
}


#pragma mark Debugging

-(NSString*) stringFromSceneGraph:(KKSceneGraphDumpOptions)options
{
	NSMutableString* dump = [NSMutableString stringWithCapacity:4096];
	[dump appendFormat:@"%@\n", self];
	
	[self enumerateChildNodesWithName:@"//*" usingBlock:^(SKNode *node, BOOL *stop) {
		[dump appendFormat:@"%@\n", node];
	}];
	
	return dump;
}

-(void) logSceneGraph:(KKSceneGraphDumpOptions)options
{
	NSString* dump = [self stringFromSceneGraph:options];
	NSLog(@"\nDump of scene graph:\n%@", dump);
}

@end
