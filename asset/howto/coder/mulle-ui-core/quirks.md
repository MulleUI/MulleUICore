<!-- keywords: quirks, init, forwarding, shadow, color, bridge, private -->
# quirks

## Bootstrap and frame-rate quirks

- `UIApplicationRunDrawCallbackHz()` converts hertz to a frame interval. `0.0` means `UIWindowFrameRateAsync`, values below `0.0` mean `UIWindowFrameRateSynced`, and positive values become `1.0f / hz`. See `src/UIApplication+UIWindow.h`.
- `UIApplicationRunDrawCallback()` uses `canvasSize` as the fallback window size and then falls back to `640x400`. When `canvasSize` is set, it also overwrites the layer `bounds` and `canvas`. See `src/UIApplication+UIWindow.m`.
- The helper path always clears `UIWindowStylePlanes` and forces `UIWindowStyleInputPolling`. If you need planes or no polling, do not use the helper path. See `src/UIApplication+UIWindow.m`.
- Manual setup still needs `[UIApplication sharedInstance]` before window creation; the helper does this for you because it initializes the backend first. See `src/UIApplication+UIWindow.m` and `demo/src/main-refresh.m`.

## View and window forwarding quirks

- `UIView` does not keep a separate draw callback or visual state here. `drawCallback`, border/background settings, opacity, rotation, masks, and related styling are forwarded to the main layer. See `src/UIView+CGGraphicsLayer.h`.
- `+layerClass` is hard-wired to `CGGraphicsLayer`. If you change the default layer story, audit the whole forwarding category. See `src/UIView+CGGraphicsLayer.m`.
- `UIWindow` stores no independent draw callback either; `[window setDrawCallback:...]` forwards to `[self contentView]` and asserts if there is no content view. See `src/UIWindow+CGGraphicsLayer.m`.
- The layout context in this repo is thread-local under the `"UILayoutContext"` key, not window-local. Code that assumes one layout context per window will be wrong. See `src/UIView+CGGraphicsLayer.m`.

## Visual helper quirks

- `[view shadowLayer]` asserts until `[view setShowsShadow:YES]` has created the helper layer. See `src/UIView+CAShadowLayer.h` and `src/UIView+CAShadowLayer.m`.
- Shadow layout extrudes the frame by `shadowInsets`, so the shadow can extend outside the view's nominal rect. See `src/UIView+CAShadowLayer.m`.
- `UIWindow` background paint is effectively monochrome. The header says so, and the implementation stores only `_backgroundHexColor` or `[paint mainColor]`. Gradient or patterned paints lose detail. See `src/UIWindow+CGColor.h` and `src/UIWindow+CGColor.m`.
- `demo/src/main-refresh.m` leaves `setTextVerticalAlignment:UITextAlignmentVisualMiddle` commented as "broken apparently"; do not rely on that path without rechecking current upstream behavior.

## CG/UI bridge quirks

- `CGImage(UIImage)` only selects `CAImageLayer` as the preferred image layer. It is a bridge hook, not an image loading API. See `src/CGImage+UIImage.h` and `src/CGImage+UIImage.m`.
- `CGFramebuffer(UIFramebuffer)` and `CGGraphicsLayer(UILayer)` exist to satisfy protocols. They do not add repo-local behavior beyond that protocol presence. See `src/CGFramebuffer+UIFramebuffer.h`, `src/CGFramebuffer+UIFramebuffer.m`, `src/CGGraphicsLayer+UILayer.h`, and `src/CGGraphicsLayer+UILayer.m`.
- `CALayer initWithFrame:OSWindow:` ignores the `OSWindow` argument and just calls `initWithFrame:`. Do not assume window-specific layer initialization happens there. See `src/CALayer+UIOSWindow.m`.
- Keep `src/MulleObjCDeps+MulleUICore.h` public. Its only job is loader dependency exposure for downstream libraries, but removing or privatizing it breaks that contract.

## Private-category naming inconsistency

- `src/UIWindow+CGFramebuffer.m` is named as a UIWindow category, but the implementation declares `@implementation CGContext( UIWindow)` — a private category on `CGContext`, not on `UIWindow`. Do not confuse this file's name with its actual target class. See `src/UIWindow+CGFramebuffer.m`.
- That file also lacks a public header. It is an internal helper, not part of the public API surface.
