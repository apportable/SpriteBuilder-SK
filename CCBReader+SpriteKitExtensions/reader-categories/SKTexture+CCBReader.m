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
	file = [[CCFileUtils sharedFileUtils] fullPathForFilename:file];
	SKTexture* texture = [SKTexture textureWithImageNamed:file];
	//NSLog(@"%@ size: {%.0f, %.0f} rect: {%.2f, %.2f, %.2f, %.2f}", texture, texture.size.width, texture.size.height, texture.textureRect.origin.x, texture.textureRect.origin.y, texture.textureRect.size.width, texture.textureRect.size.height);
	return texture;
}


@end
