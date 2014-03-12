//
//  SBControl.m
//  SB+SpriteKit
//
//  Created by Steffen Itterheim on 12/03/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "SBControlNode.h"
#import "SBControlNode_Private.h"
#import "SKNode+CCBReader.h"

#import <objc/objc-runtime.h>

@implementation SBControlNode


#pragma mark Initializers

- (id) init
{
    self = [super init];
    if (!self) return nil;
    
    self.userInteractionEnabled = YES;
	
	// FIXME: how is this implemented in CC and how can it be emulated in SK?
	//self.exclusiveTouch = YES;
    
    return self;
}

-(NSString*) description
{
	return [NSString stringWithFormat:@"<%@, %p> %@", NSStringFromClass([self class]), self, [super description]];
}

#pragma mark Action handling

- (void) setTarget:(id)target selector:(SEL)selector
{
    __weak id weakTarget = target; // avoid retain cycle
    [self setRunBlock:^(id sender) {
        typedef void (*Func)(id, SEL, id);
        ((Func)objc_msgSend)(weakTarget, selector, sender);
	}];
}

- (void) triggerAction
{
    if (self.enabled && _runBlock)
    {
        _runBlock(self);
    }
}

#pragma mark Touch handling

#if TARGET_OS_IPHONE

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self touchBegan:touches.anyObject withEvent:event];
}
-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self touchMoved:touches.anyObject withEvent:event];
}
-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self touchEnded:touches.anyObject withEvent:event];
}
-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self touchCancelled:touches.anyObject withEvent:event];
}

- (void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    _tracking = YES;
    _touchInside = YES;
    
    [self touchEntered:touch withEvent:event];
}

- (void) touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    if ([self hitTestWithWorldPosition:[touch locationInNode:self.scene]])
    {
        if (!_touchInside)
        {
            [self touchEntered:touch withEvent:event];
            _touchInside = YES;
        }
    }
    else
    {
        if (_touchInside)
        {
            [self touchExited:touch withEvent:event];
            _touchInside = NO;
        }
    }
}

- (void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (_touchInside)
    {
        [self touchUpInside:touch withEvent:event];
    }
    else
    {
        [self touchUpOutside:touch withEvent:event];
    }
    
    _touchInside = NO;
    _tracking = NO;
}

- (void) touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (_touchInside)
    {
        [self touchUpOutside:touch withEvent:event];
        [self touchExited:touch withEvent:event];
    }
    
    _touchInside = NO;
    _tracking = NO;
}

- (void) touchEntered:(UITouch*) touch withEvent:(UIEvent*)event
{}

- (void) touchExited:(UITouch*) touch withEvent:(UIEvent*) event
{}

- (void) touchUpInside:(UITouch*) touch withEvent:(UIEvent*) event
{}

- (void) touchUpOutside:(UITouch*) touch withEvent:(UIEvent*) event
{}

#elif TARGET_OS_MAC

- (void) mouseDown:(NSEvent *)event
{
    _tracking = YES;
    _touchInside = YES;
    
    [self mouseDownEntered:event];
}

- (void) mouseDragged:(NSEvent *)event
{
    if ([self hitTestWithWorldPos:[event locationInWorld]])
    {
        if (!_touchInside)
        {
            [self mouseDownEntered:event];
            _touchInside = YES;
        }
    }
    else
    {
        if (_touchInside)
        {
            [self mouseDownExited:event];
            _touchInside = NO;
        }
    }
}

- (void) mouseUp:(NSEvent *)event
{
    if (_touchInside)
    {
        [self mouseUpInside:event];
    }
    else
    {
        [self mouseUpOutside:event];
    }
    
    _touchInside = NO;
    _tracking = NO;
}

- (void) mouseDownEntered:(NSEvent*) event
{}

- (void) mouseDownExited:(NSEvent*) event
{}

- (void) mouseUpInside:(NSEvent*) event
{}

- (void) mouseUpOutside:(NSEvent*) event
{}

#endif


#pragma mark State properties

- (BOOL) enabled
{
    if (!(_state & SBControlStateDisabled)) return YES;
    else return NO;
}

- (void) setEnabled:(BOOL)enabled
{
    if (self.enabled == enabled) return;
    
    BOOL disabled = !enabled;
    
    if (disabled)
    {
        _state |= SBControlStateDisabled;
    }
    else
    {
        _state &= ~SBControlStateDisabled;
    }
    
    [self stateChanged];
}

- (BOOL) selected
{
    if (_state & SBControlStateSelected) return YES;
    else return NO;
}

- (void) setSelected:(BOOL)selected
{
    if (self.selected == selected) return;
    
    if (selected)
    {
        _state |= SBControlStateSelected;
    }
    else
    {
        _state &= ~SBControlStateSelected;
    }
    
    [self stateChanged];
}

- (BOOL) highlighted
{
    if (_state & SBControlStateHighlighted) return YES;
    else return NO;
}

- (void) setHighlighted:(BOOL)highlighted
{
    if (self.highlighted == highlighted) return;
    
    if (highlighted)
    {
        _state |= SBControlStateHighlighted;
    }
    else
    {
        _state &= ~SBControlStateHighlighted;
    }
    
    [self stateChanged];
}

#pragma mark Layout and state changes

- (void) stateChanged
{
    [self needsLayout];
}

- (void) needsLayout
{
    _needsLayout = YES;
}

- (void) layout
{
    _needsLayout = NO;
}

// FIXME: visit (update?)
/*
- (void) visit
{
    if (_needsLayout) [self layout];
    [super visit];
}
 */

- (CGSize) contentSize
{
    if (_needsLayout) [self layout];
    return [super contentSize];
}

// FIXME: onEnter
/*
- (void) onEnter
{
    [self needsLayout];
    [super onEnter];
}
*/

- (void) setContentSizeType:(CCSizeType)contentSizeType
{
    [super setContentSizeType:contentSizeType];
    [self needsLayout];
}

- (void) setPreferredSize:(CGSize)preferredSize
{
    _preferredSize = preferredSize;
    [self needsLayout];
}

- (void) setMaxSize:(CGSize)maxSize
{
    _maxSize = maxSize;
    [self needsLayout];
}

- (void) setPreferredSizeType:(CCSizeType)preferredSizeType
{
    self.contentSizeType = preferredSizeType;
}

- (CCSizeType) preferredSizeType
{
    return self.contentSizeType;
}

- (void) setMaxSizeType:(CCSizeType)maxSizeType
{
    self.contentSizeType = maxSizeType;
}

- (CCSizeType) maxSizeType
{
    return self.contentSizeType;
}


#pragma mark Setting properties for control states by name

- (SBControlState) controlStateFromString:(NSString*)stateName
{
    SBControlState state = 0;
    if ([stateName isEqualToString:@"Normal"]) state = SBControlStateNormal;
    else if ([stateName isEqualToString:@"Highlighted"]) state = SBControlStateHighlighted;
    else if ([stateName isEqualToString:@"Disabled"]) state = SBControlStateDisabled;
    else if ([stateName isEqualToString:@"Selected"]) state = SBControlStateSelected;
    
    return state;
}

- (void) setValue:(id)value forKey:(NSString *)key state:(SBControlState) state
{
}

- (id) valueForKey:(NSString *)key state:(SBControlState)state
{
    return nil;
}

- (void) setValue:(id)value forKey:(NSString *)key
{
    NSRange separatorRange = [key rangeOfString:@"|"];
    NSUInteger separatorLoc = separatorRange.location;
    
    if (separatorLoc == NSNotFound)
    {
        [super setValue:value forKey:key];
        return;
    }
    
    NSString* propName = [key substringToIndex:separatorLoc];
    NSString* stateName = [key substringFromIndex:separatorLoc+1];
    
    SBControlState state = [self controlStateFromString:stateName];
    
    [self setValue:value forKey:propName state:state];
}

- (id) valueForKey:(NSString *)key
{
    NSRange separatorRange = [key rangeOfString:@"|"];
    NSUInteger separatorLoc = separatorRange.location;
    
    if (separatorLoc == NSNotFound)
    {
        return [super valueForKey:key];
    }
    
    NSString* propName = [key substringToIndex:separatorLoc];
    NSString* stateName = [key substringFromIndex:separatorLoc+1];
    
    SBControlState state = [self controlStateFromString:stateName];
    
    return [self valueForKey:propName state:state];
}

@end
