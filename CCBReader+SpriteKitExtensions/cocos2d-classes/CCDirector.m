//
//  CCDirector.m
//  SB+KoboldKit
//
//  Created by Steffen Itterheim on 19/02/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCDirector.h"
#import "CCActionManager.h"
#import "CCBReader.h"
#import "CCBSpriteKitReader.h"

@implementation CCDirector

+(instancetype) sharedDirector
{
	static CCDirector* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CCDirector alloc] init];
		sharedInstance.actionManager = [[CCActionManager alloc] init];
		sharedInstance.UIScaleFactor = 1.0;
		sharedInstance.contentScaleFactor = 1.0; // [UIScreen mainScreen].scale
		sharedInstance.allowedOrientations = UIInterfaceOrientationMaskAllButUpsideDown;
    });
    return sharedInstance;
}

@dynamic designSize;
-(void) setDesignSize:(CGSize)designSize
{
	NSLog(@"CCBReader: design size is {%.1f, %.1f}", designSize.width, designSize.height);
	_designSize = designSize;
}
-(CGSize) designSize
{
	// as long as design size isn't set, assume design size equals scene size
	if (CGSizeEqualToSize(_designSize, CGSizeZero))
	{
		CGSize sceneSize = [CCBSpriteKitReader internal_getSceneSize];
		return sceneSize;
	}
	
	return _designSize;
}

@dynamic view;
-(SKView*) view
{
	UIView* view = [UIApplication sharedApplication].keyWindow.rootViewController.view;
	NSAssert2([view isKindOfClass:[SKView class]],
			  @"The [UIApplication sharedApplication].keyWindow.rootViewController.view is not a SKView instance, its class is %@ (%@)",
			  NSStringFromClass([view class]), view);
	return (SKView*)view;
}

@end
