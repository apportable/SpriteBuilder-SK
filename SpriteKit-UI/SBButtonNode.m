//
//  SBButton.m
//  SB+SpriteKit
//
//  Created by Steffen Itterheim on 12/03/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "SBButtonNode.h"
#import "SBControlNode_Private.h"
#import "CGPointExtension.h"
#import <objc/runtime.h>

#define SBFatFingerExpansion 70

@implementation SBButtonNode

+ (id) buttonWithTitle:(NSString*) title
{
    return [[SBButtonNode alloc] initWithTitle:title];
}

+ (id) buttonWithTitle:(NSString*) title fontName:(NSString*)fontName fontSize:(CGFloat)size
{
    return [[SBButtonNode alloc] initWithTitle:title fontName:fontName fontSize:size];
}

+ (id) buttonWithTitle:(NSString*) title spriteFrame:(CCSpriteFrame*) spriteFrame
{
    return [[SBButtonNode alloc] initWithTitle:title spriteFrame:spriteFrame];
}

+ (id) buttonWithTitle:(NSString*) title spriteFrame:(CCSpriteFrame*) spriteFrame highlightedSpriteFrame:(CCSpriteFrame*) highlighted disabledSpriteFrame:(CCSpriteFrame*) disabled
{
    return [[SBButtonNode alloc] initWithTitle:title spriteFrame:spriteFrame highlightedSpriteFrame: highlighted disabledSpriteFrame:disabled];
}

- (id) init
{
    return [self initWithTitle:@"" spriteFrame:nil];
}

- (id) initWithTitle:(NSString *)title
{
    self = [self initWithTitle:title spriteFrame:nil highlightedSpriteFrame:nil disabledSpriteFrame:nil];
    
    // Default properties for labels with only a title
    self.zoomWhenHighlighted = YES;
    
    return self;
}

- (id) initWithTitle:(NSString *)title fontName:(NSString*)fontName fontSize:(CGFloat)size
{
    self = [self initWithTitle:title];
    self.label.fontName = fontName;
    self.label.fontSize = size;
    
    return self;
}

- (id) initWithTitle:(NSString*) title spriteFrame:(CCSpriteFrame*) spriteFrame
{
    self = [self initWithTitle:title spriteFrame:spriteFrame highlightedSpriteFrame:nil disabledSpriteFrame:nil];
    
    // Setup default colors for when only one frame is used
    [self setBackgroundColor:[CCColor colorWithWhite:0.7 alpha:1] forState:SBControlStateHighlighted];
    [self setLabelColor:[CCColor colorWithWhite:0.7 alpha:1] forState:SBControlStateHighlighted];
    
    [self setBackgroundOpacity:0.5f forState:SBControlStateDisabled];
    [self setLabelOpacity:0.5f forState:SBControlStateDisabled];
    
    return self;
}

- (id) initWithTitle:(NSString*) title spriteFrame:(CCSpriteFrame*) spriteFrame highlightedSpriteFrame:(CCSpriteFrame*) highlighted disabledSpriteFrame:(CCSpriteFrame*) disabled
{
    self = [super init];
    if (!self) return nil;
    
	// FIXME: button anchorPoint
	//self.anchorPoint = ccp(0.5f, 0.5f);
    
    if (!title) title = @"";
    
    // Setup holders for properties
    _backgroundColors = [NSMutableDictionary dictionary];
    _backgroundOpacities = [NSMutableDictionary dictionary];
    _backgroundSpriteFrames = [NSMutableDictionary dictionary];
    
    _labelColors = [NSMutableDictionary dictionary];
    _labelOpacities = [NSMutableDictionary dictionary];

	// Setup label
    _label = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
	_label.text = title;
	_label.fontSize = 14;
	_label.fontColor = [SKColor blackColor];
	_label.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
	_label.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    
    // Setup background image
    if (spriteFrame)
    {
        _background = [SKSpriteNode spriteNodeWithTexture:spriteFrame];
        [self setBackgroundSpriteFrame:spriteFrame forState:SBControlStateNormal];
        self.preferredSize = spriteFrame.size;
    }
    else
    {
        _background = [SKSpriteNode spriteNodeWithColor:[SKColor whiteColor] size:_label.frame.size];
    }
    
    if (highlighted)
    {
        [self setBackgroundSpriteFrame:highlighted forState:SBControlStateHighlighted];
        [self setBackgroundSpriteFrame:highlighted forState:SBControlStateSelected];
    }
    
    if (disabled)
    {
        [self setBackgroundSpriteFrame:disabled forState:SBControlStateDisabled];
    }
    
    [self addChild:_background];
    [self addChild:_label];
    
    // Setup original scale
    _originalLabelScaleX = _originalLabelScaleY = 1;
    
    [self needsLayout];
    [self stateChanged];
    
    return self;
}

- (void) layout
{
	// must start with scaling at 1x1 so that size is correct
	_label.xScale = 1.0;
	_label.yScale = 1.0;
	
    CGSize originalLabelSize = _label.frame.size;
    CGSize paddedLabelSize = originalLabelSize;
    paddedLabelSize.width += _horizontalPadding * 2;
    paddedLabelSize.height += _verticalPadding * 2;
    
    BOOL shrunkSize = NO;
	// FIXME: size with type
	/*
    CGSize size = [self convertContentSizeToPoints: self.preferredSize type:self.contentSizeType];
    CGSize maxSize = [self convertContentSizeToPoints:self.maxSize type:self.contentSizeType];
	 */
    CGSize size = self.preferredSize;
    CGSize maxSize = self.maxSize;
    
    if (size.width < paddedLabelSize.width) size.width = paddedLabelSize.width;
    if (size.height < paddedLabelSize.height) size.height = paddedLabelSize.height;
    
    if (maxSize.width > 0 && maxSize.width < size.width)
    {
        size.width = maxSize.width;
        shrunkSize = YES;
    }
    if (maxSize.height > 0 && maxSize.height < size.height)
    {
        size.height = maxSize.height;
        shrunkSize = YES;
    }
    
    if (shrunkSize)
    {
		// FIXME: shrunkSize / label.dimension
		/**
        CGSize labelSize = CGSizeMake(clampf(size.width - _horizontalPadding * 2, 0, originalLabelSize.width),
                                      clampf(size.height - _verticalPadding * 2, 0, originalLabelSize.height));
        _label.dimensions = labelSize;
		 */
		
		// must change the label's scale
		_label.xScale = self.maxSize.width / paddedLabelSize.width;
		//_label.yScale = self.maxSize.height / paddedLabelSize.height;
		_originalLabelScaleX = _label.xScale;
		//_originalLabelScaleY = _label.yScale;
    }
    
    _background.anchorPoint = ccp(0.5f,0.5f);
    _background.positionType = CCPositionTypeMake(CCPositionUnitNormalized, CCPositionUnitNormalized, CCPositionReferenceCornerBottomLeft);
    _background.position = ccp(0.5f,0.5f);

	[self updateBackgroundSlice];
	
    _label.positionType = CCPositionTypeMake(CCPositionUnitNormalized, CCPositionUnitNormalized, CCPositionReferenceCornerBottomLeft);
    _label.position = ccp(0.5f, 0.5f);
    
	// FIXME: contentSize with type
	//self.contentSize = [self convertContentSizeFromPoints: size type:self.contentSizeType];
    
    [super layout];
}

-(void) updateBackgroundSlice
{
	// set bg scale based on label size because Sprite Kit's "9 slice" works in conjunction with scale, not size
	CGSize labelSize = _label.frame.size;
	labelSize.width += _horizontalPadding * 2.0;
	labelSize.height += _verticalPadding * 2.0;
	_background.size = labelSize;
	_background.xScale = labelSize.width / _background.texture.size.width;
	_background.yScale = labelSize.height / _background.texture.size.height;
	_background.centerRect = CGRectMake(0.33, 0.33, 0.33, 0.33);
}

#ifdef __CC_PLATFORM_IOS

- (void) touchEntered:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (!self.enabled)
    {
        return;
    }
    
	// FIXME: claimsUserInteraction
	/*
    if (self.claimsUserInteraction)
    {
        [super setHitAreaExpansion:_originalHitAreaExpansion + SBFatFingerExpansion];
    }
	 */
    self.highlighted = YES;
}

- (void) touchExited:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.highlighted = NO;
}

- (void) touchUpInside:(UITouch *)touch withEvent:(UIEvent *)event
{
	// FIXME: hit area expansion
    //[super setHitAreaExpansion:_originalHitAreaExpansion];
    
    if (self.enabled)
    {
        [self triggerAction];
    }
    
    self.highlighted = NO;
}

- (void) touchUpOutside:(UITouch *)touch withEvent:(UIEvent *)event
{
	// FIXME: hit area expansion
	//[super setHitAreaExpansion:_originalHitAreaExpansion];
    self.highlighted = NO;
}

#elif __CC_PLATFORM_MAC

- (void) mouseDownEntered:(NSEvent *)event
{
    if (!self.enabled)
    {
        return;
    }
    self.highlighted = YES;
}

- (void) mouseDownExited:(NSEvent *)event
{
    self.highlighted = NO;
}

- (void) mouseUpInside:(NSEvent *)event
{
    if (self.enabled)
    {
        [self triggerAction];
    }
    self.highlighted = NO;
}

- (void) mouseUpOutside:(NSEvent *)event
{
    self.highlighted = NO;
}

#endif

- (void) triggerAction
{
    // Handle toggle buttons
    if (self.togglesSelectedState)
    {
        self.selected = !self.selected;
    }
    
    [super triggerAction];
}

- (void) updatePropertiesForState:(SBControlState)state
{
    // Update background
    _background.color = [self backgroundColorForState:state].skColor;
    _background.alpha = [self backgroundOpacityForState:state];
    
    CCSpriteFrame* spriteFrame = [self backgroundSpriteFrameForState:state];
	if (spriteFrame == nil)
	{
		spriteFrame = [self backgroundSpriteFrameForState:SBControlStateNormal];
	}
	//NSLog(@"button sprite frame: %@ for state %d", [spriteFrame debugDescription], (int)state);
	
    _background.spriteFrame = spriteFrame;
	
    // Update label
    _label.fontColor = [self labelColorForState:state].skColor;
    _label.alpha = [self labelOpacityForState:state];

	[self updateBackgroundSlice];

    [self needsLayout];
}

-(void) applyOriginalScale
{
	_label.scaleX = _originalLabelScaleX;
	_label.scaleY = _originalLabelScaleY;
	//_background.scaleX = _originalScaleX;
	//_background.scaleY = _originalScaleY;
	
	[self updateBackgroundSlice];
}

- (void) stateChanged
{
    if (self.enabled)
    {
        // Button is enabled
        if (self.highlighted)
        {
            [self updatePropertiesForState:SBControlStateHighlighted];
            
            if (_zoomWhenHighlighted)
            {
				[self applyOriginalScale];
				[_label runAction:[SKAction scaleXTo:_originalLabelScaleX * 1.1 y:_originalLabelScaleY * 1.1 duration:0.1] withKey:@"zoomWhenHighlighted"];
				[_background runAction:[SKAction scaleXTo:_background.scaleX * 1.1 y:_background.scaleY * 1.1 duration:0.1] withKey:@"zoomWhenHighlighted"];
            }
        }
        else
        {
            if (self.selected)
            {
                [self updatePropertiesForState:SBControlStateSelected];
            }
            else
            {
                [self updatePropertiesForState:SBControlStateNormal];
            }
            
            [_label removeAllActions];
			[_background removeAllActions];
            if (_zoomWhenHighlighted)
            {
				[self applyOriginalScale];
            }
        }
    }
    else
    {
        // Button is disabled
        [self updatePropertiesForState:SBControlStateDisabled];
    }
}

#pragma mark Properties

- (void) setHitAreaExpansion:(CGFloat)hitAreaExpansion
{
    _originalHitAreaExpansion = hitAreaExpansion;
	// FIXME: hit area expansion
	//[super hitAreaExpansion];
}

- (CGFloat) hitAreaExpansion
{
    return _originalHitAreaExpansion;
}

- (void)setColor:(CCColor *)color {
    [self setLabelColor:color forState:SBControlStateNormal];
}

- (void) setLabelColor:(CCColor*)color forState:(SBControlState)state
{
    [_labelColors setObject:color forKey:[NSNumber numberWithInt:state]];
    [self stateChanged];
}

- (CCColor*) labelColorForState:(SBControlState)state
{
    CCColor* color = [_labelColors objectForKey:[NSNumber numberWithInt:state]];
    if (!color) color = [CCColor whiteColor];
    return color;
}

- (void) setLabelOpacity:(CGFloat)opacity forState:(SBControlState)state
{
    [_labelOpacities setObject:[NSNumber numberWithDouble:opacity] forKey:[NSNumber numberWithInt:state]];
    [self stateChanged];
}

- (CGFloat) labelOpacityForState:(SBControlState)state
{
    NSNumber* val = [_labelOpacities objectForKey:[NSNumber numberWithInt:state]];
    if (!val) return 1;
    return [val doubleValue];
}

- (void) setBackgroundColor:(CCColor*)color forState:(SBControlState)state
{
    [_backgroundColors setObject:color forKey:[NSNumber numberWithInt:state]];
    [self stateChanged];
}

- (CCColor*) backgroundColorForState:(SBControlState)state
{
    CCColor* color = [_backgroundColors objectForKey:[NSNumber numberWithInt:state]];
    if (!color) color = [CCColor whiteColor];
    return color;
}

- (void) setBackgroundOpacity:(CGFloat)opacity forState:(SBControlState)state
{
    [_backgroundOpacities setObject:[NSNumber numberWithDouble:opacity] forKey:[NSNumber numberWithInt:state]];
    [self stateChanged];
}

- (CGFloat) backgroundOpacityForState:(SBControlState)state
{
    NSNumber* val = [_backgroundOpacities objectForKey:[NSNumber numberWithInt:state]];
    if (!val) return 1.0;
    return [val doubleValue];
}

- (void) setBackgroundSpriteFrame:(CCSpriteFrame*)spriteFrame forState:(SBControlState)state
{
    if (spriteFrame)
    {
        [_backgroundSpriteFrames setObject:spriteFrame forKey:[NSNumber numberWithInt:state]];
    }
    else
    {
        [_backgroundSpriteFrames removeObjectForKey:[NSNumber numberWithInt:state]];
    }
    [self stateChanged];
}

- (CCSpriteFrame*) backgroundSpriteFrameForState:(SBControlState)state
{
    return [_backgroundSpriteFrames objectForKey:[NSNumber numberWithInt:state]];
}

- (void) setTitle:(NSString *)title
{
    _label.string = title;
    [self needsLayout];
}

- (NSString*) title
{
    return _label.string;
}

- (void) setHorizontalPadding:(CGFloat)horizontalPadding
{
    _horizontalPadding = horizontalPadding;
    [self needsLayout];
}

- (void) setVerticalPadding:(CGFloat)verticalPadding
{
    _verticalPadding = verticalPadding;
    [self needsLayout];
}

- (NSArray*) keysForwardedToLabel
{
    return [NSArray arrayWithObjects:
            @"fontName",
            @"fontSize",
            @"fontColor",
            @"alpha",
            @"color",
            @"colorBlendFactor",
            @"text",
            nil];
}

- (void) setValue:(id)value forKey:(NSString *)key
{
    if ([[self keysForwardedToLabel] containsObject:key])
    {
        [_label setValue:value forKey:key];
        [self needsLayout];
        return;
    }
    [super setValue:value forKey:key];
}

- (id) valueForKey:(NSString *)key
{
    if ([[self keysForwardedToLabel] containsObject:key])
    {
        return [_label valueForKey:key];
    }
    return [super valueForKey:key];
}

- (void) setValue:(id)value forKey:(NSString *)key state:(SBControlState)state
{
    if ([key isEqualToString:@"labelOpacity"])
    {
        [self setLabelOpacity:[value doubleValue] forState:state];
    }
    else if ([key isEqualToString:@"labelColor"])
    {
        [self setLabelColor:value forState:state];
    }
    else if ([key isEqualToString:@"backgroundOpacity"])
    {
        [self setBackgroundOpacity:[value doubleValue] forState:state];
    }
    else if ([key isEqualToString:@"backgroundColor"])
    {
        [self setBackgroundColor:value forState:state];
    }
    else if ([key isEqualToString:@"backgroundSpriteFrame"])
    {
        [self setBackgroundSpriteFrame:value forState:state];
    }
}

- (id) valueForKey:(NSString *)key state:(SBControlState)state
{
    if ([key isEqualToString:@"labelOpacity"])
    {
        return [NSNumber numberWithDouble:[self labelOpacityForState:state]];
    }
    else if ([key isEqualToString:@"labelColor"])
    {
        return [self labelColorForState:state];
    }
    else if ([key isEqualToString:@"backgroundOpacity"])
    {
        return [NSNumber numberWithDouble:[self backgroundOpacityForState:state]];
    }
    else if ([key isEqualToString:@"backgroundColor"])
    {
        return [self backgroundColorForState:state];
    }
    else if ([key isEqualToString:@"backgroundSpriteFrame"])
    {
        return [self backgroundSpriteFrameForState:state];
    }
    
    return nil;
}

@end
