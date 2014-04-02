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

static CGSize CCBSpriteKitReaderSceneSize;

@interface CCBSKFile : SKNode
@property (nonatomic) SKNode* ccbFile;
@end
@implementation CCBSKFile
@end

@interface CCBReader (PrivateMethods)
-(CCNode*) nodeGraphFromFile:(NSString*) file owner:(id)o parentSize:(CGSize)parentSize;
@end

@implementation CCBSpriteKitReader

+(CGSize) internal_getSceneSize
{
	return CCBSpriteKitReaderSceneSize;
}

-(id) init
{
	self = [super init];
	if (self)
	{
		[CCBReader configureCCFileUtils];
		
		// replace action manager with sprite-kit animation manager instance
		self.animationManager = [[CCBSpriteKitAnimationManager alloc] init];
		// Setup resolution scale and default container size
		animationManager.rootContainerSize = [CCDirector sharedDirector].designSize;
	}
	return self;
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
	CCBSpriteKitReaderSceneSize = sceneSize;
	animationManager.rootContainerSize = [CCDirector sharedDirector].designSize;
}

-(CGSize) sceneSize
{
	NSAssert(CGSizeEqualToSize(CCBSpriteKitReaderSceneSize, CGSizeZero) == NO, @"CCBSpriteKitReader: scene size must be assigned before loading a CCBi");
	return CCBSpriteKitReaderSceneSize;
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

-(CCNode*) nodeGraphFromFile:(NSString*) file owner:(id)o parentSize:(CGSize)parentSize
{
	CCNode* node = [super nodeGraphFromFile:file owner:o parentSize:parentSize];
	return node;
}

#pragma mark Property Overrides

-(void) readerDidSetSpriteFrame:(CCSpriteFrame*)spriteFrame node:(CCNode*)node
{
	[node setValue:[NSValue valueWithSize:spriteFrame.size] forKey:@"size"];
}

@end
