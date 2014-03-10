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


static NSString* CCBReaderNodeUserObjectKey = @"CCBReader:UserObject";
static NSString* CCBReaderUserDataKeyForContentSizeType = @"CCBReader:contentSizeType";
static NSString* CCBReaderUserDataKeyForScaleType = @"CCBReader:scaleType";
static NSString* CCBReaderUserDataKeyForPositionType = @"CCBReader:positionType";

@interface CCBReaderSizeType : NSObject
@property (readonly) CCSizeType sizeType;
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
@property CCScaleType scaleType;
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
@property CCPositionType positionType;
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

-(id) getAndRemoveUserDataObjectForKey:(NSString*)key
{
	id object = [self.userData objectForKey:key];
	
	if (self.userData.count > 1)
	{
		[self.userData removeObjectForKey:key];
	}
	else
	{
		self.userData = nil;
	}
	
	return object;
}

#pragma mark Properties

-(void) setRotation:(CGFloat)rotation
{
	self.zRotation = CC_DEGREES_TO_RADIANS(-rotation);
}
-(CGFloat) rotation
{
	return self.zRotation;
}

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

-(void) setVisible:(BOOL)visible
{
	self.hidden = !visible;
}
-(BOOL) visible
{
	return !self.hidden;
}

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

-(void) setScaleType:(CCScaleType)scaleType
{
	[[self getOrCreateUserData] setObject:[[CCBReaderScaleType alloc] initWithScaleType:scaleType] forKey:CCBReaderUserDataKeyForScaleType];
}
-(CCScaleType) scaleType
{
	[NSException raise:NSInternalInconsistencyException format:@"scaleType not available at runtime"];
	return CCScaleTypePoints;
}

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

-(void) setContentSizeType:(CCSizeType)contentSizeType
{
	[[self getOrCreateUserData] setObject:[[CCBReaderSizeType alloc] initWithSizeType:contentSizeType] forKey:CCBReaderUserDataKeyForContentSizeType];
}
-(CCSizeType) contentSizeType
{
	[NSException raise:NSInternalInconsistencyException format:@"contentSizeType not available at runtime"];
	return CCSizeTypeMake(0, 0);
}

-(void) setPositionType:(CCPositionType)positionType
{
	[[self getOrCreateUserData] setObject:[[CCBReaderPositionType alloc] initWithPositionType:positionType] forKey:CCBReaderUserDataKeyForPositionType];
}
-(CCPositionType) positionType
{
	return CCPositionTypeMake(CCPositionUnitPoints, CCPositionUnitPoints, CCPositionReferenceCornerBottomLeft);
}

-(void) setValue:(id)value forUndefinedKey:(NSString *)key
{
	NSLog(@"IGNORED: %@ undefined key '%@' for value: %@", NSStringFromClass([self class]), key, value);
}

#pragma mark Post Load Processing

-(void) postProcessAfterLoadFromCCB
{
	// apply the positionType, sizeType, scaleType properties here and only once
	if ([self respondsToSelector:@selector(setSize:)])
	{
		CGSize size = [self sizeFromSizeType];
		[(id)self setSize:size];
	}
	
	CCBReaderScaleType* scaleTypeObject = [self getAndRemoveUserDataObjectForKey:CCBReaderUserDataKeyForScaleType];
	if (scaleTypeObject.scaleType == CCScaleTypeScaled)
	{
		CGFloat scaleFactor = [CCDirector sharedDirector].UIScaleFactor;
		self.xScale *= scaleFactor;
		self.yScale *= scaleFactor;
	}

	self.position = [self positionFromPositionType];
	
	NSLog(@"%@ (%p)  size: {%.1f, %.1f} scale: {%.2f, %.2f}", NSStringFromClass([self class]), self,
		  [self respondsToSelector:@selector(setSize:)] ? [(id)self size].width : self.frame.size.width,
		  [self respondsToSelector:@selector(setSize:)] ? [(id)self size].height : self.frame.size.height, self.xScale, self.yScale);
}

#pragma mark Adjust Size based on sizeType

-(CGSize) contentSizeFromParent
{
	CGSize parentSize = CGSizeZero;
	
	if (self.parent)
	{
		if ([self.parent respondsToSelector:@selector(setSize:)])
		{
			parentSize = [(id)self.parent size];
		}
		else
		{
			parentSize = self.parent.frame.size;
		}
	}
	
	if (CGSizeEqualToSize(parentSize, CGSizeZero))
	{
		// if there's no parent (or parent's size is 0,0) assume "parent" to be scene sized
		parentSize = [CCBSpriteKitReader internal_getSceneSize];
	}
	
	return parentSize;
}

-(CGSize) sizeFromSizeType
{
	CCBReaderSizeType* sizeTypeObject = [self getAndRemoveUserDataObjectForKey:CCBReaderUserDataKeyForContentSizeType];
	if (sizeTypeObject)
	{
		CCSizeType sizeType = sizeTypeObject.sizeType;
		
		// change size once at load-time based on size type
		CGSize size = [(id)self size];
		CGSize newSize = CGSizeZero;
		
		switch (sizeType.widthUnit)
		{
			case CCSizeUnitPoints:
				newSize.width = size.width;
				break;
			case CCSizeUnitUIPoints:
				newSize.width = [CCDirector sharedDirector].UIScaleFactor * size.width;
				break;
			case CCSizeUnitNormalized:
				newSize.width = size.width * [self contentSizeFromParent].width;
				break;
			case CCSizeUnitInsetPoints:
				newSize.width = [self contentSizeFromParent].width - size.width;
				break;
			case CCSizeUnitInsetUIPoints:
				newSize.width = [self contentSizeFromParent].width - size.width * [CCDirector sharedDirector].UIScaleFactor;
				break;
				
			default:
				[NSException raise:NSInternalInconsistencyException format:@"unsupported contentSize unit type for width: %d", sizeType.widthUnit];
				break;
		}
		
		switch (sizeType.heightUnit)
		{
			case CCSizeUnitPoints:
				newSize.height = size.height;
				break;
			case CCSizeUnitUIPoints:
				newSize.height = [CCDirector sharedDirector].UIScaleFactor * size.height;
				break;
			case CCSizeUnitNormalized:
				newSize.height = size.height * [self contentSizeFromParent].height;
				break;
			case CCSizeUnitInsetPoints:
				newSize.height = [self contentSizeFromParent].height - size.height;
				break;
			case CCSizeUnitInsetUIPoints:
				newSize.height = [self contentSizeFromParent].height - size.height * [CCDirector sharedDirector].UIScaleFactor;
				break;
				
			default:
				[NSException raise:NSInternalInconsistencyException format:@"unsupported contentSize unit type for height: %d", sizeType.heightUnit];
				break;
		}
		
		return newSize;
	}
	
	return self.frame.size;
}

#pragma mark Adjust Position with positionType

-(CGPoint) positionFromPositionType
{
	CGPoint newPosition = self.position;
	CCBReaderPositionType* positionTypeObject = [self getAndRemoveUserDataObjectForKey:CCBReaderUserDataKeyForPositionType];

	if (positionTypeObject)
	{
		CCPositionType positionType = positionTypeObject.positionType;
		switch (positionType.xUnit)
		{
			case CCPositionUnitPoints:
				// no adjustment
				break;
			case CCPositionUnitUIPoints:
				newPosition.x *= [CCDirector sharedDirector].UIScaleFactor;
				break;
			case CCPositionUnitNormalized:
				newPosition.x *= [self contentSizeFromParent].width;
				break;
				
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
				newPosition.y *= [self contentSizeFromParent].height;
				break;
				
			default:
				[NSException raise:NSInternalInconsistencyException format:@"unsupported positionType for y: %d", positionType.yUnit];
				break;
		}
	}
	
	return newPosition;
}

@end
