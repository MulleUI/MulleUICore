//
//  UIApplication+UIWindow.m
//  MulleUICore
//
//  Copyright (c) 2021 Nat! - Mulle kybernetiK.
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
#import "UIApplication+UIWindow.h"

#import "import-private.h"

#import "CGGraphicsLayer+UILayer.h"


int  UIApplicationRunDrawCallback( CGGraphicsLayerDrawCallback_t *callback,
                                   CGSize windowSize,
                                   CGSize canvasSize, 
                                   char *title,
                                   CGFloat frameRate)
{
   UIApplication      *app;
   CGGraphicsLayer    *layer;
   UIWindow           *window;
   NSUInteger         styleMask;
   
   if( windowSize.width == 0.0)
      windowSize = canvasSize;

   if( windowSize.width == 0.0)
      windowSize = CGSizeMake( 640, 400);

   layer = [CGGraphicsLayer layerWithFrame:CGRectMake( 0, 0, windowSize.width, windowSize.height)];
   if( canvasSize.width != 0.0)
   {
      [layer setBounds:CGRectMake( 0, 0, canvasSize.width, canvasSize.height)];
      [layer setCanvas:CGRectMake( 0, 0, canvasSize.width, canvasSize.height)];
   }
   [layer setDrawCallback:callback];

   // need this for UIWindow to work, since it initializes glwf/SDL
   app = [UIApplication sharedInstance];

   styleMask = UIWindowStyleMaskDefault;
   styleMask = UIWindowStyleMaskBySetting( styleMask, UIWindowStylePlanes, NO);
   styleMask = UIWindowStyleMaskBySetting( styleMask, UIWindowStyleInputPolling, YES);

   window = [UIWindow windowWithLayer:layer
                      titleUTF8String:title
                            styleMask:styleMask];
   [window setFrameRate:frameRate];

   return( [app runWindow:window]);
}


