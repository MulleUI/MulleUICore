//
// Copyright (c) 2021 Nat!, Mulle kybernetiK
//
#import "import.h"


int  UIApplicationRunDrawCallback( CGGraphicsLayerDrawCallback_t *callback,
                                   CGSize windowSize,
                                   CGSize canvasSize,
                                   char *title,
                                   CGFloat frameRate);

// even simpler and more convenient
static inline int  
     UIApplicationRunDrawCallbackHz( CGGraphicsLayerDrawCallback_t *callback,
                                     CGSize windowSize,
                                     char *title,
                                     CGFloat hz)
{
   CGFloat   frameRate;

   if( hz == 0.0)
      frameRate = UIWindowFrameRateAsync;
   else
      if( hz < 0.0)
         frameRate = UIWindowFrameRateSynced;
      else
         frameRate = 1.0f / hz;      
   return( UIApplicationRunDrawCallback( callback, windowSize, CGSizeZero, title, frameRate));
}
