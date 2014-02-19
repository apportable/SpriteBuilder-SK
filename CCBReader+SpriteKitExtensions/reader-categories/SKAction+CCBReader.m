//
//  SKAction+CCBReader.m
//  SB+KoboldKit
//
//  Created by Steffen Itterheim on 19/02/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "SKAction+CCBReader.h"

@implementation SKAction (CCBReader)

@dynamic tag;
static int _tempTag = CCActionTagInvalid;

-(void) setTag:(int)tag
{
	_tempTag = tag;
}
-(int) tag
{
	return _tempTag;
}

-(int) getAndClearTag
{
	int tag = _tempTag;
	_tempTag = CCActionTagInvalid;
	return tag;
}

@dynamic tagAsUniqueString;
static uint32_t SKActionUniqueTagCounter = 0;

-(NSString*) tagAsUniqueString
{
	return [NSString stringWithFormat:@"%@ uniqueTag=%u", [SKAction tagAsString:_tempTag], SKActionUniqueTagCounter++];
}

+(NSString*) tagAsString:(int)tag
{
	return [NSString stringWithFormat:@"actionTag=%i", tag];
}

@end
