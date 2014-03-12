//
//  SBButton.h
//  SB+SpriteKit
//
//  Created by Steffen Itterheim on 12/03/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "SBControlNode.h"
#import "ccTypes.h"

/**
 The CCButton represents a button on the screen. The button is presented with a stretchable background image and/or a title label. Different images, colors and opacity can be set for each of the buttons different states.
 
 Methods for setting callbacks for the button is inherited from SBControl through the setTarget:selector: method or the block property.
 */
@interface SBButtonNode : SBControlNode
{
    NSMutableDictionary* _backgroundSpriteFrames;
    NSMutableDictionary* _backgroundColors;
    NSMutableDictionary* _backgroundOpacities;
    NSMutableDictionary* _labelColors;
    NSMutableDictionary* _labelOpacities;
	CGFloat _originalScaleX;
	CGFloat _originalScaleY;
    
	CGFloat _originalHitAreaExpansion;
}

@property (nonatomic, copy) NSString* title;
@property (nonatomic, readonly) SKSpriteNode* background;
@property (nonatomic, readonly) SKLabelNode* label;
@property (nonatomic) CGFloat horizontalPadding;
@property (nonatomic) CGFloat verticalPadding;
@property (nonatomic) BOOL togglesSelectedState;
@property (nonatomic) BOOL zoomWhenHighlighted;

/// -----------------------------------------------------------------------
/// @name Creating Buttons
/// -----------------------------------------------------------------------

/**
 *  Creates a new button with a title and no background. Uses default font and font size.
 *
 *  @param title The title text of the button.
 *
 *  @return A new button.
 */
+ (id) buttonWithTitle:(NSString*) title;

/**
 *  Creates a new button with a title and no background.
 *
 *  @param title    The title text of the button.
 *  @param fontName Name of the TTF font to use for the title label.
 *  @param size     Font size for the title label.
 *
 *  @return A new button.
 */
+ (id) buttonWithTitle:(NSString*) title fontName:(NSString*)fontName fontSize:(CGFloat)size;

/**
 *  Creates a new button with the specified title for the label and sprite frame for its background.
 *
 *  @param title       The title text of the button.
 *  @param spriteFrame Stretchable background image.
 *
 *  @return A new button.
 */
+ (id) buttonWithTitle:(NSString*) title spriteFrame:(CCSpriteFrame*) spriteFrame;

/**
 *  Creates a new button with the speicified title for the label, sprite frames for its background in different states.
 *
 *  @param title       The title text of the button.
 *  @param spriteFrame Stretchable background image for the normal state.
 *  @param highlighted Stretchable background image for the highlighted state.
 *  @param disabled    Stretchable background image for the disabled state.
 *
 *  @return A new button.
 */
+ (id) buttonWithTitle:(NSString*) title spriteFrame:(CCSpriteFrame*) spriteFrame highlightedSpriteFrame:(CCSpriteFrame*) highlighted disabledSpriteFrame:(CCSpriteFrame*) disabled;

/**
 *  Sets the background color for the specified state. The color is multiplied into the background sprite frame.
 *
 *  @param color Color applied to background image.
 *  @param state State to apply the color to.
 */
- (void) setBackgroundColor:(CCColor*) color forState:(SBControlState) state;

/**
 *  Gets the background color for the specified state.
 *
 *  @param state State to get the color for.
 *
 *  @return Background color.
 */
- (CCColor*) backgroundColorForState:(SBControlState)state;

/**
 *  Sets the background's opacity for the specified state.
 *
 *  @param opacity Opacity to apply to the background image
 *  @param state   State to apply the opacity to.
 */
- (void) setBackgroundOpacity:(CGFloat) opacity forState:(SBControlState) state;

/**
 *  Gets the background opacity for the specified state.
 *
 *  @param state State to get the opacity for.
 *
 *  @return Opacity.
 */
- (CGFloat) backgroundOpacityForState:(SBControlState)state;

/**
 *  Will set the label's color for the normal state.
 *
 *  @param color Color applied to the label.
 */
- (void) setColor:(CCColor *)color;

/**
 *  Sets the label's color for the specified state.
 *
 *  @param color Color applied to the label.
 *  @param state State to set the color for.
 */
- (void) setLabelColor:(CCColor*) color forState:(SBControlState) state;

/**
 *  Gets the label's color for the specified state.
 *
 *  @param state State to get the color for.
 *
 *  @return Label color.
 */
- (CCColor*) labelColorForState:(SBControlState) state;

/**
 *  Sets the label's opacity for the specified state.
 *
 *  @param opacity Opacity applied to the label.
 *  @param state   State to set the opacity for.
 */
- (void) setLabelOpacity:(CGFloat) opacity forState:(SBControlState) state;

/**
 *  Gets the label's opacity for the specified state.
 *
 *  @param state State to get the opacity for.
 *
 *  @return Label opacity.
 */
- (CGFloat) labelOpacityForState:(SBControlState) state;

/**
 *  Sets the background's sprite frame for the specified state. The sprite frame will be stretched to the preferred size of the label. If set to `nil` no background will be drawn.
 *
 *  @param spriteFrame Sprite frame to use for drawing the background.
 *  @param state       State to set the background for.
 */
- (void) setBackgroundSpriteFrame:(CCSpriteFrame*)spriteFrame forState:(SBControlState)state;

/**
 *  Gets the background's sprite frame for the specified state.
 *
 *  @param state State to get the sprite frame for.
 *
 *  @return Background sprite frame.
 */
- (CCSpriteFrame*) backgroundSpriteFrameForState:(SBControlState)state;

@end
