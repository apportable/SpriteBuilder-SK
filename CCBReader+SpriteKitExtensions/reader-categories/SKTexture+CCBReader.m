/*
 * SpriteBuilder: http://www.spritebuilder.org
 *
 * Copyright (c) 2014 Apportable Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "SKTexture+CCBReader.h"
#import "CCSpriteFrameCache.h"
#import "CCFileUtils.h"

@implementation SKTexture (CCBReader)

+(instancetype) frameWithImageNamed:(NSString*)name
{
	return [SKTexture textureWithFile:name];
}

+(instancetype) textureWithFile:(NSString*)file
{
	SKTexture* texture = nil;
	SKTextureAtlas* atlas = [SKTexture atlasFromPath:[file stringByDeletingLastPathComponent]];
	if (atlas)
	{
		NSString* textureName = file.lastPathComponent;
		texture = [atlas textureNamed:textureName];
	}
	else
	{
		file = [[CCFileUtils sharedFileUtils] fullPathForFilename:file];
		texture = [SKTexture textureWithImageNamed:file];
	}
	
	//NSLog(@"%@ size: {%.0f, %.0f} rect: {%.2f, %.2f, %.2f, %.2f}", texture, texture.size.width, texture.size.height, texture.textureRect.origin.x, texture.textureRect.origin.y, texture.textureRect.size.width, texture.textureRect.size.height);
	return texture;
}

#pragma mark Texture Atlas Loading

static NSMutableDictionary* textureAtlasNameCache;
static NSMutableDictionary* notTextureAtlasNameCache;
+(SKTextureAtlas*) atlasFromPath:(NSString*)path
{
	SKTextureAtlas* atlas = nil;
	if (path.length)
	{
		if (textureAtlasNameCache == nil && notTextureAtlasNameCache == nil)
		{
			textureAtlasNameCache = [NSMutableDictionary dictionary];
			notTextureAtlasNameCache = [NSMutableDictionary dictionary];
		}
		
		if ([notTextureAtlasNameCache objectForKey:path] == nil)
		{
			NSString* textureAtlasName = [textureAtlasNameCache objectForKey:path];
			if (textureAtlasName)
			{
				atlas = [SKTextureAtlas atlasNamed:textureAtlasName];
			}
			else
			{
				atlas = [SKTexture deviceSpecificAtlasNamed:path];
			}
		}
	}
	
	return atlas;
}

+(SKTextureAtlas*) deviceSpecificAtlasNamed:(NSString*)textureAtlasName
{
	SKTextureAtlas* atlas = nil;
	CCFileUtils* fileUtils = [CCFileUtils sharedFileUtils];
	
	for (NSString* device in fileUtils.searchResolutionsOrder)
	{
		// Search in subdirectories
		NSString* directory = [fileUtils.directoriesDict objectForKey:device];
		directory = [@"Published-iOS" stringByAppendingPathComponent:directory];
		
		// check if file is actually inside a texture atlas
		BOOL isDirectory = NO;
		NSString* atlasPath = [[NSBundle mainBundle] pathForResource:textureAtlasName ofType:@"atlasc" inDirectory:directory];
		
		if (atlasPath && [[NSFileManager defaultManager] fileExistsAtPath:atlasPath isDirectory:&isDirectory] && isDirectory)
		{
			NSString* relativePathToAtlas = [directory stringByAppendingPathComponent:textureAtlasName];
			[textureAtlasNameCache setObject:relativePathToAtlas forKey:textureAtlasName];
			NSLog(@"Creating SKTextureAtlas named: %@", relativePathToAtlas);
			atlas = [SKTextureAtlas atlasNamed:relativePathToAtlas];
			break;
		}
	}

	if (atlas == nil)
	{
		// remember this path as not being an atlas folder (typically "ccbResources") for quick dismissal
		[notTextureAtlasNameCache setObject:textureAtlasName forKey:textureAtlasName];
	}

	return atlas;
}

@end
