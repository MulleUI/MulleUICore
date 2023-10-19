//
//  UIView+Dump.m
//  MulleUI
//
//  Copyright (c) 2021 Nat! - Mulle kybernetiK.
//  Copyright (c) 2021 Codeon GmbH.
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
#import "UIView+Dump.h"

#import "import-private.h"



#define DUMP_LAYERS


@implementation CALayer( Dump)

- (void) dumpWithIndent:(NSUInteger) indent
{
   NSUInteger   i;

   for( i = 0; i < indent; i++)
      fputc( ' ', stderr);

   fprintf( stderr, "%s: frame=[%s] bounds=[%s] clip=[%s]",
               [self UTF8String],
               CGRectUTF8String( [self frame]),
               CGRectUTF8String( [self bounds]),
               CGRectUTF8String( [self clipRect]));
   if( [self masksToBounds])
      fprintf ( stderr, " masks");

   fprintf( stderr, "\n");
}

@end


@implementation UIView( Dump)

- (void) dumpSubviewsWithIndent:(NSUInteger) indent
{
   UIView   *view;

   mulle_pointerarray_for( &_subviews, view)
   {
      [view dumpWithIndent:indent];
   }
}


- (void) dumpLayersWithIndent:(NSUInteger) indent
{
   CALayer   *layer;

   [(CALayer *) _mainLayer dumpWithIndent:indent];

   mulle_pointerarray_for( &_layers, layer)
   {
      [layer dumpWithIndent:indent];
   }
}


- (void) dumpWithIndent:(NSUInteger) indent
{
   NSUInteger   i;
   char         *s;

   for( i = 0; i < indent; i++)
      fputc( ' ', stderr);

   if( [self isHidden])
      fprintf( stderr, "%s: hidden\n",
                  [self UTF8String]);
   else
   {
      fprintf( stderr, "%s: f=[%s] b=[%s]",
                  [self UTF8String],
                  CGRectUTF8String( [self frame]),
                  CGRectUTF8String( [self bounds]));
      if( [self clipsToBounds])
         fprintf ( stderr, " clips");
      if( [self isUserInteractionEnabled])
         fprintf ( stderr, " interactive");

      s = UIViewAutoresizingMaskShortUTF8String( [self autoresizingMask]);
      if( *s)
         fprintf ( stderr, " %s", s);

      fprintf( stderr, "\n");
   }
#ifdef DUMP_LAYERS
   [self dumpLayersWithIndent:indent + 3];
#endif
//   if( _yoga)
//   {
//      fprintf( stderr, "%s\n", [[_yoga debugDescription] UTF8String]);
//   }
   [self dumpSubviewsWithIndent:indent + 3];
}


- (void) dump
{
   [self dumpWithIndent:0];
}

@end
