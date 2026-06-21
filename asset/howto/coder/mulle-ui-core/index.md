<!-- keywords: mulle-uicore, uiwindow, uiview, calayer, cggraphicslayer, cgimage, cgframebuffer -->
# mulle-ui-core

Use this topic when you are changing MulleUICore's public convenience layer around `UIApplication`, `UIWindow`, `UIView`, `CALayer`, and the small CG/UI bridge categories in `src/`.

## Understand first

```bash
mulle-sde api apropos UIWindow UIView CALayer CGGraphicsLayer CGFramebuffer CGImage
mulle-sde api cat MulleUIApplication
mulle-sde api cat MulleUIWindow
mulle-sde api cat MulleUIView
mulle-sde api cat MulleCG
mulle-sde code search drawCallback
mulle-sde code search shadowLayer
```

## Local references

- `README.md`
- `asset/dox/TOC.md`
- `src/MulleUICore.h`
- `src/UIApplication+UIWindow.h`
- `src/UIApplication+UIWindow.m`
- `src/CALayer+UIOSWindow.h`
- `src/CALayer+UIOSWindow.m`
- `src/UIView+CGGraphicsLayer.h`
- `src/UIView+CGGraphicsLayer.m`
- `src/UIWindow+CGGraphicsLayer.h`
- `src/UIWindow+CGGraphicsLayer.m`
- `src/UIView+CAShadowLayer.h`
- `src/UIView+CAShadowLayer.m`
- `src/UIWindow+CGColor.h`
- `src/UIWindow+CGColor.m`
- `src/CGImage+UIImage.h`
- `src/CGImage+UIImage.m`
- `src/CGFramebuffer+UIFramebuffer.h`
- `src/CGFramebuffer+UIFramebuffer.m`
- `src/CGGraphicsLayer+UILayer.h`
- `src/CGGraphicsLayer+UILayer.m`
- `src/MulleObjCDeps+MulleUICore.h`
- `demo/src/main-refresh.m`
- `demo/src/main-glfw-boing.m`

## Main local surfaces

| Scenario | Start here | Local delta |
| --- | --- | --- |
| Single-layer drawing app | `UIApplicationRunDrawCallback` / `UIApplicationRunDrawCallbackHz` | MulleUICore builds the window, installs a `CGGraphicsLayer`, turns planes off, and enables mouse polling. |
| Manual window/controller setup | `UIApplication`, `UIWindow`, `UIView` | The common path is still layer-backed: make a view, attach it to the window, then add the window to the shared application. |
| View-side visual authoring | `UIView(CGGraphicsLayerForwarding)` | Border, background, opacity, rotation, masks, and draw callback are forwarded to the main `CGGraphicsLayer`. |
| Window-level visuals | `UIWindow(CGGraphicsLayer)` and `UIWindow(CGColor)` | `drawCallback` is only content-view forwarding; window background paint is reduced to a solid main color. |
| CG/UI adapters | `CGImage(UIImage)`, `CGFramebuffer(UIFramebuffer)`, `CGGraphicsLayer(UILayer)` | These are thin bridge shims so CG objects satisfy higher-level UI protocols. |

## Local workflow

- Stay at the highest layer that fits the change. Most repo-local behavior is in the categories under `src/`, not in new root classes.
- Use the callback helper for a single `CGGraphicsLayer` window. Drop to the manual `UIApplication`/`UIWindow`/`UIView` path when you need retained mode, autoresizing, or explicit content-view setup like `demo/src/main-refresh.m`.
- Treat `demo/src/main-glfw-boing.m` as the escape hatch below MulleUICore: it uses `GLFWOSWindow` and a manual event/render loop when the convenience layer is intentionally bypassed.

## Verify and report

- Say which family you changed: bootstrap, window/controller wiring, view/layer forwarding, or CG/UI bridge helpers.
- Cite the exact `src/...` and `demo/src/...` paths that justify the change.
- If you touched drawing callbacks, say whether the callback lives on the `UIView` or is only proxied by `UIWindow`.
