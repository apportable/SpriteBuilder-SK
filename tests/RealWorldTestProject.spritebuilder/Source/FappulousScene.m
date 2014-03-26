//
//  FappulousScene.m
//  RealWorldTestProject
//
//  Created by Steffen Itterheim on 19/03/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FappulousScene.h"

@implementation FappulousScene

-(void) didLoadFromCCB
{
	NSLog(@"didLoadFromCCB: %p - %@", self, self);
}

-(void) readerDidLoadSelf
{
	NSLog(@"readerDidLoadSelf: %p - %@", self, self);
	
	//_badWords = @[@"Candy", @"Saga", @"Edge", @"Paper", @"Flappy", @"Doodle", @"Memory", @"Scroll", @"Aperture", @"iCal", @"Keynote", @"Logic", @"Numbers", @"Pages", @"Sherlock"];
	//_goodWords = @[@"pea", @"penguin", @"brave", @"duck", @"carrot", @"corner", @"sage", @"sawtooth", @"cuboid", @"octopus", @"boring", @"clash", @"illogical", @"ball", @"mind"];
	_badWords = @[@"frown", @"no", @"hurt", @"pain", @"sad", @"angry", @"cry", @"broccoli", @"grounded", @"bummed out", @"disappointed", @"boring" ];
	_goodWords = @[@"happy", @"lucky", @"glad", @"joy", @"sweet", @"nice", @"laugh", @"strawberry", @"playing", @"relieved", @"flow", @"singing"];
	
	// verify both arrays contain the same number of items
	NSAssert2(_badWords.count == _goodWords.count,
			  @"both word lists must contain the same number of words! good words: %u bad words: %u",
			  (int)_goodWords.count, (int)_badWords.count);
}

-(void) readerDidLoadChildNode:(SKNode*)node
{
	NSLog(@"readerDidLoadChildNode: %p - %@", node, node);
}

-(void) endGameButton:(id)sender
{
	SKScene* scene = [CCBReader loadAsScene:@"MainScene"];
	[self.scene.view presentScene:scene];
}

-(void) goodWordButton:(id)sender
{
	[self userSaysWordIsBad:NO];
}

-(void) badWordButton:(id)sender
{
	[self userSaysWordIsBad:YES];
}

-(void) userSaysWordIsBad:(BOOL)userSaysWordIsBad
{
	BOOL wordIsBad = [_badWords containsObject:_currentWord];
	
	if (userSaysWordIsBad && wordIsBad)
	{
		// CORRECT! Score++
		_score++;
	}
	else if (userSaysWordIsBad == NO && wordIsBad == NO)
	{
		// also correct
		_score++;
	}
	else
	{
		// FAIL! Score--
		_score--;
	}
}

-(void) update:(NSTimeInterval)currentTime
{
	NSTimeInterval timePassedSinceUpdate = currentTime - _lastWordUpdate;
	
	if (timePassedSinceUpdate > 1.0 || _lastWordUpdate == 0)
	{
		_lastWordUpdate = currentTime;
		NSLog(@"update word");
		
		// default to using the good words list
		NSArray* wordList = _goodWords;
		
		// randomly returns 0 or 1
		uint32_t useBadWord = arc4random_uniform(2);
		if (useBadWord) {
			// swith to bad words list instead
			wordList = _badWords;
		}
		
		// select a random word
		uint32_t randomWordIndex = arc4random_uniform(_badWords.count);
		_currentWord = wordList[randomWordIndex];
		
		SKNode* wordNode = [CCBReader load:@"word"];
		wordNode.position = CGPointMake(self.scene.size.width / 2.0, self.scene.size.height / 2.0);
		[self addChild:wordNode];
	}
}

@end
