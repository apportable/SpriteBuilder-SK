//
//  CCActionManager.h
//  SB+KoboldKit
//
//  Created by Steffen Itterheim on 19/02/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface CCActionManager : NSObject

-(SKAction*) getActionByTag:(int)tag target:(id)target;
-(void) removeActionByTag:(int)tag target:(id)target;

@end
