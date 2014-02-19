//
//  SKAction+CCBReader.h
//  SB+KoboldKit
//
//  Created by Steffen Itterheim on 19/02/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

enum {
	//! Default tag
	CCActionTagInvalid = -1,
};

@interface SKAction (CCBReader)

@property (nonatomic) int tag;

-(int) getAndClearTag;

@end
