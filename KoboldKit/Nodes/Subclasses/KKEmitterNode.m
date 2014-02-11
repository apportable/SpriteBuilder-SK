/*
 * Copyright (c) 2013 Steffen Itterheim.
 * Released under the MIT License:
 * KoboldAid/licenses/KoboldKitFree.License.txt
 */


#import "KKEmitterNode.h"
#import "KKNodeShared.h"

@implementation KKEmitterNode
KKNODE_SHARED_CODE

+(id) emitterWithFile:(NSString*)file
{
	NSString* filePath = [[NSBundle mainBundle] pathForResource:[file stringByDeletingPathExtension]
														 ofType:@"sks"];
	return [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
}

@end
