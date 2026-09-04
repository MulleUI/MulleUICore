//
//  UIWindow+CGFramebuffer.m
//  MulleUICore
//
//  Copyright (c) 2026 Nat! - Mulle kybernetiK.
//  All rights reserved.
//
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  Neither the name of Mulle kybernetiK nor the names of its contributors
//  may be used to endorse or promote products derived from this software
//  without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
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


// The no-backend sibling of CGContext (MulleCG). It has no framebuffer, so the
// image query returns nil. Declared here so CGNullContext gets the exact same
// runtime treatment (and UIGraphicsContext conformance) as CGContext.
@implementation CGNullContext( UIWindow)

- (id <UIImage>) imageWithFramebuffer:(id <UILayer>) framebuffer
                       nameUTF8String:(char *) nameUTF8String
{
   return( nil);
}

@end

