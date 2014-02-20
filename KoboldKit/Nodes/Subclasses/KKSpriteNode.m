/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */

#import "KKSpriteNode.h"
#import "KKNodeShared.h"
#import "CCScheduler.h"
#import "CCBSpriteKitCompatibility.h"

@implementation KKSpriteNode
KKNODE_SHARED_CODE
KKNODE_SHARED_OVERRIDE_ANCHORPOINT

@dynamic startColor, endColor;
-(void) setStartColor:(CCColor*)startColor
{
	self.color = startColor.skColor;
	self.colorBlendFactor = 1.0;
}
-(CCColor*) startColor
{
	return [CCColor colorWithSKColor:self.color];
}

-(void) setEndColor:(CCColor*)endColor
{
	self.color = endColor.skColor;
	self.colorBlendFactor = 1.0;
}
-(CCColor*) endColor
{
	return [CCColor colorWithSKColor:self.color];
}

@end
