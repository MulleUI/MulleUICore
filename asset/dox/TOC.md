# MulleUIWidgetsBase Library Documentation for AI
<!-- Keywords: UI, desktop, mobile, convenience, wrapper, objective-c -->

## 1. Introduction & Purpose

MulleUIWidgetsBase is a high-level convenience library that provides a simplified entry point for developing user interface applications with mulle-objc. It sits atop the MulleUIOS framework and provides an easy-to-use API for creating desktop and mobile user interfaces. The library serves as the main starting point for MulleUIWidgetsBase development, offering streamlined access to window creation, view layout, event handling, drawing operations, and animations.

MulleUIWidgetsBase is part of the mulle-objc ecosystem and depends on MulleUIOS as its core foundation. It provides factory classes and convenience functions that simplify common UI tasks while leveraging the underlying graphics capabilities provided by nanovg through the MulleUIOS stack.

## 2. Key Concepts & Design Philosophy

### Simplified API Surface
MulleUIWidgetsBase's primary design goal is to reduce boilerplate and provide the simplest possible API for common UI tasks. It wraps the more complex MulleUIOS APIs with convenience methods and factory patterns.

### Color as Values, Not Objects
Unlike many UI frameworks, MulleUIWidgetsBase treats colors as lightweight CGColor values rather than heavyweight objects. The UIColor class is a factory that produces CGColor structs (which map to nanovg color structs), making color operations efficient and avoiding unnecessary object allocation overhead.

### Convenience Functions Over Class Hierarchies
The library provides C convenience functions like `UIApplicationRunDrawCallback()` that encapsulate entire application lifecycles, allowing developers to write simple drawing applications with minimal setup code.

### Integration with mulle-objc Patterns
MulleUIWidgetsBase follows mulle-objc conventions, including the use of UTF8String methods for string handling, proper memory management patterns, and the avoidance of alloc/init outside of -init methods.

## 3. Core API & Data Structures

### 3.1. `MulleUIWidgetsBase.h`

This is the main umbrella header that provides version information and includes all necessary dependencies.

#### Version Information
- **`MulleUI_get_version()`**: Returns the complete version as a uint32_t.
- **`MulleUI_get_version_major()`**: Returns the major version number.
- **`MulleUI_get_version_minor()`**: Returns the minor version number.
- **`MulleUI_get_version_patch()`**: Returns the patch version number.
- **`MULLE_UI_VERSION`**: Compile-time version constant encoded as ((major << 20) | (minor << 8) | patch).

### 3.2. `UIColor.h`

UIColor is a factory class for creating CGColor values (nanovg color structs). It is not meant to be instantiated.

#### Standard Color Factory Methods
- **`+ (CGColor) blackColor`**: Returns black color (#000000FF).
- **`+ (CGColor) whiteColor`**: Returns white color (#FFFFFFFF).
- **`+ (CGColor) redColor`**: Returns red color (#FF0000FF).
- **`+ (CGColor) greenColor`**: Returns green color (#00FF00FF).
- **`+ (CGColor) blueColor`**: Returns blue color (#0000FFFF).
- **`+ (CGColor) grayColor`**: Returns medium gray (#7F7F7FFF).
- **`+ (CGColor) darkGrayColor`**: Returns dark gray (#3F3F3FFF).
- **`+ (CGColor) lightGrayColor`**: Returns light gray (#BFBFBFFF).
- **`+ (CGColor) yellowColor`**: Returns yellow color (#FFFF00FF).
- **`+ (CGColor) magentaColor`**: Returns magenta color (#FF00FFFF).
- **`+ (CGColor) brownColor`**: Returns brown color (#8F5F2FFF).
- **`+ (CGColor) cyanColor`**: Returns cyan color (#00FFFFFF).
- **`+ (CGColor) orangeColor`**: Returns orange color (#FF7F00FF).
- **`+ (CGColor) purpleColor`**: Returns purple color (#7F007FFF).

#### Special Colors
- **`+ (CGColor) underPageBackgroundColor`**: Returns a special gray color for backgrounds (#6B716FFF).

#### Custom Colors
- **`+ (CGColor) colorWithCGColor:(CGColor) cgColor`**: Pass-through method that returns the provided CGColor.
- **`+ (CGColor) colorWithUTF8String:(char *) name`**: Creates a color from a string name by delegating to `CGColorMakeWithUTF8String()`.

**Important:** UIColor cannot be instantiated. Attempting to call `alloc` or `init` will trigger an assertion failure. All methods are class methods that return CGColor values.

### 3.3. `UIApplication+UIWindow.h`

Provides high-level C functions for running simple UI applications with minimal boilerplate.

#### Application Lifecycle Functions

##### `UIApplicationRunDrawCallback()`
```c
int UIApplicationRunDrawCallback( CGGraphicsLayerDrawCallback_t *callback,
                                  CGSize windowSize,
                                  CGSize canvasSize,
                                  char *title,
                                  CGFloat frameRate)
```
Creates a complete application with a window containing a graphics layer with the specified draw callback. This is the lowest-level convenience function.

**Parameters:**
- `callback`: Drawing callback function pointer.
- `windowSize`: Size of the window (defaults to 640x400 if zero).
- `canvasSize`: Size of the drawing canvas (defaults to windowSize if zero).
- `title`: Window title as UTF-8 string.
- `frameRate`: Frame rate control (use `UIWindowFrameRateAsync`, `UIWindowFrameRateSynced`, or a specific rate).

**Returns:** Exit code from the application run loop.

##### `UIApplicationRunDrawCallbackHz()` (inline)
```c
static inline int UIApplicationRunDrawCallbackHz( CGGraphicsLayerDrawCallback_t *callback,
                                                  CGSize windowSize,
                                                  char *title,
                                                  CGFloat hz)
```
Even simpler variant that takes a frequency in Hertz and enables mouse polling automatically.

**Parameters:**
- `callback`: Drawing callback function pointer.
- `windowSize`: Size of the window.
- `title`: Window title as UTF-8 string.
- `hz`: Refresh frequency (0.0 for async, negative for synced, positive for specific Hz).

**Returns:** Exit code from the application run loop.

**Note:** This inline function converts Hz to frameRate and automatically enables mouse polling by setting appropriate style masks.

#### Frame Rate Constants
- **`UIWindowFrameRateAsync`**: Run asynchronously without frame rate limiting.
- **`UIWindowFrameRateSynced`**: Sync to display refresh rate (VSync).

### 3.4. `MulleObjCLoader+MulleUIWidgetsBase.h`

Provides the loader interface for the MulleUIWidgetsBase library in the mulle-objc runtime.

#### MulleObjCLoader Category
- **`+ (struct _mulle_objc_dependency *) dependencies`**: Returns the dependency information for proper library loading order in the mulle-objc runtime.

This header is required to be public to allow other libraries that depend on MulleUIWidgetsBase to properly declare their load dependencies.

## 4. Performance Characteristics

### Color Operations
- **O(1)** - All UIColor factory methods return colors in constant time by using compile-time constants with `CGColorMakeWithHexColor()`.
- **No allocation** - Colors are value types (structs), not heap-allocated objects, eliminating GC overhead.

### Application Lifecycle
- **Minimal overhead** - The convenience functions `UIApplicationRunDrawCallback()` create only the essential objects needed for the application to run (one layer, one window, one application instance).
- **Frame rate control** - Applications can run in async mode (no frame limiting), VSync mode (display synchronized), or at a specific frame rate.

### Thread Safety
- MulleUIWidgetsBase follows the standard mulle-objc pattern: **not thread-safe by default**. All UI operations should occur on the main thread.
- The underlying MulleUIOS framework handles platform-specific threading for window and event management.

## 5. AI Usage Recommendations & Patterns

### Best Practices

1. **Use UIColor as a Factory, Never Instantiate**: Always call class methods on UIColor. Never attempt to create UIColor instances with `alloc` or `init`.

2. **Prefer Convenience Functions for Simple Applications**: For simple drawing applications, use `UIApplicationRunDrawCallbackHz()` instead of manually creating UIApplication, UIWindow, and UIView hierarchies.

3. **Import Properly**: Use `#import "import.h"` in source files to get all necessary dependencies. The `import.h` header automatically includes MulleUIOS and all required headers.

4. **Use UTF8String Methods**: All string methods in MulleUIWidgetsBase use UTF-8 encoding. Use methods like `titleUTF8String:` rather than NSString-based APIs for better performance.

5. **Follow mulle-buffer Patterns**: Use `mulle_buffer_do()` macro for automatic buffer cleanup when working with temporary string buffers.

6. **Set Frame Rates Appropriately**: 
   - Use 0.0 Hz (async) for event-driven applications that only redraw when needed.
   - Use negative Hz (synced) for smooth animations that should match the display refresh rate.
   - Use specific Hz values (e.g., 1.0, 30.0, 60.0) for controlled update rates.

### Common Pitfalls

1. **Don't Mix Color Objects and Values**: UIColor returns CGColor values, not objects. Don't try to retain, release, or store them in object collections. Use NSValue if you need to wrap them.

2. **Don't Forget Shared Instance**: Always get `[UIApplication sharedInstance]` before creating windows to ensure proper initialization of the underlying graphics system (GLFW/SDL).

3. **Avoid Direct Instantiation**: Don't use `[[UIColor alloc] init]` - it will fail with an assertion. This is by design.

4. **Frame Rate vs Hz Confusion**: Remember that frameRate is the interval (1/Hz), while Hz is the frequency. The convenience function `UIApplicationRunDrawCallbackHz()` takes Hz and converts it properly.

### Idiomatic Usage

**Minimal Application Pattern:**
```objective-c
// Use the convenience function for simple drawing apps
int main( int argc, char *argv[])
{
   return( UIApplicationRunDrawCallbackHz( myDrawFunction,
                                          CGSizeMake( 640, 480),
                                          "My App",
                                          60.0));  // 60 Hz refresh
}
```

**Standard Application Pattern:**
```objective-c
// More control over window and view setup
int main( int argc, char *argv[])
{
   UIApplication   *app;
   UIWindow        *window;
   UIView          *view;
   CALayer         *layer;
   
   app = [UIApplication sharedInstance];
   
   layer = [CATextLayer layerWithFrame:CGRectMake( 0, 0, 320, 240)];
   [layer setBackgroundColor:[UIColor blueColor]];
   
   view = [UIView viewWithLayer:layer];
   
   window = [UIWindow windowWithFrame:CGRectMake( 0, 0, 320, 240)
                      titleUTF8String:"Demo"
                            styleMask:UIWindowStyleMaskDefault];
   [window setView:view];
   [window setFrameRateHz:60.0];
   
   [app addWindow:window];
   return( [app runApp]);
}
```

**Color Usage Pattern:**
```objective-c
// Always use class methods
CGColor blue = [UIColor blueColor];
CGColor customColor = [UIColor colorWithUTF8String:"#FF8800FF"];

[layer setBackgroundColor:blue];
[layer setTextColor:customColor];

// Don't wrap in objects unless necessary
// If needed for collections, use NSValue
NSValue *colorValue = [NSValue valueWithBytes:&blue
                                      objCType:@encode(CGColor)];
```

## 6. Integration Examples

### Example 1: Minimal Animation Counter

This example demonstrates the simplest way to create an animated UI that updates once per second.

```c
#import "import.h"

static BOOL   updateText( CGGraphicsLayer *layer, CGContext *context)
{
   CATextLayer   *textLayer;
   char          *s;

   textLayer = (CATextLayer *) layer;
   
   mulle_buffer_do( buffer)
   {
      mulle_buffer_sprintf( buffer, "%td", [context numberOfFrames]);
      s  = mulle_buffer_get_string( buffer);
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

   app     = [UIApplication sharedInstance];
   frame   = CGRectMake( 0.0, 0.0, 320.0, 320.0);
   
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

### Example 2: Using Color Factory Methods

This example shows how to use UIColor as a factory for various colors.

```c
#import "import.h"

int   main( int argc, char *argv[])
{
   UIApplication   *app;
   UIWindow        *window;
   UIView          *view;
   CALayer         *layer;
   CGRect          frame;

   app   = [UIApplication sharedInstance];
   frame = CGRectMake( 0, 0, 400, 300);

   layer = [CALayer layerWithFrame:frame];
   
   // Use standard color factories
   [layer setBackgroundColor:[UIColor darkGrayColor]];
   [layer setBorderColor:[UIColor orangeColor]];
   [layer setBorderWidth:5.0];
   
   view = [UIView viewWithLayer:layer];
   
   window = [UIWindow windowWithFrame:frame
                      titleUTF8String:"Color Demo"
                            styleMask:UIWindowStyleMaskDefault];
   [window setView:view];
   [window setFrameRateHz:60.0];
   
   [app addWindow:window];
   
   return( [app runApp]);
}
```

### Example 3: Ultra-Simple Drawing Application

This example demonstrates the absolute minimal code needed to create a drawing application using the convenience function.

```c
#import "import.h"

static BOOL   drawCircle( CGGraphicsLayer *layer, CGContext *context)
{
   CGRect   bounds;
   
   bounds = [layer bounds];
   
   // Draw a circle in the center
   CGContextBeginPath( context);
   CGContextCircle( context, 
                   bounds.size.width / 2.0,
                   bounds.size.height / 2.0,
                   100.0);
   CGContextSetFillColor( context, [UIColor redColor]);
   CGContextFill( context);
   
   return( YES);
}


int   main( int argc, char *argv[])
{
   return( UIApplicationRunDrawCallbackHz( drawCircle,
                                          CGSizeMake( 640, 480),
                                          "Circle Demo",
                                          0.0));  // async, no animation
}
```

### Example 4: Custom Color with String

This example shows how to create custom colors from string specifications.

```c
#import "import.h"

int   main( int argc, char *argv[])
{
   UIApplication   *app;
   UIWindow        *window;
   UIView          *view;
   CATextLayer     *textLayer;
   CGRect          frame;
   CGColor         customBg;
   CGColor         customFg;

   app   = [UIApplication sharedInstance];
   frame = CGRectMake( 0, 0, 500, 200);

   // Create custom colors from hex strings
   customBg = [UIColor colorWithUTF8String:"#2C3E50"];
   customFg = [UIColor colorWithUTF8String:"#ECF0F1"];

   textLayer = [CATextLayer layerWithFrame:frame];
   [textLayer setBackgroundColor:customBg];
   [textLayer setTextColor:customFg];
   [textLayer setTextUTF8String:"Custom Colors"];
   [textLayer setTextAlignment:UITextAlignmentCenter];
   
   view = [UIView viewWithLayer:textLayer];
   
   window = [UIWindow windowWithFrame:frame
                      titleUTF8String:"Custom Color Demo"
                            styleMask:UIWindowStyleMaskDefault];
   [window setView:view];
   
   [app addWindow:window];
   
   return( [app runApp]);
}
```

## 7. Dependencies

MulleUIWidgetsBase has the following direct dependencies within the mulle-sde ecosystem:

- **MulleUIOS**: The core UI framework that provides UIWindow, UIView, UIEvent, CALayer, CAAnimation, UIApplication, and all the underlying graphics capabilities through nanovg integration.

- **mulle-objc-list**: Build-time dependency for Objective-C class listing (marked as no-link, no-header).

MulleUIOS itself transitively depends on many other libraries including:
- MulleObjC (Objective-C runtime)
- mulle-core (foundational C libraries)
- MulleGraphics, MulleCG, MulleCA (graphics and Core Animation)
- MulleGLFW (window management via GLFW)
- mulle-gfx (nanovg integration)
- Various support libraries (mulle-freetype, MulleThread, etc.)

However, as a MulleUIWidgetsBase user, you typically only need to be aware of MulleUIWidgetsBase and MulleUIOS, as the build system automatically handles transitive dependencies.
