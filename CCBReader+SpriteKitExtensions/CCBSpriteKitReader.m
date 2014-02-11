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
#import "JRSwizzle.h"
#import "NSValue+CCBReader.h"

#import "KKScene.h"
#import "KKNode.h"
#import "KKSpriteNode.h"
#import "KKLabelNode.h"
#import "KKEmitterNode.h"
#import "KKViewOriginNode.h"
#import "KKNodeShared.h"

static CGSize CCBSpriteKitReaderSceneSize;

@implementation CCBSpriteKitReader

-(id) init
{
	self = [super init];
	if (self)
	{
		[CCBReader configureCCFileUtils];
		
		[self swizzleMethodNamed:@"setAnchorPoint:" classNames:@[@"SKScene", @"SKSpriteNode", @"SKVideoNode"]];
	}
	return self;
}

-(void) swizzleMethodNamed:(NSString*)methodName classNames:(NSArray*)classNames
{
	for (NSString* className in classNames)
	{
		[self swizzleMethodNamed:methodName className:className];
	}
}

-(void) swizzleMethodNamed:(NSString*)methodName className:(NSString*)className
{
	NSError* error = nil;
	Class klass = NSClassFromString(className);
	NSAssert2(klass, @"CCBSpriteKitReader: unknown class '%@' - can't swizzle method '%@'", className, methodName);
	
	NSString* newMethod = [NSString stringWithFormat:@"ccb_%@", methodName];
	[klass jr_swizzleMethod:NSSelectorFromString(methodName)
				 withMethod:NSSelectorFromString(newMethod)
					  error:&error];
	NSAssert2(error == nil, @"CCBSpriteKitReader: method '%@' swizzle error: %@", methodName, error);
}

-(CCNode*) nodeFromClassName:(NSString *)nodeClassName
{
	// map CC nodes to SK nodes
	CCNode* node = nil;

	if ([nodeClassName isEqualToString:@"CCNode"] ||
		[nodeClassName isEqualToString:@"SKNode"])
	{
		node = [KKNode node];
	}
	else if ([nodeClassName isEqualToString:@"CCSprite"] ||
			 [nodeClassName isEqualToString:@"CCNodeColor"] ||
			 [nodeClassName isEqualToString:@"CCNodeGradient"] ||
			 [nodeClassName isEqualToString:@"SKSpriteNode"])
	{
		node = (CCNode*)[KKSpriteNode node];
	}
	else if ([nodeClassName isEqualToString:@"SKColorSpriteNode"])
	{
		node = (CCNode*)[KKSpriteNode spriteNodeWithColor:[SKColor magentaColor] size:CGSizeMake(32, 32)];
	}
	else if ([nodeClassName isEqualToString:@"CCLabelTTF"] ||
			 [nodeClassName isEqualToString:@"SKLabelNode"])
	{
		node = (CCNode*)[KKLabelNode node];
	}
	else if ([nodeClassName isEqualToString:@"CCParticleSystem"] ||
			 [nodeClassName isEqualToString:@"SKEmitterNode"])
	{
		node = (CCNode*)[KKEmitterNode node];
	}
	else
	{
		Class nodeClass = NSClassFromString(nodeClassName);
		NSAssert1(nodeClass, @"%@: reader could not find this class", nodeClassName);
		NSAssert1([nodeClass isSubclassOfClass:[SKScene class]] == NO, @"class %@ is a subclass of SKScene, it should be a SKNode subclass", nodeClassName);
		
		node = [[nodeClass alloc] init];
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

	NSAssert2([node respondsToSelector:@selector(isKoboldKitNode)], @"CCBSpriteKitReader: not a Kobold Kit node: %@ (%@)", node, NSStringFromClass([node class]));

	return node;
}

-(void) setSceneSize:(CGSize)sceneSize
{
	CCBSpriteKitReaderSceneSize = sceneSize;
}

-(CCScene*) createScene
{
	NSAssert(CCBSpriteKitReaderSceneSize.width > 0.0 && CCBSpriteKitReaderSceneSize.height > 0.0,
			 @"CCBReader scene size not set! Use: [CCBReader setSceneSize:kkView.bounds.size]; to set scene size before loading the first scene.");
	
	return [KKScene sceneWithSize:CCBSpriteKitReaderSceneSize];
}

#pragma mark Property Overrides

-(void) readerDidSetSpriteFrame:(CCSpriteFrame*)spriteFrame node:(CCNode*)node
{
	[node setValue:[NSValue valueWithSize:spriteFrame.size] forKey:@"size"];
}

@end
