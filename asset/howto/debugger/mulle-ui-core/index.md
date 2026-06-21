<!-- keywords: debugger, mulle-ui-core, uiwindow, uiview, calayer, cggraphicslayer, cgimage, cgframebuffer -->
# mulle-ui-core

Use this topic when you are debugging MulleUICore's convenience layer around `UIApplication`, `UIWindow`, `UIView`, `CALayer`, and the small CG/UI bridge categories in `src/`.

## Understand first

```bash
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
- `src/UIView+CGGraphicsLayer.h`
- `src/UIView+CGGraphicsLayer.m`
- `src/UIView+CAShadowLayer.h`
- `src/UIView+CAShadowLayer.m`
- `src/UIWindow+CGGraphicsLayer.h`
- `src/UIWindow+CGGraphicsLayer.m`
- `src/UIWindow+CGColor.h`
- `src/UIWindow+CGColor.m`
- `src/CALayer+UIOSWindow.h`
- `src/CALayer+UIOSWindow.m`
- `src/CGImage+UIImage.h`
- `src/CGImage+UIImage.m`
- `src/CGFramebuffer+UIFramebuffer.h`
- `src/CGFramebuffer+UIFramebuffer.m`
- `src/CGGraphicsLayer+UILayer.h`
- `src/CGGraphicsLayer+UILayer.m`
- `src/MulleObjCDeps+MulleUICore.h`
- `demo/src/main-refresh.m`
- `demo/src/main-glfw-boing.m`

## Main debug surfaces

| Symptom | Inspect first | Local delta |
| --- | --- | --- |
| Window comes up, but callback-driven content is wrong | `src/UIApplication+UIWindow.h`, `src/UIApplication+UIWindow.m`, `demo/src/main-refresh.m` | The helper path creates one `CGGraphicsLayer`, disables planes, enables mouse polling, and runs through a window helper. |
| `[window setDrawCallback:...]` or view styling behaves oddly | `src/UIWindow+CGGraphicsLayer.m`, `src/UIView+CGGraphicsLayer.h`, `src/UIView+CGGraphicsLayer.m` | The window callback is only a forwarder to `contentView`; view visual state is documented as main-layer state. |
| Background color/paint looks flattened | `src/UIWindow+CGColor.h`, `src/UIWindow+CGColor.m` | Window background storage is reduced to one hex color or `paint mainColor`. |
| Shadow/image/framebuffer behavior looks missing | `src/UIView+CAShadowLayer.m`, `src/CGImage+UIImage.m`, `src/CGFramebuffer+UIFramebuffer.m`, `src/CGGraphicsLayer+UILayer.m` | These are opt-in helpers or thin protocol bridges, not large subsystems. |

## Local workflow

- Reproduce first in `demo/src/main-refresh.m` when the bug is on the normal MulleUICore path: shared app, retained window, content view, `CATextLayer`, and a draw callback on the view.
- Use `src/UIApplication+UIWindow.m` when the repro is a single callback surface. That helper bakes in style-mask choices, so debug those choices before blaming deeper rendering code.
- Use `demo/src/main-glfw-boing.m` as the below-MulleUICore comparison. It talks to `GLFWOSWindow` directly, so a bug that only exists there is likely below this repo's convenience layer.
- There are no repo tests here; the demos are the concrete live repro surfaces.

## Verify and report

- Say which family failed: bootstrap, window/content-view forwarding, view/layer helpers, or CG/UI bridge glue.
- Say whether the failing path used `UIApplicationRunDrawCallback...` or the manual `UIApplication`/`UIWindow`/`UIView` setup.
- For draw callback bugs, say where the callback actually lived: layer, view, or forwarded through `UIWindow`.
