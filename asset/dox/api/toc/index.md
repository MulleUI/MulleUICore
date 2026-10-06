# MulleUICore Library Documentation for AI
<!-- Keywords: UI, desktop, mobile, convenience, forwarding, bridge, objective-c -->

## 1. Introduction & Purpose

MulleUICore is a convenience layer atop MulleUIWindow and MulleGraphics. It
reduces boilerplate for creating mulle-objc UI applications by providing C
bootstrap functions, category-based forwarding helpers, and thin bridge shims
that marry CG-level objects with higher-level UI protocols. It is the
recommended entry point for writing MulleUI code without widgets and without
Foundation (which introduces NSString).

With MulleUICore you can:

* run a single-layer drawing app with one C function call
* manually wire UIApplication/UIWindow/UIView hierarchies with minimal setup
* forward view-level visual properties (border, background, opacity, rotation)
  to the backing CGGraphicsLayer
* add opt-in CAShadowLayer shadows on any UIView
* set a monochrome window background color via CGColor
* bridge CGImage, CGFramebuffer, and CGGraphicsLayer to UIImage, UIFramebuffer,
  and UILayer protocols

MulleUICore depends on MulleUIWindow (which provides UIWindow, UIView, and
UIApplication) and MulleGraphics (which provides CALayer subclasses and CG
types).

## 2. Key Concepts & Design Philosophy

### Category-based convenience, not new class hierarchies

MulleUICore adds its API through categories on the classes provided by its
dependencies. It does not introduce new base UI classes. This keeps the
dependency surface small and the library itself easy to understand.

### Forwarding over duplication

UIView and UIWindow do not own independent draw-callback or visual state
in this library. Properties like `drawCallback`, `borderWidth`, `opacity`,
`cornerInsets`, `rotation`, and `masksToBounds` are forwarded to the
view's main `CGGraphicsLayer` via mulle-objc forwarding. This avoids
synchronization bugs between view and layer state.

### Bootstrap functions for common cases

The C functions `UIApplicationRunDrawCallback()` and
`UIApplicationRunDrawCallbackHz()` encapsulate the entire application
setup lifecycle for simple single-layer drawing apps. They create the
application, window, and graphics layer in one call.

### CG/UI bridge shims, not wrappers

Categories like `CGFramebuffer(UIFramebuffer)`, `CGGraphicsLayer(UILayer)`,
and `CGImage(UIImage)` exist solely to make core-graphics objects conform to
higher-level UI protocols. They add no repo-local behavior beyond protocol
adoption.

## 3. Core API & Data Structures

### 3.1. `MulleUICore.h`

Umbrella header providing version information. Includes all dependencies via
`import.h`.

#### Version Information

```c
#define MULLE_UI_CORE_VERSION  ((0UL << 20) | (1 << 8) | 1)

static inline unsigned int   MulleUI_get_version_major( void);
static inline unsigned int   MulleUI_get_version_minor( void);
static inline unsigned int   MulleUI_get_version_patch( void);

MULLE_UI_CORE_GLOBAL
uint32_t   MulleUICore_get_version( void);
```

- `MULLE_UI_CORE_VERSION` — compile-time version of this library
  (major 0, minor 1, patch 1); the `MulleUI_get_version_*()` inlines decode it
- `MulleUICore_get_version()` — runtime version as uint32_t, declared
  `MULLE_UI_CORE_GLOBAL` (import/export visibility from `include.h`)
- `_major/_minor/_patch` — decoded version components of `MULLE_UI_CORE_VERSION`

### 3.2. `UIApplication+UIWindow.h`

Bootstrap C functions that create a complete single-layer drawing application
with one call. These are the shortest path from zero to a running window.

#### `UIApplicationRunDrawCallback()`

```c
MULLE_UI_CORE_GLOBAL
int  UIApplicationRunDrawCallback( CGGraphicsLayerDrawCallback_t *callback,
                                   CGSize windowSize,
                                   CGSize canvasSize,
                                   char *title,
                                   CGFloat frameRate);
```

Creates a UIApplication, UIWindow, and CGGraphicsLayer with the given draw
callback. This is the lower-level convenience function that allows specifying
canvas size separately from window size.

**Parameters:**
- `callback` — draw function of type `CGGraphicsLayerDrawCallback_t`
- `windowSize` — window dimensions (defaults to 640x400 if zero)
- `canvasSize` — drawing canvas dimensions (defaults to windowSize if zero);
  when non-zero, also overwrites layer `bounds` and `canvas`
- `title` — window title as UTF-8 C string
- `frameRate` — `UIWindowFrameRateAsync`, `UIWindowFrameRateSynced`, or
  an explicit interval in seconds

**Returns:** exit code from the application run loop.

**Implementation notes:** This function always clears `UIWindowStylePlanes`
and forces `UIWindowStyleInputPolling`. It calls `[UIApplication sharedInstance]`
internally, so callers do not need to initialize the backend first.

**Frame rate constants:**
```c
UIWindowFrameRateAsync    // no frame limiting
UIWindowFrameRateSynced   // sync to display refresh (VSync)
```

#### `UIApplicationRunDrawCallbackHz()`

```c
static inline int
      UIApplicationRunDrawCallbackHz( CGGraphicsLayerDrawCallback_t *callback,
                                      CGSize windowSize,
                                      char *title,
                                      CGFloat hz);
```

Inline convenience wrapper that converts hertz to frameRate. Call this when
you have a frequency rather than an interval.

**Parameters:**
- `callback` — draw function
- `windowSize` — window dimensions
- `title` — window title as UTF-8 C string
- `hz` — refresh frequency: `0.0` → async, `<0.0` → synced to display,
  `>0.0` → interval = `1.0 / hz`

**Returns:** exit code from the application run loop.

### 3.3. `UIView+CGGraphicsLayer.h`

Forwarding category that maps UIView-level property access to the backing
`CGGraphicsLayer`. The category name is `CGGraphicsLayerForwarding` and it
adopts `<MulleObjCForwarding>`. A `UIView` does not store these properties
itself — they are all forwarded to `[self mainLayer]`.

```objc
@interface UIView( CGGraphicsLayerForwarding) < MulleObjCForwarding>

@property( forward, assign) CGGraphicsLayerDrawCallback_t   *drawCallback;
@property( forward, observable) MulleCornerInsets           cornerInsets;
@property( forward, observable) CGFloat                     borderWidth;
@property( forward, observable) CGFloat                     opacity;
@property( forward, observable) CGPaint                     *borderPaint;
@property( forward, observable) CGPaint                     *backgroundPaint;
@property( forward, observable) CGPoint                     anchorPoint;
@property( forward, observable) CARotation                  rotation;
@property( forward, assign) BOOL                            masksToBounds;
```

**Implementation note:** `+layerClass` is hard-wired to `CGGraphicsLayer`. The
layout context used during forwarding is thread-local under the key
`"UILayoutContext"`, not window-local.

The `@optional` section provides methods that may or may not be available at
runtime depending on the actual layer class:

```objc
@optional
- (void) setBorderColor:(CGColor) color;
- (void) setBackgroundColor:(CGColor) color;
- (void) setCornerRadius:(CGFloat) radius;
@end
```

### 3.4. `UIWindow+CGGraphicsLayer.h`

Draw-callback proxy on UIWindow. The window does not store its own draw
callback; `setDrawCallback:` forwards to `[self contentView]` and asserts
if there is no content view.

```objc
@interface UIWindow( CGGraphicsLayer)

@property( dynamic) CGGraphicsLayerDrawCallback_t    *drawCallback;

@end
```

### 3.5. `UIWindow+CGColor.h`

Window background color support. Only monochrome colors work —
the implementation stores a single hex color internally. Gradient or
patterned paints lose detail because `setBackgroundPaint:` stores only
`[paint mainColor]`.

```objc
@interface UIWindow( CGColor)

@property( assign, dynamic) CGColor   backgroundColor;

// only monochrome colors possible
- (CGPaint *) backgroundPaint;
- (void) setBackgroundPaint:(CGPaint *) paint;

@end
```

### 3.6. `UIView+CAShadowLayer.h`

Opt-in shadow layer on UIView. Call `setShowsShadow:YES` before accessing
`shadowLayer` — it asserts if the shadow has not been enabled.

```objc
@interface UIView( CAShadowLayer)

- (void) setShowsShadow:(BOOL) flag;
- (BOOL) isShowingShadow;

// this will assert, if isShowingShadow returns NO
- (CAShadowLayer *) shadowLayer;

@end
```

**Implementation notes:** The shadow layer's frame is extruded by
`shadowInsets`, so the shadow can paint outside the view's nominal rectangle.

### 3.7. `CALayer+UIOSWindow.h`

Layer initializer that accepts an `<UIOSWindow>` argument but ignores it
entirely. This exists for protocol conformance compatibility.

```objc
@interface CALayer( UIOSWindow) < MulleUINamedObject>

- (instancetype) initWithFrame:(CGRect) frame
                      OSWindow:(id <UIOSWindow>) window;
@end
```

### 3.8. `CGImage+UIImage.h`

Bridge shim that makes CGImage conform to `<UIImage>`. Its only behavioral
addition: `CAImageLayer` is set as the preferred image layer class. This is
a protocol bridge, not an image-loading API.

```objc
@interface CGImage( UIImage) <UIImage>
@end
```

### 3.9. `CGFramebuffer+UIFramebuffer.h`

Bridge shim that makes CGFramebuffer conform to `<UIFramebuffer>`. Adds no
repo-local behavior beyond protocol adoption.

```objc
@interface CGFramebuffer( UIFramebuffer) <UIFramebuffer>
@end
```

### 3.10. `CGGraphicsLayer+UILayer.h`

Bridge shim that makes CGGraphicsLayer conform to `<UILayer>`. Adds no
repo-local behavior beyond protocol adoption.

```objc
@interface CGGraphicsLayer( UILayer) <UILayer>
@end
```

### 3.11. `MulleObjCDeps+MulleUICore.h`

Loader dependency declaration for the mulle-objc runtime. **Must remain public**
because downstream libraries use it to declare their load dependencies.

```objc
@interface MulleObjCDeps( MulleUICore)

+ (struct _mulle_objc_dependency *) dependencies;

@end
```

### 3.12. Private: `UIWindow+CGFramebuffer.m`

This file has no public header. Despite the filename, the implementation
declares `@implementation CGContext( UIWindow)` — a private category on
`CGContext`, not on UIWindow. It provides one method:

```objc
- (id <UIImage>) imageWithFramebuffer:(id <UILayer>) framebuffer
                       nameUTF8String:(char *) nameUTF8String;
```

Do not confuse this file's name with its actual target class.

## 4. Performance Characteristics

### Bootstrap functions
- **Constant-time setup** — `UIApplicationRunDrawCallback` creates exactly one
  application, one window, and one layer. No iteration or complex allocation.
- **Frame rate control** — async (no limiting), VSync, or explicit interval.

### Forwarding overhead
- Properties forwarded through `<MulleObjCForwarding>` add one level of
  indirection per access. The forwarding target is the main layer, resolved
  once per property chain.
- View-level `setBackgroundColor:` etc. are `@optional` and dispatch through
  the runtime; if the main layer's class does not implement them the message
  is silently ignored.

### Thread safety
- Not thread-safe. All UI operations must occur on the main thread.
- The layout context used by `UIView+CGGraphicsLayer` is thread-local, not
  window-local.

## 5. AI Usage Recommendations & Patterns

### Best Practices

1. **Use the bootstrap functions for single-layer drawing apps.** Prefer
   `UIApplicationRunDrawCallbackHz()` — it is one call. Only drop to the
   full `UIApplication`/`UIWindow`/`UIView` path when you need retained mode,
   autoresizing, or explicit content-view setup.

2. **Put draw callbacks on the UIView, not the UIWindow.** The window
   forwarding through `UIWindow+CGGraphicsLayer` merely proxies to the
   content view and asserts without one.

3. **Enable shadows before accessing the shadow layer.** `[view shadowLayer]`
   asserts if `[view setShowsShadow:YES]` was not called first.

4. **Use direct CGColor values for window backgrounds.** The window background
   paint is monochrome-only. Gradient or patterned paints lose detail.

5. **Import via `import.h`.** The project's `import.h` (in `src/generic/`)
   brings in all necessary dependencies.

6. **Keep `MulleObjCDeps+MulleUICore.h` public.** It exists solely for
   downstream loader dependency chains.

### Common Pitfalls

1. **UIColor is NOT in this library.** It comes from a dependency
   (MulleGraphics or MulleUIWindow). Do not document or use it as a
   MulleUICore symbol.

2. **`UIWindow+CGFramebuffer.m` is named for UIWindow but the class is
   CGContext.** Do not import or use it — it has no public header.

3. **The draw callback on UIWindow assumes a content view exists.**
   Calling `[window setDrawCallback:...]` before `[window setView:...]`
   will assert.

4. **Don't rely on thread-local layout context across windows.** The layout
   context is thread-local under `"UILayoutContext"`, not window-local.

5. **Frame rate vs Hz:** `UIApplicationRunDrawCallback` takes `frameRate`
   (interval in seconds). `UIApplicationRunDrawCallbackHz` takes `hz`
   (frequency). `0.0` Hz = async, `<0.0` Hz = synced.

### Idiomatic Usage

**Minimal drawing app:**
```c
static BOOL   drawCircle( CGGraphicsLayer *layer, CGContext *context)
{
   return( YES);
}

int   main( int argc, char *argv[])
{
   return( UIApplicationRunDrawCallbackHz( drawCircle,
                                           CGSizeMake( 640, 480),
                                           "Demo",
                                           60.0));
}
```

**View with forwarded styling:**
```c
view  = [UIView viewWithLayer:[CGGraphicsLayer layerWithFrame:frame]];
[view setBackgroundColor:CGColorMakeBlue()];   // forwarded to layer
[view setBorderColor:CGColorMakeWhite()];
[view setBorderWidth:1.0];
[view setCornerRadius:8.0];
[view setMasksToBounds:YES];
```

**Shadow on a view:**
```c
[view setShowsShadow:YES];
shadowLayer = [view shadowLayer];
```

**Manual window setup:**
```c
app       = [UIApplication sharedInstance];
window    = [UIWindow windowWithFrame:frame
                     titleUTF8String:"Demo"
                           styleMask:styleMask];
view      = [UIView viewWithLayer:layer];
[view setAutoresizingMask:UIViewAutoresizingFlexibleWidth
                          |UIViewAutoresizingFlexibleHeight];
[view setDrawCallback:myDrawCallback];
[window setView:view];
[window setFrameRateHz:1.0];
[app addWindow:window];
return( [app runApp]);
```

## 6. Integration Examples

### Example 1: Minimal Single-Layer Animation

Demonstrates the shortest path to a running animated window.

```c
#import "import.h"

static BOOL   updateText( CGGraphicsLayer *layer, CGContext *context)
{
   CATextLayer   *textLayer = (CATextLayer *) layer;
   char          *s;

   mulle_buffer_do( buffer)
   {
      mulle_buffer_sprintf( buffer, "%td", [context numberOfFrames]);
      s = mulle_buffer_get_string( buffer);
      [textLayer setTextUTF8String:s];
   }
   return( YES);
}

int   main( int argc, char *argv[])
{
   return( UIApplicationRunDrawCallbackHz( updateText,
                                           CGSizeMake( 320, 320),
                                           "Counter",
                                           1.0));
}
```

### Example 2: Manual Window with Retained Mode

Shows the explicit UIApplication/UIWindow/UIView path with autoresizing.

```c
#import "import.h"

static BOOL   updateText( CGGraphicsLayer *layer, CGContext *context)
{
   CATextLayer   *textLayer = (CATextLayer *) layer;
   char          *s;

   mulle_buffer_do( buffer)
   {
      mulle_buffer_sprintf( buffer, "%td", [context numberOfFrames]);
      s = mulle_buffer_get_string( buffer);
      [textLayer setTextUTF8String:s];
   }
   return( YES);
}

int   main( int argc, char *argv[])
{
   UIWindow        *window;
   UIApplication   *app;
   CGRect          frame;
   UIView          *view;
   CATextLayer     *layer;
   NSUInteger      styleMask;

   app       = [UIApplication sharedInstance];
   frame     = CGRectMake( 0.0, 0.0, 320.0, 320.0);
   styleMask = (UIWindowStyleMaskDefault & ~UIWindowStylePlanes)
               | UIWindowStyleRetained;

   window = [UIWindow windowWithFrame:frame
                     titleUTF8String:"Demo"
                           styleMask:styleMask];

   layer = [CATextLayer layerWithFrame:frame];
   [layer setBackgroundColor:CGColorMakeBlue()];
   [layer setTextBackgroundColor:CGColorMakeBlue()];
   [layer setTextColor:CGColorMakeWhite()];
   [layer setTextUTF8String:"0"];
   [layer setTextAlignment:UITextAlignmentCenter];

   view = [UIView viewWithLayer:layer];
   [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth
                             |UIViewAutoresizingFlexibleHeight];
   [view setDrawCallback:updateText];

   [window setView:view];
   [window setFrameRateHz:1.0];
   [app addWindow:window];

   return( [app runApp]);
}
```

### Example 3: View Styling via Forwarding

Demonstrates that UIView-level visual properties are forwarded to the layer.

```c
#import "import.h"

int   main( int argc, char *argv[])
{
   UIApplication   *app;
   UIWindow        *window;
   UIView          *view;
   CGGraphicsLayer *layer;
   CGRect          frame;

   app   = [UIApplication sharedInstance];
   frame = CGRectMake( 0, 0, 400, 300);

   layer = [CGGraphicsLayer layerWithFrame:frame];
   view  = [UIView viewWithLayer:layer];

   [view setBorderColor:CGColorMakeOrange()];
   [view setBorderWidth:5.0];
   [view setCornerRadius:12.0];
   [view setOpacity:0.8];
   [view setMasksToBounds:YES];

   window = [UIWindow windowWithFrame:frame
                      titleUTF8String:"Styled View"
                            styleMask:UIWindowStyleMaskDefault];
   [window setView:view];
   [window setFrameRateHz:60.0];
   [app addWindow:window];

   return( [app runApp]);
}
```

### Example 4: Shadow Layer

Shows opt-in shadow on a UIView.

```c
#import "import.h"

int   main( int argc, char *argv[])
{
   UIApplication   *app;
   UIWindow        *window;
   UIView          *view;
   CAShadowLayer   *shadowLayer;
   CGRect          frame;

   app   = [UIApplication sharedInstance];
   frame = CGRectMake( 0, 0, 300, 300);

   view = [UIView viewWithFrame:frame];
   [view setShowsShadow:YES];

   shadowLayer = [view shadowLayer];
   [shadowLayer setShadowColor:CGColorMakeBlack()];
   [shadowLayer setShadowOffset:CGSizeMake( 4, 4)];
   [shadowLayer setShadowBlur:8.0];
   [shadowLayer setShadowOpacity:0.5];

   window = [UIWindow windowWithFrame:frame
                      titleUTF8String:"Shadow Demo"
                            styleMask:UIWindowStyleMaskDefault];
   [window setView:view];
   [app addWindow:window];

   return( [app runApp]);
}
```

## 7. Dependencies

Direct mulle-sde dependencies from sourcetree config:

- **MulleUIWindow** — provides UIWindow, UIView, UIApplication, and the
  base window/view/layer hierarchy
- **MulleGraphics** — provides CALayer subclasses (CGGraphicsLayer,
  CATextLayer, CAShadowLayer, CAImageLayer, CGFramebuffer) and CG types
  (CGColor, CGPaint, CGContext, CGImage, CGSize, CGRect, etc.)
- **mulle-objc-list** — build-time dependency for Objective-C class listing
  (marked no-all-load, no-header, no-link, no-singlephase)

Transitively through MulleUIWindow and MulleGraphics, the following are
also available: MulleObjC (runtime), mulle-core (foundational C libraries),
MulleCG, MulleCA, MulleGLFW, mulle-gfx (nanovg integration), mulle-freetype,
MulleThread, and others.
