//
//  FappulousScene.h
//  RealWorldTestProject
//
//  Created by Steffen Itterheim on 19/03/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface FlappulousScene : SKScene
{
	@private
	NSArray* _badWords;
	NSArray* _goodWords;
	NSString* _currentWord;
	NSInteger _score;
	NSTimeInterval _lastWordUpdate;
}

@end
