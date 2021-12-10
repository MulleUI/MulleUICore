//
// Copyright (c) 2021 Nat!, Mulle kybernetiK
//
#import "import.h"


@interface UIApplication( UIWindow)

//
// This method  creates a window to display what "callback" draws and runs
// the window until it is closed.
//
// The canvasSize is the unscaled size of your drawing, let say
// 320x200. If the windowSize is left to zero, then the window will
// be this size too. Otherwise the drawing will be scaled to fit
// the windowSize
//
- (void) runWindowForDrawCallback:(CALayerDrawCallback_t) callback
                       canvasSize:(CGSize) canvasSize
                       windowSize:(CGSize) windowSize
                  titleUTF8String:(char *) title
                      frameRateHz:(CGFloat) hz;

// even more convenient...
+ (void) runWindowForDrawCallback:(CALayerDrawCallback_t) callback
                       canvasSize:(CGSize) canvasSize
                       windowSize:(CGSize) windowSize
                  titleUTF8String:(char *) title
                      frameRateHz:(CGFloat) hz;
@end
