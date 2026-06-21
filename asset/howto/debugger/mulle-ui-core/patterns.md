<!-- keywords: debugger, patterns, mulle-ui-core, drawcallback, uiwindow, uiview, cggraphicslayer -->
# patterns

## Split helper-path bugs from retained-view bugs

Start by deciding whether the failure is in the one-layer bootstrap helper or in normal content-view wiring.

- `src/UIApplication+UIWindow.m` is the helper path: it creates one `CGGraphicsLayer`, optionally rewrites `bounds` and `canvas`, forces `UIWindowStylePlanes` off, and forces mouse polling on.
- `demo/src/main-refresh.m` is the retained-view path: shared app, explicit `UIWindow`, explicit `UIView`, and the callback installed on the view.
- If the bug reproduces only on the helper path, inspect the helper's style-mask and canvas setup before digging into view hierarchy code.

## Chase draw callbacks through the forwarding chain

`UIWindow` is not an independent draw-callback owner here.

```objective-c
view = [UIView viewWithLayer:layer];
[view setDrawCallback:updateText];
[window setView:view];
```

- `src/UIWindow+CGGraphicsLayer.m` forwards `drawCallback` to `[self contentView]`.
- A window-side callback failure usually means there is no content view yet, or the content view's main layer is not the layer you think it is.
- Repro code in `demo/src/main-refresh.m` is the local reference shape.

## Debug view styling on the main layer, not on a parallel view state

`src/UIView+CGGraphicsLayer.h` documents border/background/opacity/rotation/masks as main-layer forwarding.

- When border, background, opacity, or rotation looks wrong, inspect the main `CGGraphicsLayer` first.
- `src/UIView+CGGraphicsLayer.m` changes two local things that matter during debugging: `+layerClass` is fixed to `CGGraphicsLayer`, and `layoutContext` is pulled from the thread-local `"UILayoutContext"` key.
- If the wrong thread is driving layout or drawing, the wrong layout context is a plausible local cause.

## Debug shadow issues as helper-layer lifecycle problems

`src/UIView+CAShadowLayer.h` is opt-in shadow support.

```objective-c
[view setShowsShadow:YES];
shadow = [view shadowLayer];
```

- `src/UIView+CAShadowLayer.m` allocates the helper layer only when `setShowsShadow:YES` runs.
- `shadowLayer` asserts if you ask for it too early.
- Shadow layout extrudes the rect with `shadowInsets`, so overflow outside the nominal view frame is expected.

## Separate window-background bugs from content-layer bugs

`src/UIWindow+CGColor.h` is only for the window's solid background paint.

- `setBackgroundColor:` stores `_backgroundHexColor`.
- `setBackgroundPaint:` keeps only `[paint mainColor]`.
- If a gradient or patterned paint seems to disappear, that is the local contract; debug the content view or layer instead if you need richer visuals.

## Treat the bridge categories as protocol glue checkpoints

- `src/CGImage+UIImage.m` only fixes `CAImageLayer` as the preferred image-layer class.
- `src/CGFramebuffer+UIFramebuffer.h` and `src/CGGraphicsLayer+UILayer.h` are protocol-attachment shims; they add almost no behavior of their own.
- `src/CALayer+UIOSWindow.m` ignores the `OSWindow:` argument and just calls `initWithFrame:`. If you expected window-specific layer initialization, the bug is elsewhere.
- `src/MulleObjCDeps+MulleUICore.h` is public loader glue for downstream libraries; linkage/load-order bugs belong there, not in drawing code.
