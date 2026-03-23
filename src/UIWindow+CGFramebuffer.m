//
//  UIWindow+CG.m
//  MulleUIOS
//
//  CG-related helpers for UIWindow integration
//
#import "import-private.h"

#import "CGFramebuffer+UIFramebuffer.h"
#import "CGImage+UIImage.h"

// CG helper
@implementation CGContext( UIWindow)

- (id <UIImage>) imageWithFramebuffer:(id <UILayer>) framebuffer
                       nameUTF8String:(char *) nameUTF8String
{
   CGFramebuffer   *layer = (CGFramebuffer *) framebuffer;
   CGImage         *image;

   assert( [framebuffer isKindOfClass:[CGFramebuffer class]]);

   image = [[[CGImage alloc] initWithSharedGPUTexture:[layer sharedGPUTexture]
                                           bitmapSize:[layer bitmapSize]
                                         textureFlags:[layer textureFlags]
                                       nameUTF8String:nameUTF8String
                                              context:self] autorelease];
   return( image);
}

@end

