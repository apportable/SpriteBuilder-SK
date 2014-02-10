//
//  CCColor.m
//  cocos2d-ios
//
//  Created by Viktor on 12/10/13.
//
//

#import "CCColor.h"
#import <CoreGraphics/CoreGraphics.h>

@implementation CCColor

+ (CCColor*) colorWithWhite:(float)white alpha:(float)alpha
{
    return [[CCColor alloc] initWithWhite:white alpha:alpha];
}

+ (CCColor*) colorWithRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha
{
    return [[CCColor alloc] initWithRed:red green:green blue:blue alpha:alpha];
}

+ (CCColor*) colorWithRed:(float)red green:(float)green blue:(float)blue
{
    return [[CCColor alloc] initWithRed:red green:green blue:blue];
}

+ (CCColor*) colorWithCGColor:(CGColorRef)cgColor
{
    return [[CCColor alloc] initWithCGColor:cgColor];
}

#ifdef __CC_PLATFORM_IOS
+ (CCColor*) colorWithUIColor:(UIColor *)color
{
    return [[CCColor alloc] initWithUIColor:color];
}
#endif

- (CCColor*) colorWithAlphaComponent:(float)alpha
{
    return [CCColor colorWithRed:_r green:_g blue:_b alpha:alpha];
}

- (CCColor*) initWithWhite:(float)white alpha:(float)alpha
{
    self = [super init];
    if (!self) return NULL;
    
    _r = white;
    _g = white;
    _b = white;
    _a = alpha;
    
    return self;
}

/** Hue in degrees 
 HSV-RGB Conversion adapted from code by Mr. Evil, beyondunreal wiki
 */
/*
- (CCColor*) initWithHue:(float)hue saturation:(float)saturation brightness:(float)brightness alpha:(float)alpha
{
	self = [super init];
	if (!self) return NULL;
	
	float chroma = saturation * brightness;
	float hueSection = hue / 60.0f;
	float X = chroma *  (1.0f - ABS(fmod(hueSection, 2.0f) - 1.0f));
	ccColor4F rgb;

	if(hueSection < 1.0) {
		rgb.r = chroma;
		rgb.g = X;
	} else if(hueSection < 2.0) {
		rgb.r = X;
		rgb.g = chroma;
	} else if(hueSection < 3.0) {
		rgb.g = chroma;
		rgb.b = X;
	} else if(hueSection < 4.0) {
		rgb.g= X;
		rgb.b = chroma;
	} else if(hueSection < 5.0) {
		rgb.r = X;
		rgb.b = chroma;
	} else if(hueSection <= 6.0){
		rgb.r = chroma;
		rgb.b = X;
	}

	float Min = brightness - chroma;

	rgb.r += Min;
	rgb.g += Min;
	rgb.b += Min;
	rgb.a = alpha;

	return [CCColor colorWithCcColor4f:rgb];
}
*/

- (CCColor*) initWithRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha
{
    self = [super init];
    if (!self) return NULL;
    
    _r = red;
    _g = green;
    _b = blue;
    _a = alpha;
    
    return self;
}

- (CCColor*) initWithRed:(float)red green:(float)green blue:(float)blue
{
    self = [super init];
    if (!self) return NULL;
    
    _r = red;
    _g = green;
    _b = blue;
    _a = 1;
    
    return self;
}

- (CCColor*) initWithCGColor:(CGColorRef)cgColor
{
    self = [super init];
    if (!self) return NULL;
    
    const CGFloat *components = CGColorGetComponents(cgColor);
    
    _r = (float) components[0];
    _g = (float) components[1];
    _b = (float) components[2];
    _a = (float) components[3];
    
    return self;
}

#ifdef __CC_PLATFORM_IOS
- (CCColor*) initWithUIColor:(UIColor *)color
{
    self = [super init];
    if (!self) return NULL;
    
    CGColorSpaceModel csModel = CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
    if (csModel == kCGColorSpaceModelRGB)
    {
        [color getRed:&_r green:&_g blue:&_b alpha:&_a];
    }
    else if (csModel == kCGColorSpaceModelMonochrome)
    {
        CGFloat w, a;
        [color getWhite:&w alpha:&a];
        _r = w;
        _g = w;
        _b = w;
        _a = a;
    }
    else
    {
        NSAssert(NO, @"UIColor has unsupported color space model");
    }
    
    return self;
}
#endif

- (CGColorRef) CGColor
{
    CGFloat components[4] = {(CGFloat)_r, (CGFloat)_g, (CGFloat)_b, (CGFloat)_a};
    return CGColorCreate(CGColorSpaceCreateDeviceRGB(), components);
}

#ifdef __CC_PLATFORM_IOS

- (UIColor*) UIColor
{
    return [UIColor colorWithRed:_r green:_g blue:_b alpha:_a];
}

#endif

#ifdef __CC_PLATFORM_MAC
- (NSColor*) NSColor
{
	return [NSColor colorWithCalibratedRed:(CGFloat)_r green:(CGFloat)_g blue:(CGFloat)_b alpha:(CGFloat)_a];
}
#endif

- (BOOL) getRed:(float *)red green:(float *)green blue:(float *)blue alpha:(float *)alpha
{
    *red = _r;
    *green = _g;
    *blue = _b;
    *alpha = _a;
    
    return YES;
}

- (BOOL) getWhite:(float *)white alpha:(float *)alpha
{
    *white = (_r + _g + _b) / 3.0; // Just use an average of the components
    *alpha = _a;
    
    return YES;
}

/*
- (CCColor*) interpolateTo:(CCColor *) toColor time:(float) t
{
	return [CCColor colorWithCcColor4f:ccc4FInterpolated(self.ccColor4f, toColor.ccColor4f, t)];
}
 */

+ (CCColor*) blackColor
{
    return [CCColor colorWithRed:0 green:0 blue:0 alpha:1];
}

+ (CCColor*) darkGrayColor
{
    return [CCColor colorWithWhite:1.0/3.0 alpha:1];
}

+ (CCColor*) lightGrayColor
{
    return [CCColor colorWithWhite:2.0/3.0 alpha:1];
}

+ (CCColor*) whiteColor
{
    return [CCColor colorWithWhite:1 alpha:1];
}

+ (CCColor*) grayColor
{
    return [CCColor colorWithWhite:0.5 alpha:1];
}

+ (CCColor*) redColor
{
    return [CCColor colorWithRed:1 green:0 blue:0 alpha:1];
}

+ (CCColor*) greenColor
{
    return [CCColor colorWithRed:0 green:1 blue:0 alpha:1];
}

+ (CCColor*) blueColor
{
    return [CCColor colorWithRed:0 green:0 blue:1 alpha:1];
}

+ (CCColor*) cyanColor
{
    return [CCColor colorWithRed:0 green:1 blue:1 alpha:1];
}

+ (CCColor*) yellowColor
{
    return [CCColor colorWithRed:1 green:1 blue:0 alpha:1];
}

+ (CCColor*) magentaColor
{
    return [CCColor colorWithRed:1 green:0 blue:1 alpha:1];
}

+ (CCColor*) orangeColor
{
    return [CCColor colorWithRed:1 green:0.5 blue:0 alpha:1];
}

+ (CCColor*) purpleColor
{
    return [CCColor colorWithRed:0.5 green:0 blue:0.5 alpha:1];
}

+ (CCColor*) brownColor
{
    return [CCColor colorWithRed:0.6 green:0.4 blue:0.2 alpha:1];
}

+ (CCColor*) clearColor
{
    return [CCColor colorWithRed:0 green:0 blue:0 alpha:0];
}

-(instancetype) copyWithZone:(NSZone *)zone
{
	CCColor* copy = [[CCColor allocWithZone:zone] initWithRed:self.red green:self.green blue:self.blue alpha:self.alpha];
	return copy;
}

@end


@implementation CCColor (OpenGL)

/*
+ (CCColor*) colorWithCcColor3b:(ccColor3B)c
{
    return [[CCColor alloc] initWithCcColor3b:c];
}

+ (CCColor*) colorWithCcColor4b:(ccColor4B)c
{
    return [[CCColor alloc] initWithCcColor4b:c];
}

+ (CCColor*) colorWithCcColor4f:(ccColor4F)c
{
    return [[CCColor alloc] initWithCcColor4f:c];
}

- (CCColor*) initWithCcColor3b: (ccColor3B) c
{
    return [self initWithRed:c.r/255.0 green:c.g/255.0 blue:c.b/255.0 alpha:1];
}

- (CCColor*) initWithCcColor4b: (ccColor4B) c
{
    return [self initWithRed:c.r/255.0 green:c.g/255.0 blue:c.b/255.0 alpha:c.a/255.0];
}

- (CCColor*) initWithCcColor4f: (ccColor4F) c
{
    return [self initWithRed:c.r green:c.g blue:c.b alpha:c.a];
}

- (ccColor3B) ccColor3b
{
    return (ccColor3B){(GLubyte)(_r*255), (GLubyte)(_g*255), (GLubyte)(_b*255)};
}

- (ccColor4B) ccColor4b
{
    return (ccColor4B){(GLubyte)(_r*255), (GLubyte)(_g*255), (GLubyte)(_b*255), (GLubyte)(_a*255)};
}

- (ccColor4F) ccColor4f
{
    return ccc4f(_r, _g, _b, _a);
}
*/
@end

@implementation CCColor (ExtraProperties)

- (float) red
{
    return _r;
}

- (float) green
{
    return _g;
}

- (float) blue
{
    return _b;
}

- (float) alpha
{
    return _a;
}

/*
- (BOOL) isEqual:(id)color
{
    if (self == color) return YES;
    if (![color isKindOfClass:[CCColor class]]) return NO;
    
    ccColor4F c4f0 = self.ccColor4f;
    ccColor4F c4f1 = ((CCColor*)color).ccColor4f;
    
    return ccc4FEqual(c4f0, c4f1);
}
*/

- (BOOL) isEqualToColor:(CCColor*) color
{
    return [self isEqual:color];
}

@end

@implementation CCColor (CCBReader)

+(id) colorWithSKColor:(SKColor*)skColor
{
	CGFloat r, g, b, a;
	[skColor getRed:&r green:&g blue:&b alpha:&a];
	return [CCColor colorWithRed:r green:g blue:b alpha:a];
}

-(SKColor*) skColor
{
	return [SKColor colorWithRed:self.red
						   green:self.green
							blue:self.blue
						   alpha:self.alpha];
}

-(CCColorComponentRGBA) componentRGBA
{
    CCColorComponentRGBA rgba;
	rgba.r = self.red;
	rgba.g = self.green;
	rgba.b = self.blue;
	rgba.a = self.alpha;
    return rgba;
}

-(NSString*) description
{
	return [NSString stringWithFormat:@"%@ %.2f %.2f %.2f %.2f", NSStringFromClass([self class]), self.red, self.green, self.blue, self.alpha];
}

@end
