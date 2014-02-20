/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import "KKEmitterNode.h"
#import "KKNodeShared.h"
#import "CCScheduler.h"

@implementation KKEmitterNode
KKNODE_SHARED_CODE
KKNODE_SHARED_ADD_ANCHORPOINT

+(id) emitterWithFile:(NSString*)file
{
	NSString* filePath = [[NSBundle mainBundle] pathForResource:[file stringByDeletingPathExtension]
														 ofType:@"sks"];
	return [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
}

@end
