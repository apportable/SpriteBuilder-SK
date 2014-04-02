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

@property (nonatomic) id userObject;
@property (nonatomic) CGFloat rotation;
@property (nonatomic) CGFloat skewX;
@property (nonatomic) CGFloat skewY;
@property (nonatomic) CGFloat scaleX;
@property (nonatomic) CGFloat scaleY;
@property (nonatomic) CGPoint scaleAsPoint;
@property (nonatomic) CGFloat opacity;
@property (nonatomic) SKTexture* spriteFrame;
@property (nonatomic) CGSize contentSize;
@property (nonatomic) CCSizeType contentSizeType;
@property (nonatomic) CCScaleType scaleType;
@property (nonatomic) CCPositionType positionType;
@property (nonatomic) BOOL visible;
@property (nonatomic) BOOL loadedFromCCB;

-(CGFloat) scale;
-(void) postProcessAfterLoadFromCCBWithRootNode:(SKNode*)rootNode;

-(CGPoint) convertToWorldSpace:(CGPoint)position;
-(CGPoint) convertToNodeSpace:(CGPoint)position;

/** Returns YES, if touch is inside sprite
 Added hit area expansion / contraction */
-(BOOL) hitTestWithWorldPosition:(CGPoint)pos;

-(CGPoint) convertPosition:(CGPoint)originalPosition positionType:(CCPositionType)positionType;
-(CGSize) convertSize:(CGSize)size sizeType:(CCSizeType)sizeType;
-(CGPoint) convertScaleX:(CGFloat)scaleX scaleY:(CGFloat)scaleY scaleType:(CCScaleType)scaleType;

@end
