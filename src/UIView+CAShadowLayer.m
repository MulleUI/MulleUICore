//
//  UIView+CAShadowLayer.m
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
#import "UIView+CAShadowLayer.h"

#import "import-private.h"


@interface CALayer( UILayer) <UILayer>
@end


@implementation UIView ( CAShadowLayer)

- (void) setShowsShadow:(BOOL) flag
{
   // already there ? 
   if( flag && _shadowLayer)
      return;

   [_shadowLayer release];
   _shadowLayer = nil;

   if( flag)
      _shadowLayer = [CAShadowLayer new];
}


- (BOOL) isShowingShadow
{
   return( _shadowLayer ? YES : NO);
}


- (void) layoutShadowLayer:(id <UILayer>) layer
                layoutInfo:(struct UILayoutInfo *) info
{
   CAShadowLayer  *shadowLayer = (CAShadowLayer *) layer;
   CGRect         frame;
   UIEdgeInsets   shadowInsets;

   shadowInsets = [shadowLayer shadowInsets];

   // create new frame for shadow layer and copy insets down
   frame = UIEdgeInsetsExtrudeRect( info->rect, shadowInsets);
   [shadowLayer setFrame:frame];
   [shadowLayer layoutWithLayoutInfo:info];
}  


- (CAShadowLayer *) shadowLayer
{
   assert( _shadowLayer);
   return( (CAShadowLayer *) _shadowLayer);
}

@end
