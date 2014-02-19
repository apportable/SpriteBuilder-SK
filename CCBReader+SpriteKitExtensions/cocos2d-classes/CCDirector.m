//
//  CCDirector.m
//  SB+KoboldKit
//
//  Created by Steffen Itterheim on 19/02/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCDirector.h"
#import "CCActionManager.h"
#import "KKView.h"

@implementation CCDirector

+(instancetype) sharedDirector
{
	static CCDirector* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CCDirector alloc] init];
		sharedInstance.actionManager = [[CCActionManager alloc] init];
    });
    return sharedInstance;
}

-(CGFloat) UIScaleFactor
{
	return 1.0;
}

@dynamic designSize;
-(void) setDesignSize:(CGSize)designSize
{
	[KKView defaultView].designSize = designSize;
}
-(CGSize) designSize
{
	return [KKView defaultView].designSize;
}

@dynamic view;
-(KKView*) view
{
	return [KKView defaultView];
}

@end