//
// Copyright (c) 2021 Nat!, Mulle kybernetiK
//
#import "UIApplication+UIWindow.h"

#import "import-private.h"


int  UIApplicationRunDrawCallback( CALayerDrawCallback_t *callback,
                                   CGSize canvasSize, 
                                   CGSize windowSize, 
                                   char *title,
                                   CGFloat frameRate)
{
   CALayer    *layer;
   UIWindow   *window;

   
   if( windowSize.width == 0.0)
      windowSize = canvasSize;

   layer = [CALayer layerWithFrame:CGRectMake( 0, 0, windowSize.width, windowSize.height)];
   [layer setBounds:CGRectMake( 0, 0, canvasSize.width, canvasSize.height)];
   [layer setCanvas:CGRectMake( 0, 0, canvasSize.width, canvasSize.height)];
   [layer setDrawCallback:callback];

   // need this for UIWindow to work, since it initializes glwf/SDL
   [UIApplication sharedInstance];

   window = [UIWindow windowWithLayer:layer
                      titleUTF8String:title];
   [window setFrameRate:frameRate];

   return( UIApplicationRunWindow( window));
}

