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

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#define __CC_PLATFORM_IOS 1
#define SB_PLATFORM_IOS 1
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
#define __CC_PLATFORM_MAC 1
#define SB_PLATFORM_MAC 1
#endif

#define CC_DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) * 0.01745329252f) // PI / 180
#define CC_RADIANS_TO_DEGREES(__ANGLE__) ((__ANGLE__) * 57.29577951f) // PI * 180

#import <SpriteKit/SpriteKit.h>

#import "CCColor.h"
#import "CCFileUtils.h"
#import "CCSpriteFrameCache.h"
#import "CGPointExtension.h"
#import "CCBSpriteKitDummy.h"

#import "CCBCocosTypes.h"

#import "SKNode+CCBReader.h"
#import "SKPhysicsBody+CCBReader.h"
#import "SKTexture+CCBReader.h"
#import "SKAction+CCBReader.h"

#import "CCDirector.h"
#import "CCActionManager.h"
#import "CCActions.h"

#import "ccTypes.h"

// just forward all unsupported features to a dummy class to make the compiler happy
@class CCBSpriteKitDummy;
@class CCBSpriteKitDummyAction;

typedef CCBSpriteKitDummy OALSimpleAudio;

typedef CCBSpriteKitDummyAction CCAction;
typedef CCBSpriteKitDummyAction CCActionInterval;
typedef CCBSpriteKitDummyAction CCActionEase;
typedef CCBSpriteKitDummyAction CCActionEaseBackIn;
typedef CCBSpriteKitDummyAction CCActionEaseBackInOut;
typedef CCBSpriteKitDummyAction CCActionEaseBackOut;
typedef CCBSpriteKitDummyAction CCActionEaseBounceIn;
typedef CCBSpriteKitDummyAction CCActionEaseBounceInOut;
typedef CCBSpriteKitDummyAction CCActionEaseBounceOut;
typedef CCBSpriteKitDummyAction CCActionEaseElasticIn;
typedef CCBSpriteKitDummyAction CCActionEaseElasticInOut;
typedef CCBSpriteKitDummyAction CCActionEaseElasticOut;
typedef CCBSpriteKitDummyAction CCActionEaseIn;
typedef CCBSpriteKitDummyAction CCActionEaseInOut;
//typedef CCBSpriteKitDummy CCActionEaseInstant;
typedef CCBSpriteKitDummyAction CCActionEaseOut;
typedef CCBSpriteKitDummyAction CCActionFadeTo;
typedef CCBSpriteKitDummyAction CCActionHide;
typedef CCBSpriteKitDummyAction CCActionInstant;
typedef CCBSpriteKitDummyAction CCActionMoveTo;
typedef CCBSpriteKitDummyAction CCActionScaleTo;
//typedef CCBSpriteKitDummyAction CCActionSequence;
typedef CCBSpriteKitDummyAction CCActionShow;
typedef CCBSpriteKitDummyAction CCActionSkewTo;
typedef CCBSpriteKitDummyAction CCActionTintTo;
