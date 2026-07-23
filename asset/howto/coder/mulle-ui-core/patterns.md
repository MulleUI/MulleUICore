<!-- keywords: bootstrap, window, view, layer, shadow, forwarding, bridge -->
# patterns

## Bootstrap a one-layer app fast

Use the callback helpers when one `CGGraphicsLayer` is the whole surface.

```objective-c
static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *context)
{
   return( YES);
}


int   main( int argc, char *argv[])
{
   return( UIApplicationRunDrawCallbackHz( drawStuff,
                                           CGSizeMake( 640.0, 400.0),
                                           "Demo",
                                           60.0));
}
```

- This is the shortest MulleUICore path from `src/UIApplication+UIWindow.h`.
- If canvas size must differ from window size, use `UIApplicationRunDrawCallback()` instead of the Hz wrapper; the implementation updates both `bounds` and `canvas` when `canvasSize` is non-zero.

## Build the retained window path explicitly

`demo/src/main-refresh.m` is the concrete local pattern for a real window, a content view, and a layer-owned draw callback.

```objective-c
static BOOL   updateText( CGGraphicsLayer *layer, CGContext *context)
{
   CATextLayer   *textLayer;

   textLayer = (CATextLayer *) layer;
   [textLayer setTextUTF8String:"tick"];
   return( YES);
}


int   main( int argc, char *argv[])
{
   UIApplication   *app;
   UIWindow        *window;
   UIView          *view;
   CATextLayer     *layer;
   CGRect          frame;
   NSUInteger      styleMask;

   app = [UIApplication sharedInstance];
   frame = CGRectMake( 0.0, 0.0, 320.0, 320.0);
   styleMask = (UIWindowStyleMaskDefault & ~UIWindowStylePlanes) | UIWindowStyleRetained;

   window = [UIWindow windowWithFrame:frame
                      titleUTF8String:"Demo"
                            styleMask:styleMask];
   layer = [CATextLayer layerWithFrame:frame];
   [layer setBackgroundColor:CGColorMakeBlue()];

   view = [UIView viewWithLayer:layer];
   [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
   [view setDrawCallback:updateText];

   [window setView:view];
   [window setFrameRateHz:1.0];
   [app addWindow:window];
   return( [app runApp]);
}
```

- Put the draw callback on the `UIView` when you own the content view. `src/UIWindow+CGGraphicsLayer.m` only forwards window access to `[self contentView]`.
- Use this path when you need retained mode or normal view configuration before entering the app loop.

## Style a view through its forwarded main layer

`src/UIView+CGGraphicsLayer.h` exists so view code can configure the main `CGGraphicsLayer` without custom plumbing.

```objective-c
view = [UIView viewWithLayer:[CGGraphicsLayer layerWithFrame:frame]];
[view setBackgroundColor:CGColorMakeBlue()];
[view setBorderColor:CGColorMakeWhite()];
[view setBorderWidth:1.0];
[view setCornerRadius:8.0];
[view setOpacity:0.9];
[view setMasksToBounds:YES];
```

- Comparison: this feels UIKit-like, but the state still lives on the layer side in this repo.
- Keep view styling at the view/category surface unless you are intentionally replacing the underlying layer behavior.

## Set the window background color

`src/UIWindow+CGColor.h` exposes a monochrome-only background. The implementation stores a hex color internally and derives the paint from it.

```objective-c
[window setBackgroundColor:CGColorMakeWhite()];
// or via paint — but only the mainColor survives:
CGPaint *paint = [CGPaint paintWithCGColor:CGColorMakeRed()];
[window setBackgroundPaint:paint];
```

- The header comment says "only monochrome colors possible". Gradient or patterned paints lose detail because `setBackgroundPaint:` stores only `[paint mainColor]`. See `src/UIWindow+CGColor.m`.
- Use `CGColor` values directly unless you need `CGPaint` interop elsewhere.

## Add shadows on views

Opt in, then access the layer. See `src/UIView+CAShadowLayer.h` and `src/UIView+CAShadowLayer.m`.

```objective-c
[view setShowsShadow:YES];
CAShadowLayer *shadow = [view shadowLayer];
```

- `shadowLayer` asserts unless `setShowsShadow:YES` was called first.
- The shadow layer's frame is extruded by `shadowInsets`, so the shadow can paint outside the view's nominal rectangle.

## Add repo-local helpers on top of the view/layer pair

- Enable shadows with `[view setShowsShadow:YES]` before asking for `[view shadowLayer]`; the helper is opt-in in `src/UIView+CAShadowLayer.m`.
- Use `[window setBackgroundColor:...]` for solid backgrounds. `src/UIWindow+CGColor.m` stores hex color, so plain `CGColor` values are the happy path.
- Let `CGImage` choose its UI layer class. `src/CGImage+UIImage.m` fixes `CAImageLayer` as the preferred image layer.
- Use `CGFramebuffer` and `CGGraphicsLayer` directly when higher-level code asks for `UIFramebuffer` or `UILayer`; these categories are bridge glue, not wrapper subsystems.
- Keep `MulleObjCDeps(MulleUICore)` header public — downstream libraries use it to declare their load dependencies.

## Drop below MulleUICore only for backend control

`demo/src/main-glfw-boing.m` shows the fallback when you need direct `GLFWOSWindow`, explicit graphics-context activation, and your own render loop.

```objective-c
app = [UIApplication sharedInstance];
gWindow = [GLFWOSWindow windowWithFrame:CGRectMake( 0, 0, 400, 400)
                        titleUTF8String:"Demo"
                              styleMask:styleMask
                          graphicsHints:0];
[app addWindow:gWindow];
```

- Keep this as the fallback, not the default pattern for normal MulleUICore changes.
