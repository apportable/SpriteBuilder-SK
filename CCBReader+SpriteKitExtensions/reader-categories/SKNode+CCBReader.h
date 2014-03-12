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

#import <SpriteKit/SpriteKit.h>
#import "CCBSpriteKitCompatibility.h"

@interface SKNode (CCBReader)

@property id userObject;
@property CGFloat rotation;
@property CGFloat skewX;
@property CGFloat skewY;
@property CGFloat scaleX;
@property CGFloat scaleY;
@property BOOL visible;
@property SKTexture* spriteFrame;
@property CGSize contentSize;
@property CCSizeType contentSizeType;
@property CCScaleType scaleType;
@property CCPositionType positionType;

-(CGFloat) scale;
-(void) postProcessAfterLoadFromCCB;

-(CGPoint) convertToWorldSpace:(CGPoint)position;

@end
