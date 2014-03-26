//
//  CCBSpriteKitAnimationManager.m
//  SB+KoboldKit
//
//  Created by Steffen Itterheim on 19/02/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCBSpriteKitAnimationManager.h"
#import "CCBKeyframe.h"
#import "CCBReader_Private.h"

@implementation CCBSpriteKitAnimationManager

-(CCActionInterval*) actionFromKeyframe0:(CCBKeyframe*)kf0 andKeyframe1:(CCBKeyframe*)kf1 propertyName:(NSString*)name node:(CCNode*)node
{
    CGFloat duration = kf1.time - kf0.time;
	SKAction* action = nil;
    
    if ([name isEqualToString:@"rotation"] || [name isEqualToString:@"rotationX"] || [name isEqualToString:@"rotationY"])
    {
		action = [SKAction rotateToAngle:CC_DEGREES_TO_RADIANS([kf1.value doubleValue] * -1.0) duration:duration];
    }
	else if ([name isEqualToString:@"position"])
    {
        id value = kf1.value;
        
        // Get relative position
        CGFloat x = [[value objectAtIndex:0] doubleValue];
        CGFloat y = [[value objectAtIndex:1] doubleValue];
        
		CGPoint absolutePosition = [node convertPosition:CGPointMake(x, y) withPositionType:node.positionType];
        action = [SKAction moveTo:absolutePosition duration:duration];
    }
    else if ([name isEqualToString:@"scale"])
    {
        // Get position type
        //int type = [[[self baseValueForNode:node propertyName:name] objectAtIndex:2] intValue];
        
        id value = kf1.value;
        
        // Get relative scale
        CGFloat x = [[value objectAtIndex:0] doubleValue];
        CGFloat y = [[value objectAtIndex:1] doubleValue];
        
        action = [SKAction scaleXTo:x y:y duration:duration];
    }
    else if ([name isEqualToString:@"alpha"] || [name isEqualToString:@"opacity"])
    {
		CGFloat alpha = [kf1.value doubleValue];
		action = [SKAction fadeAlphaTo:alpha duration:duration];
    }
    else if ([name isEqualToString:@"color"])
    {
        CCColor* color = kf1.value;
		action = [SKAction colorizeWithColor:[color skColor] colorBlendFactor:1.0 duration:duration];
    }
    else if ([name isEqualToString:@"visible"])
    {
		BOOL visible = [kf1.value boolValue];
		id showHide = [SKAction runBlock:^{
			node.hidden = !visible;
		}];
		action = [SKAction sequence:@[[SKAction waitForDuration:duration], showHide]];
    }
    else if ([name isEqualToString:@"spriteFrame"])
    {
		SKTexture* spriteFrame = kf1.value;
		SKSpriteNode* sprite = (SKSpriteNode*)node;
		NSAssert1([sprite isKindOfClass:[SKSpriteNode class]], @"CCBReader: can't change texture (spriteFrame animation), node %@ is not a sprite!", node);

		id changeTexture = [SKAction runBlock:^{
			sprite.texture = spriteFrame;
		}];
		action = [SKAction sequence:@[[SKAction waitForDuration:duration], changeTexture]];
    }
    else if ([name isEqualToString:@"skew"])
    {
		[NSException raise:NSInvalidArgumentException format:@"CCBReader: Sprite Kit does not support 'skew' actions (used by node: %@)", node];
    }
	else
	{
		[NSException raise:NSInvalidArgumentException format:@"CCBReader: Failed to create action for property: %@ on node: %@", name, node];
	}

    return (CCActionInterval*)action;
}

-(CCActionInterval*) easeAction:(CCActionInterval*)action easingType:(int)easingType easingOpt:(CGFloat)easingOpt
{
	SKAction* skAction = (SKAction*)action;
	NSAssert2([skAction isKindOfClass:[SKAction class]], @"object %@ (%@) is not a SKAction", action, NSStringFromClass([action class]));
	
	switch (easingType)
	{
		case kCCBKeyframeEasingLinear:
		case kCCBKeyframeEasingInstant:
			skAction.timingMode = SKActionTimingLinear;
			break;
			
		case kCCBKeyframeEasingCubicIn:
		case kCCBKeyframeEasingBackIn:
		case kCCBKeyframeEasingBounceIn:
		case kCCBKeyframeEasingElasticIn:
			skAction.timingMode = SKActionTimingEaseIn;
			break;
		case kCCBKeyframeEasingCubicOut:
		case kCCBKeyframeEasingBackOut:
		case kCCBKeyframeEasingBounceOut:
		case kCCBKeyframeEasingElasticOut:
			skAction.timingMode = SKActionTimingEaseOut;
			break;
		case kCCBKeyframeEasingCubicInOut:
		case kCCBKeyframeEasingBackInOut:
		case kCCBKeyframeEasingBounceInOut:
		case kCCBKeyframeEasingElasticInOut:
			skAction.timingMode = SKActionTimingEaseInEaseOut;
			break;
			
		default:
			NSLog(@"CCBSpriteKitAnimationManager: unkown action easing type %d", easingType);
			break;
	}
	
	return (CCActionInterval*)skAction;
}

-(void) removeActionsByTag:(NSInteger)tag fromNode:(CCNode*)node
{
	[node removeAllActions];
}

@end

