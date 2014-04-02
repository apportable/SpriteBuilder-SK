/*
 * SpriteBuilder: http://www.spritebuilder.org
 *
 * Copyright (c) 2014 Apportable Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */


#import "CCBSpriteKitReader.h"
#import "NSValue+CCBReader.h"
#import "CCBSpriteKitAnimationManager.h"
#import "SKNode+CCBReader.h"

NSString* const CCSetupScreenMode = @"CCSetupScreenMode";
NSString* const CCSetupScreenOrientation = @"CCSetupScreenOrientation";
//NSString* const CCSetupAnimationInterval = @"CCSetupAnimationInterval";
//NSString* const CCSetupFixedUpdateInterval = @"CCSetupFixedUpdateInterval";
//NSString* const CCSetupShowDebugStats = @"CCSetupShowDebugStats";
NSString* const CCSetupTabletScale2X = @"CCSetupTabletScale2X";

//NSString* const CCSetupPixelFormat = @"CCSetupPixelFormat";
//NSString* const CCSetupDepthFormat = @"CCSetupDepthFormat";
//NSString* const CCSetupPreserveBackbuffer = @"CCSetupPreserveBackbuffer";
//NSString* const CCSetupMultiSampling = @"CCSetupMultiSampling";
//NSString* const CCSetupNumberOfSamples = @"CCSetupNumberOfSamples";

NSString* const CCScreenOrientationLandscape = @"CCScreenOrientationLandscape";
NSString* const CCScreenOrientationPortrait = @"CCScreenOrientationPortrait";
NSString* const CCScreenModeFlexible = @"CCScreenModeFlexible";
NSString* const CCScreenModeFixed = @"CCScreenModeFixed";

// Fixed size. As wide as iPhone 5 and as high as the iPad.
const CGSize FIXED_SIZE = {568, 384};

/** @def CC_SWAP simple macro that swaps 2 variables */
#define CC_SWAP( x, y )			\
({ __typeof__(x) temp  = (x);		\
x = y; y = temp;		\
})

/*
static CGFloat FindPOTScale(CGFloat size, CGFloat fixedSize)
{
	int scale = 1;
	while (fixedSize * scale < size)
	{
		scale *= 2;
	}
	return (CGFloat)scale;
}
 */


@interface CCBReader (PrivateMethods)
-(CCNode*) nodeGraphFromFile:(NSString*) file owner:(id)o parentSize:(CGSize)parentSize;
@end

@implementation CCBSpriteKitReader

static CGSize currentSceneSize;
+(CGSize) internal_getSceneSize
{
	return currentSceneSize;
}

-(id) init
{
	self = [super init];
	if (self)
	{
		// replace action manager with sprite-kit animation manager instance
		self.animationManager = [[CCBSpriteKitAnimationManager alloc] init];
		// Setup resolution scale and default container size
		animationManager.rootContainerSize = [CCDirector sharedDirector].designSize;
	}
	return self;
}

-(void) setupSpriteKitWithOptions:(NSDictionary*)options
{
	CCDirector* director = [CCDirector sharedDirector];
	
	if ([options[CCSetupScreenMode] isEqual:CCScreenModeFixed])
	{
		CGSize fixed = FIXED_SIZE;
		CGSize size = director.designSize; // equals scene size at this point
		NSAssert(CGSizeEqualToSize(size, CGSizeZero) == NO, @"director design size (scene size) should not be 0,0 at this point");
		
		if ([options[CCSetupScreenOrientation] isEqualToString:CCScreenOrientationPortrait])
		{
			CC_SWAP(fixed.width, fixed.height);
		}
		
		// Find the minimal power-of-two scale that covers both the width and height.
		//director.contentScaleFactor = MIN(FindPOTScale(size.width, fixed.width), FindPOTScale(size.height, fixed.height));
		
		director.UIScaleFactor = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 1.0 : 0.5);
		
		// Let CCFileUtils know that "-ipad" textures should be treated as having a contentScale of 2.0.
		[[CCFileUtils sharedFileUtils] setiPadContentScaleFactor:2.0];
		
		director.designSize = fixed;
		//[director setProjection:CCDirectorProjectionCustom];
	}
	else
	{
		// Setup tablet scaling if it was requested.
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && [options[CCSetupTabletScale2X] boolValue])
		{
			// Set the director to use 2 points per pixel.
			//director.contentScaleFactor *= 2.0;
			
			// Set the UI scale factor to show things at "native" size.
			//director.UIScaleFactor = 0.5;
			
			// Let CCFileUtils know that "-ipad" textures should be treated as having a contentScale of 2.0.
			[[CCFileUtils sharedFileUtils] setiPadContentScaleFactor:2.0];
		}
		
		//[director setProjection:CCDirectorProjection2D];
	}
}

-(CCNode*) nodeFromClassName:(NSString *)nodeClassName
{
	CCNode* node = nil;
	Class nodeClass = NSClassFromString(nodeClassName);
	
	if (nodeClass)
	{
		if (_nodeCount == 0 && self.rootNodeIsScene)
		{
			NSAssert2([nodeClass isSubclassOfClass:[CCScene class]],
					  @"Class named '%@' must inherit from SKScene if it should be loaded as Scene. Currently it's a subclass of '%@'.",
					  nodeClassName, NSStringFromClass([nodeClass superclass]));
			
			node = [[nodeClass alloc] initWithSize:self.sceneSize];
		}
		else
		{
			node = [nodeClass node];
		}
	}

	if (node == nil)
	{
		// process fallbacks
		if ([nodeClassName isEqualToString:@"SKColorSpriteNode"] ||
			[nodeClassName isEqualToString:@"CCNodeColor"] ||
			[nodeClassName isEqualToString:@"CCNodeGradient"])
		{
			node = (CCNode*)[SKSpriteNode spriteNodeWithColor:[SKColor magentaColor] size:CGSizeMake(128, 128)];
		}
		else if ([nodeClassName isEqualToString:@"CCNode"])
		{
			node = [SKNode node];
		}
		else if ([nodeClassName isEqualToString:@"CCSprite"])
		{
			node = (CCNode*)[SKSpriteNode node];
		}
		else if ([nodeClassName isEqualToString:@"CCLabelTTF"])
		{
			node = (CCNode*)[SKLabelNode node];
		}
		else if ([nodeClassName isEqualToString:@"CCParticleSystem"])
		{
			node = (CCNode*)[SKEmitterNode node];
		}

		NSAssert1(node, @"CCBReader: class named '%@' not supported / does not exist", nodeClassName);
	}

#if DEBUG
	NSLog(@" ");
	if ([node class] != NSClassFromString(nodeClassName))
	{
		NSLog(@"~~~~~~~~~~~~~~~~~~ %@ aka %@ (%@) - %p ~~~~~~~~~~~~~~~~~~", nodeClassName, NSStringFromClass([node class]), NSStringFromClass([node superclass]), node);
	}
	else
	{
		NSLog(@"~~~~~~~~~~~~~~~~~~ %@ (%@) - %p ~~~~~~~~~~~~~~~~~~", nodeClassName, NSStringFromClass([node superclass]), node);
	}
#endif

	// mark the node as being created by CCBReader
	node.loadedFromCCB = YES;
	_nodeCount++;
	
	return node;
}

-(void) setSceneSize:(CGSize)sceneSize
{
	_sceneSize = sceneSize;
	currentSceneSize = sceneSize;
	animationManager.rootContainerSize = [CCDirector sharedDirector].designSize; // either fixed size or the new scene size
}

-(CGSize) sceneSize
{
	NSAssert(CGSizeEqualToSize(_sceneSize, CGSizeZero) == NO, @"CCBSpriteKitReader: scene size is 0,0");
	return _sceneSize;
}

#pragma mark CCReader Load overrides

-(void) readerDidLoadNode:(CCNode*)node rootNode:(CCNode*)rootNode
{
	if (node.loadedFromCCB)
	{
		[node postProcessAfterLoadFromCCBWithRootNode:rootNode];
	}
	
	for (CCNode* childNode in node.children)
	{
		[self readerDidLoadNode:childNode rootNode:rootNode];
	}
}

#pragma mark Property Overrides

-(void) readerDidSetSpriteFrame:(CCSpriteFrame*)spriteFrame node:(CCNode*)node
{
	[node setValue:[NSValue valueWithSize:spriteFrame.size] forKey:@"size"];
}

@end
