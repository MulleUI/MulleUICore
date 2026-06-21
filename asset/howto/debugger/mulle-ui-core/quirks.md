<!-- keywords: debugger, quirks, mulle-ui-core, drawcallback, shadowlayer, cgcolor, bridge -->
# quirks

## Bootstrap quirks

- `UIApplicationRunDrawCallbackHz()` converts hertz to the frame interval expected by `UIApplicationRunDrawCallback()`: `0.0` means async, values below `0.0` mean synced, positive values become `1.0f / hz`. See `src/UIApplication+UIWindow.h`.
- `UIApplicationRunDrawCallback()` falls back from `windowSize` to `canvasSize` to `640x400`, and when `canvasSize` is non-zero it overwrites both layer `bounds` and `canvas`. See `src/UIApplication+UIWindow.m`.
- The helper path always clears `UIWindowStylePlanes` and enables `UIWindowStyleInputPolling`. If planes or no polling matter, do not debug through the helper path alone. See `src/UIApplication+UIWindow.m`.
- The helper also calls `[UIApplication sharedInstance]` for backend setup; manual repros need to do the same first. See `src/UIApplication+UIWindow.m` and `demo/src/main-refresh.m`.

## Forwarding and layout quirks

- `UIWindow` does not own a separate draw callback here. `[window setDrawCallback:...]` asserts unless `contentView` already exists, then forwards to the content view. See `src/UIWindow+CGGraphicsLayer.m`.
- `UIView+CGGraphicsLayer.h` advertises main-layer forwarding, but the repo-local implementation in `src/UIView+CGGraphicsLayer.m` only changes `+layerClass` and `layoutContext`. If a forwarded visual property misbehaves, expect the interesting behavior to be below this repo's tiny convenience layer.
- `+layerClass` is hard-wired to `CGGraphicsLayer`. If a view unexpectedly has some other main layer, the category probably is not in play. See `src/UIView+CGGraphicsLayer.m`.
- The layout context is thread-local under the `"UILayoutContext"` key, not window-local. Cross-thread layout/debug sessions can pick up the wrong context silently. See `src/UIView+CGGraphicsLayer.m`.

## Visual-helper quirks

- `[view shadowLayer]` asserts until `[view setShowsShadow:YES]` has created `_shadowLayer`. See `src/UIView+CAShadowLayer.h` and `src/UIView+CAShadowLayer.m`.
- Shadow frames are extruded with `shadowInsets`, so clipped-looking shadows may actually be a parent-bounds issue, not a shadow-rendering issue. See `src/UIView+CAShadowLayer.m`.
- `UIWindow` background paint is effectively monochrome: `backgroundColor` stores one hex color and `backgroundPaint` keeps only `mainColor`. See `src/UIWindow+CGColor.h` and `src/UIWindow+CGColor.m`.
- `demo/src/main-refresh.m` leaves `setTextVerticalAlignment:UITextAlignmentVisualMiddle` commented as "broken apparently"; treat text-vertical-alignment failures as suspect until rechecked against current dependencies.

## Bridge and boundary quirks

- `CGImage(UIImage)` is only the preferred-layer hook to `CAImageLayer`; it is not an image-loading or decoding surface. See `src/CGImage+UIImage.m`.
- `CGFramebuffer(UIFramebuffer)` and `CGGraphicsLayer(UILayer)` mostly exist so protocol checks succeed at runtime. Missing behavior is often in the underlying CG/UI classes, not these categories. See `src/CGFramebuffer+UIFramebuffer.m` and `src/CGGraphicsLayer+UILayer.m`.
- `CALayer initWithFrame:OSWindow:` ignores the `OSWindow` argument. Do not assume that passing a window there wires graphics state or ownership. See `src/CALayer+UIOSWindow.m`.
- `demo/src/main-glfw-boing.m` is intentionally below MulleUICore. A bug that reproduces there but not in `demo/src/main-refresh.m` is probably outside the convenience layer covered by this topic.
- Keep `src/MulleObjCDeps+MulleUICore.h` public; downstream load-order/debugging breaks if that contract disappears.
