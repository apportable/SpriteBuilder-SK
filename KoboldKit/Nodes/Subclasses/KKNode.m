/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import "KKNode.h"
#import "SKNode+KoboldKit.h"
#import "KKNodeShared.h"

@implementation KKNode
KKNODE_SHARED_CODE

#pragma mark Description

-(NSString*) description
{
	return [NSString stringWithFormat:@"%@ (%p)", [super description], self];
}

@end
