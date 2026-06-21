<!-- keywords: drawcallback, shadowlayer, layoutcontext, backgroundpaint, loader -->
# mulle-ui-core

Use this topic when you are verifying or debugging app code that uses MulleUICore's convenience layer around `UIApplication`, `UIWindow`, `UIView`, `CALayer`, and the small CG/UI bridge categories in `src/`.

There are no repo-local `MULLE_*_TRACE` switches, dump helpers, or debug-only support classes in this repo's public surface. Use the shared mulle-sde debug howto for generic `-DDEBUG`, sanitizer, and debugger workflow, then use the local checkpoints below.

## Understand first

```bash
mulle-sde howto cat debug
mulle-sde api apropos mulle-ui-core UIWindow UIView CALayer CGGraphicsLayer CGFramebuffer CGImage
mulle-sde api cat MulleUIApplication
mulle-sde api cat MulleUIWindow
mulle-sde api cat MulleUIView
mulle-sde code search UIApplicationRunDrawCallback
mulle-sde code search shadowLayer
mulle-sde code search preferredImageLayerClass
```

## Local references

- `README.md`
- `asset/dox/TOC.md`
- `src/MulleUICore.h`
- `src/UIApplication+UIWindow.h`
- `src/UIApplication+UIWindow.m`
- `src/UIWindow+CGGraphicsLayer.h`
- `src/UIWindow+CGGraphicsLayer.m`
- `src/UIView+CGGraphicsLayer.h`
- `src/UIView+CGGraphicsLayer.m`
- `src/UIView+CAShadowLayer.h`
- `src/UIView+CAShadowLayer.m`
- `src/UIWindow+CGColor.h`
- `src/UIWindow+CGColor.m`
- `src/CALayer+UIOSWindow.m`
- `src/CGImage+UIImage.m`
- `src/CGFramebuffer+UIFramebuffer.m`
- `src/CGGraphicsLayer+UILayer.m`
- `src/MulleObjCDeps+MulleUICore.h`
- `demo/src/main-refresh.m`
- `demo/src/main-glfw-boing.m`

## Main verification surfaces

| Symptom | Inspect first | Local delta |
| --- | --- | --- |
| Helper-path app behaves differently from manual setup | `src/UIApplication+UIWindow.h`, `src/UIApplication+UIWindow.m`, `demo/src/main-refresh.m` | `UIApplicationRunDrawCallback...` creates one `CGGraphicsLayer`, calls `[UIApplication sharedInstance]`, falls back to `640x400`, clears `UIWindowStylePlanes`, and enables `UIWindowStyleInputPolling`. |
| `[window setDrawCallback:...]` or basic view styling behaves oddly | `src/UIWindow+CGGraphicsLayer.m`, `src/UIView+CGGraphicsLayer.h`, `src/UIView+CGGraphicsLayer.m` | Window draw callback is only forwarded to `contentView`; `UIView` hard-wires `+layerClass` to `CGGraphicsLayer`; layout context is thread-local under `"UILayoutContext"`. |
| Shadow or clipping looks wrong | `src/UIView+CAShadowLayer.h`, `src/UIView+CAShadowLayer.m` | `shadowLayer` asserts until `setShowsShadow:YES` created it, and shadow layout expands the rect with `shadowInsets`. |
| Window background paint loses gradients/patterns | `src/UIWindow+CGColor.h`, `src/UIWindow+CGColor.m` | Window background storage is reduced to `_backgroundHexColor`; `setBackgroundPaint:` keeps only `[paint mainColor]`. |
| Image/framebuffer/layer bridge behavior feels missing | `src/CGImage+UIImage.m`, `src/CGFramebuffer+UIFramebuffer.m`, `src/CGGraphicsLayer+UILayer.m`, `src/CALayer+UIOSWindow.m` | These categories are mostly protocol glue. `preferredImageLayerClass` returns `CAImageLayer`, `CGFramebuffer`/`CGGraphicsLayer` add almost no behavior, and `initWithFrame:OSWindow:` ignores the `OSWindow` argument. |
| Downstream load-order or startup issues | `src/MulleObjCDeps+MulleUICore.h` | The public loader-deps category is part of the contract for dependent libraries. |

## Local workflow

- Start with the shared mulle-sde debug workflow; this repo adds local invariants, not extra tracing infrastructure.
- Reproduce MulleUICore-level failures first in `demo/src/main-refresh.m`. That demo is the normal retained-view path: shared app, explicit `UIWindow`, explicit `UIView`, and a view draw callback.
- Use `UIApplicationRunDrawCallback...` when you need to check the single-layer bootstrap path separately from retained-mode window/view wiring.
- Use `demo/src/main-glfw-boing.m` as the below-MulleUICore comparison. A bug that only reproduces there is likely lower than this repo's convenience layer.

## Verify and report

- Say explicitly that this repo exposed no extra trace environment variables or dump helpers for the failing case.
- Say which family failed: bootstrap helper, content-view forwarding, thread-local layout context, shadow helper, background-color collapse, or thin bridge/loader glue.
- Say whether the repro used `UIApplicationRunDrawCallback...` or the manual `UIApplication`/`UIWindow`/`UIView` setup.
- Cite the exact `src/...` or `demo/src/...` path that proved the local rule.
