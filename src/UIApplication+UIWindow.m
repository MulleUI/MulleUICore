//
// Copyright (c) 2021 Nat!, Mulle kybernetiK
//
#import "UIApplication+UIWindow.h"

#import "import-private.h"


int  UIApplicationRunDrawCallback( CGGraphicsLayerDrawCallback_t *callback,
                                   CGSize windowSize,
                                   CGSize canvasSize, 
                                   char *title,
                                   CGFloat frameRate)
{
   CGGraphicsLayer    *layer;
   UIWindow           *window;

   
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
   [UIApplication sharedInstance];

   window = [UIWindow windowWithLayer:layer
                      titleUTF8String:title
                            styleMask:UIWindowStyleMaskDefault & ~UIWindowStylePlanes];
   [window setFrameRate:frameRate];

   return( UIApplicationRunWindow( window));
}


