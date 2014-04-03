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

#import "SKNode+CCBReader.h"
#import "CCBSpriteKitMacros.h"
#import "CCBSpriteKitReader.h"
#import "CCBReaderDelegate.h"

static NSString* CCBReaderNodeUserObjectKey = @"CCBReader:UserObject";
static NSString* CCBReaderUserDataKeyForContentSizeType = @"CCBReader:contentSizeType";
static NSString* CCBReaderUserDataKeyForScaleType = @"CCBReader:scaleType";
static NSString* CCBReaderUserDataKeyForPositionType = @"CCBReader:positionType";
static NSString* CCBReaderUserDataKeyForLoadedFromCCB = @"CCBSpriteKitReader:loadedFromCCB";

@interface CCBReaderSizeType : NSObject
@property (nonatomic) CCSizeType sizeType;
@end
@implementation CCBReaderSizeType
-(id) initWithSizeType:(CCSizeType)sizeType
{
	self = [super init];
	_sizeType = sizeType;
	return self;
}
@end

@interface CCBReaderScaleType : NSObject
@property (nonatomic) CCScaleType scaleType;
@end
@implementation CCBReaderScaleType
-(id) initWithScaleType:(CCScaleType)scaleType
{
	self = [super init];
	_scaleType = scaleType;
	return self;
}
@end

@interface CCBReaderPositionType : NSObject
@property (nonatomic) CCPositionType positionType;
@end
@implementation CCBReaderPositionType
-(id) initWithPositionType:(CCPositionType)positionType
{
	self = [super init];
	_positionType = positionType;
	return self;
}
@end


@implementation SKNode (CCBReader)

#pragma mark Manage User Data/Objects

@dynamic userObject;
-(void) setUserObject:(id)userObject
{
	if (self.userData == nil)
	{
		self.userData = [NSMutableDictionary dictionary];
	}

	if (userObject)
	{
		[self.userData setObject:userObject forKey:CCBReaderNodeUserObjectKey];
	}
	else
	{
		[self.userData removeObjectForKey:CCBReaderNodeUserObjectKey];
	}
}
-(id) userObject
{
	return [self.userData objectForKey:CCBReaderNodeUserObjectKey];
}

-(NSMutableDictionary*) getOrCreateUserData
{
	NSMutableDictionary* userData = self.userData;
	if (userData == nil)
	{
		userData = [NSMutableDictionary dictionary];
		self.userData = userData;
	}
	return userData;
}

#pragma mark Properties

@dynamic rotation;
-(void) setRotation:(CGFloat)rotation
{
	self.zRotation = CC_DEGREES_TO_RADIANS(-rotation);
}
-(CGFloat) rotation
{
	return self.zRotation;
}

@dynamic skewX, skewY;
-(void) setSkewX:(CGFloat)skewX
{
}
-(CGFloat) skewX
{
	return 0.0;
}
-(void) setSkewY:(CGFloat)skewY
{
}
-(CGFloat) skewY
{
	return 0.0;
}

@dynamic visible;
-(void) setVisible:(BOOL)visible
{
	self.hidden = !visible;
}
-(BOOL) visible
{
	return !self.hidden;
}

@dynamic spriteFrame;
-(void) setSpriteFrame:(SKTexture *)spriteFrame
{
	if ([self isKindOfClass:[SKSpriteNode class]])
	{
		SKSpriteNode* sprite = (SKSpriteNode*)self;
		sprite.texture = spriteFrame;
	}
}
-(SKTexture*)spriteFrame
{
	if ([self isKindOfClass:[SKSpriteNode class]])
	{
		SKSpriteNode* sprite = (SKSpriteNode*)self;
		return sprite.texture;
	}
	return nil;
}

@dynamic scaleX, scaleY;
-(void) setScaleX:(CGFloat)scaleX
{
	self.xScale = scaleX;
}
-(void) setScaleY:(CGFloat)scaleY
{
	self.yScale = scaleY;
}
-(CGFloat) scaleX
{
	return self.xScale;
}
-(CGFloat) scaleY
{
	return self.yScale;
}
-(CGFloat) scale
{
	return self.xScale;
}

@dynamic opacity;
-(void) setOpacity:(CGFloat)opacity
{
	self.alpha = opacity;
}
-(CGFloat) opacity
{
	return self.alpha;
}

@dynamic scaleType;
-(void) setScaleType:(CCScaleType)scaleType
{
	CCBReaderScaleType* proxy = [[self getOrCreateUserData] objectForKey:CCBReaderUserDataKeyForScaleType];
	if (proxy)
	{
		proxy.scaleType = scaleType;
	}
	else
	{
		proxy = [[CCBReaderScaleType alloc] initWithScaleType:scaleType];
		[[self getOrCreateUserData] setObject:proxy forKey:CCBReaderUserDataKeyForScaleType];
	}
}
-(CCScaleType) scaleType
{
	CCBReaderScaleType* proxy = [[self getOrCreateUserData] objectForKey:CCBReaderUserDataKeyForScaleType];
	return proxy.scaleType;
}

@dynamic contentSize;
-(void) setContentSize:(CGSize)contentSize
{
	if ([self respondsToSelector:@selector(setSize:)])
	{
		[(id)self setSize:contentSize];
	}
}
-(CGSize) contentSize
{
	if ([self respondsToSelector:@selector(setSize:)])
	{
		return [(id)self size];
	}
	
	return self.frame.size;
}

@dynamic contentSizeType;
-(void) setContentSizeType:(CCSizeType)contentSizeType
{
	CCBReaderSizeType* proxy = [[self getOrCreateUserData] objectForKey:CCBReaderUserDataKeyForContentSizeType];
	if (proxy)
	{
		proxy.sizeType = contentSizeType;
	}
	else
	{
		proxy = [[CCBReaderSizeType alloc] initWithSizeType:contentSizeType];
		[[self getOrCreateUserData] setObject:proxy forKey:CCBReaderUserDataKeyForContentSizeType];
	}
}
-(CCSizeType) contentSizeType
{
	CCBReaderSizeType* proxy = [[self getOrCreateUserData] objectForKey:CCBReaderUserDataKeyForContentSizeType];
	return proxy.sizeType;
}

@dynamic positionType;
-(void) setPositionType:(CCPositionType)positionType
{
	CCBReaderPositionType* proxy = [[self getOrCreateUserData] objectForKey:CCBReaderUserDataKeyForPositionType];
	if (proxy)
	{
		proxy.positionType = positionType;
	}
	else
	{
		proxy = [[CCBReaderPositionType alloc] initWithPositionType:positionType];
		[[self getOrCreateUserData] setObject:proxy forKey:CCBReaderUserDataKeyForPositionType];
	}
}
-(CCPositionType) positionType
{
	CCBReaderPositionType* proxy = [[self getOrCreateUserData] objectForKey:CCBReaderUserDataKeyForPositionType];
	return proxy.positionType;
}

-(void) setValue:(id)value forUndefinedKey:(NSString *)key
{
	NSLog(@"IGNORED: %@ undefined key '%@' for value: %@", NSStringFromClass([self class]), key, value);
}

#pragma mark Post Load Processing

-(void) sendDidLoadFromCCBWithRootNode:(SKNode*)rootNode
{
	// send readerDidLoadSelf to every node
	if ([self respondsToSelector:@selector(readerDidLoadSelf)])
	{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		[self performSelector:@selector(readerDidLoadSelf)];
#pragma clang diagnostic pop
	}
	
	// also send readerDidLoadChildNode: to the CCB's main node (the 'scene' node)
	if (self != rootNode)
	{
		if ([rootNode respondsToSelector:@selector(readerDidLoadChildNode:)])
		{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
			[rootNode performSelector:@selector(readerDidLoadChildNode:) withObject:self];
#pragma clang diagnostic pop
		}
	}
}

-(void) postProcessAfterLoadFromCCBWithRootNode:(SKNode*)rootNode
{
	[self sendDidLoadFromCCBWithRootNode:rootNode];

	// apply the positionType, sizeType, scaleType properties here and only once
	if ([self respondsToSelector:@selector(setSize:)])
	{
		CGSize size = [self convertSize:[(id)self contentSize] sizeType:self.contentSizeType];
		[(id)self setSize:size];
	}
	
	self.scaleAsPoint = [self convertScaleX:self.xScale scaleY:self.yScale scaleType:self.scaleType];
	self.position = [self convertPosition:self.position positionType:self.positionType];

	// convert only once
	[self.userData removeObjectForKey:CCBReaderUserDataKeyForContentSizeType];
	[self.userData removeObjectForKey:CCBReaderUserDataKeyForScaleType];
	[self.userData removeObjectForKey:CCBReaderUserDataKeyForPositionType];
	[self.userData removeObjectForKey:CCBReaderUserDataKeyForLoadedFromCCB];

	// remove dictionary if empty (user may have already added custom userData items, hence the check)
	if (self.userData.count == 0)
	{
		self.userData = nil;
	}
	
	/*
	NSLog(@"%@ (%p)  size: {%.1f, %.1f} scale: {%.2f, %.2f}", NSStringFromClass([self class]), self,
		  [self respondsToSelector:@selector(setSize:)] ? [(id)self size].width : self.frame.size.width,
		  [self respondsToSelector:@selector(setSize:)] ? [(id)self size].height : self.frame.size.height, self.xScale, self.yScale);
	 */
}

#pragma mark Adjust scale based on scaleType

@dynamic scaleAsPoint;
-(CGPoint) scaleAsPoint
{
	return CGPointMake(self.xScale, self.yScale);
}
-(void) setScaleAsPoint:(CGPoint)scaleAsPoint
{
	self.xScale = scaleAsPoint.x;
	self.yScale = scaleAsPoint.y;
}

-(CGPoint) convertScaleX:(CGFloat)scaleX scaleY:(CGFloat)scaleY scaleType:(CCScaleType)scaleType
{
	CGPoint newScale = CGPointMake(scaleX, scaleY);
	
	if (scaleType == CCScaleTypeScaled)
	{
		CGFloat scaleFactor = [CCDirector sharedDirector].UIScaleFactor;
		newScale.x *= scaleFactor;
		newScale.y *= scaleFactor;
	}
	
	return newScale;
}

#pragma mark Adjust Size based on sizeType

-(CGSize) contentSizeFromParent
{
	CGSize parentSize = CGSizeZero;
	SKNode* parent = self.parent;
	
	if (parent)
	{
		if ([parent respondsToSelector:@selector(setSize:)])
		{
			parentSize = [(id)parent size];
		}
		else
		{
			parentSize = parent.frame.size;
		}
	}
	
	if (CGSizeEqualToSize(parentSize, CGSizeZero))
	{
		// if there's no parent (or parent's size is 0,0) assume "parent" to be scene sized
		parentSize = [CCBSpriteKitReader internal_getSceneSize];
	}
	
	return parentSize;
}

-(CGSize) convertSize:(CGSize)size sizeType:(CCSizeType)sizeType
{
	CGSize newSize = size;
    CCDirector* director = [CCDirector sharedDirector];

	switch (sizeType.widthUnit)
	{
		case CCSizeUnitPoints:
			// nothing to do
			break;
		case CCSizeUnitUIPoints:
			newSize.width = director.UIScaleFactor * size.width;
			break;
		case CCSizeUnitNormalized:
			newSize.width = size.width * [self contentSizeFromParent].width;
			break;
		case CCSizeUnitInsetPoints:
			newSize.width = [self contentSizeFromParent].width - size.width;
			break;
		case CCSizeUnitInsetUIPoints:
			newSize.width = [self contentSizeFromParent].width - size.width * director.UIScaleFactor;
			break;
			
		default:
			[NSException raise:NSInternalInconsistencyException format:@"unsupported contentSize unit type for width: %d", sizeType.widthUnit];
			break;
	}
	
	switch (sizeType.heightUnit)
	{
		case CCSizeUnitPoints:
			// nothing to do
			break;
		case CCSizeUnitUIPoints:
			newSize.height = director.UIScaleFactor * size.height;
			break;
		case CCSizeUnitNormalized:
			newSize.height = size.height * [self contentSizeFromParent].height;
			break;
		case CCSizeUnitInsetPoints:
			newSize.height = [self contentSizeFromParent].height - size.height;
			break;
		case CCSizeUnitInsetUIPoints:
			newSize.height = [self contentSizeFromParent].height - size.height * director.UIScaleFactor;
			break;
			
		default:
			[NSException raise:NSInternalInconsistencyException format:@"unsupported contentSize unit type for height: %d", sizeType.heightUnit];
			break;
	}
	
	return newSize;
}

#pragma mark Adjust Position with positionType

-(CGPoint) convertPosition:(CGPoint)originalPosition positionType:(CCPositionType)positionType
{
	CGPoint newPosition = originalPosition;

	CGPoint anchorPoint = CGPointZero;
	if ([self.parent respondsToSelector:@selector(anchorPoint)])
	{
		anchorPoint = [(SKSpriteNode*)self.parent anchorPoint];
	}
	else if ([self.parent isKindOfClass:[SKLabelNode class]])
	{
		anchorPoint = CGPointMake(0.5, 0.5);
	}

	switch (positionType.xUnit)
	{
		case CCPositionUnitPoints:
			// no adjustment
			break;
		case CCPositionUnitUIPoints:
			newPosition.x *= [CCDirector sharedDirector].UIScaleFactor;
			break;
		case CCPositionUnitNormalized:
		{
			CGFloat parentWidth = [self contentSizeFromParent].width;
			newPosition.x = newPosition.x * parentWidth - (parentWidth * anchorPoint.x);
			break;
		}
			
		default:
			[NSException raise:NSInternalInconsistencyException format:@"unsupported positionType for x: %d", positionType.xUnit];
			break;
	}
	
	switch (positionType.yUnit)
	{
		case CCPositionUnitPoints:
			// no adjustment
			break;
		case CCPositionUnitUIPoints:
			newPosition.y *= [CCDirector sharedDirector].UIScaleFactor;
			break;
		case CCPositionUnitNormalized:
		{
			CGFloat parentHeight = [self contentSizeFromParent].height;
			newPosition.y = newPosition.y * parentHeight - (parentHeight * anchorPoint.y);
			break;
		}
			
		default:
			[NSException raise:NSInternalInconsistencyException format:@"unsupported positionType for y: %d", positionType.yUnit];
			break;
	}
	
	// Account for reference corner
	switch (positionType.corner)
	{
		default:
		case CCPositionReferenceCornerBottomLeft:
			// do nothing
			break;
		case CCPositionReferenceCornerTopLeft:
			// Reverse y-axis
			newPosition.y = [self contentSizeFromParent].height - newPosition.y;
			break;
		case CCPositionReferenceCornerTopRight:
			// Reverse x-axis and y-axis
			newPosition.x = [self contentSizeFromParent].width - newPosition.x;
			newPosition.y = [self contentSizeFromParent].height - newPosition.y;
			break;
		case CCPositionReferenceCornerBottomRight:
			// Reverse x-axis
			newPosition.x = [self contentSizeFromParent].width - newPosition.x;
			break;
	}
	
	return newPosition;
}

#pragma mark Cocos2D additions

-(CGPoint) convertToWorldSpace:(CGPoint)position
{
	return [self.parent convertPoint:position toNode:self.scene];
}

-(CGPoint) convertToNodeSpace:(CGPoint)position
{
	return [self.parent convertPoint:position fromNode:self.scene];
}

-(BOOL) hitTestWithWorldPosition:(CGPoint)worldPosition
{
	CGPoint localPosition = [self convertToNodeSpace:worldPosition];
	CGSize size = self.contentSize;
	BOOL inside = (localPosition.x > size.width) || (localPosition.y > size.height);
	return inside;
}

#pragma mark Loaded from CCB

@dynamic loadedFromCCB;
-(void) setLoadedFromCCB:(BOOL)loadedFromCCB
{
	if (loadedFromCCB)
	{
		[[self getOrCreateUserData] setObject:@"YES" forKey:CCBReaderUserDataKeyForLoadedFromCCB];
	}
	else
	{
		[[self getOrCreateUserData] removeObjectForKey:CCBReaderUserDataKeyForLoadedFromCCB];
	}
}
-(BOOL) loadedFromCCB
{
	return ([[self getOrCreateUserData] objectForKey:CCBReaderUserDataKeyForLoadedFromCCB] != nil);
}

@end
