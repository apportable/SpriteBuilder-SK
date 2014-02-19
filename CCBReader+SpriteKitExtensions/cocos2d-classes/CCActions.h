//
//  CCActions.h
//  SB+KoboldKit
//
//  Created by Steffen Itterheim on 19/02/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>


@interface CCActionSequence : SKAction
+(id) actionOne:(id)anAction two:(id)anotherAction;
+(id) actionWithArray:(NSArray*)actions;
@end



@interface CCActionDelay : SKAction
+(id) actionWithDuration:(CGFloat)duration;
@end



@interface CCActionCallFunc : SKAction
+(id) actionWithTarget:(id)target selector:(SEL)selector;
@end