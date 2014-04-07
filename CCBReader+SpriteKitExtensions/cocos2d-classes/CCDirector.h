//
//  CCDirector.h
//  SB+KoboldKit
//
//  Created by Steffen Itterheim on 19/02/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CCActionManager;
@class KKView;

@interface CCDirector : NSObject
{
	@private
	CGSize _designSize;
}

+(instancetype) sharedDirector;
@property (nonatomic) CCActionManager* actionManager;
@property (nonatomic, readonly) KKView* view;
@property (nonatomic) CGSize designSize;
@property (nonatomic) CGFloat UIScaleFactor;
@property (nonatomic) CGFloat contentScaleFactor;
@property (nonatomic) CGFloat iPadLabelScaleFactor;

@end
