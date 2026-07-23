<!-- keywords: bootstrap, forwarding, shadow, bridge, convenience, categories -->
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
- `src/UIApplication+UIWindow.h` / `.m` — bootstrap C functions
- `src/UIView+CGGraphicsLayer.h` / `.m` — view-to-layer forwarding
- `src/UIWindow+CGGraphicsLayer.h` / `.m` — window draw-callback proxy
- `src/UIWindow+CGColor.h` / `.m` — window background color (monochrome only)
- `src/UIView+CAShadowLayer.h` / `.m` — opt-in shadow layer
- `src/CALayer+UIOSWindow.h` / `.m` — layer init with ignored OSWindow
- `src/CGImage+UIImage.h` / `.m` — image layer class bridge
- `src/CGFramebuffer+UIFramebuffer.h` / `.m` — framebuffer protocol bridge
- `src/CGGraphicsLayer+UILayer.h` / `.m` — graphics layer protocol bridge
- `src/MulleObjCDeps+MulleUICore.h` / `.m` — loader dependency exposure
- `src/UIWindow+CGFramebuffer.m` — private CGContext category, not a UIWindow category despite filename
- `demo/src/main-refresh.m`
- `demo/src/main-glfw-boing.m`

## Main local surfaces

| Scenario | Start here | Local delta |
| --- | --- | --- |
| Single-layer drawing app | `UIApplicationRunDrawCallback` / `UIApplicationRunDrawCallbackHz` | MulleUICore builds the window, installs a `CGGraphicsLayer`, turns planes off, and enables mouse polling. |
| Manual window/controller setup | `UIApplication`, `UIWindow`, `UIView` | The common path is still layer-backed: make a view, attach it to the window, then add the window to the shared application. |
| View-side visual authoring | `UIView(CGGraphicsLayerForwarding)` | Border, background, opacity, rotation, masks, and draw callback are forwarded to the main `CGGraphicsLayer`. |
| Window-level visuals | `UIWindow(CGGraphicsLayer)` and `UIWindow(CGColor)` | `drawCallback` is only content-view forwarding; window background paint is reduced to a solid main color (monochrome only). |
| Opt-in shadows on views | `UIView(CAShadowLayer)` | Call `setShowsShadow:YES` before accessing `shadowLayer`. Shadow frame extrudes by `shadowInsets`. |
| CG/UI adapters | `CGImage(UIImage)`, `CGFramebuffer(UIFramebuffer)`, `CGGraphicsLayer(UILayer)` | Thin bridge shims so CG objects satisfy higher-level UI protocols. |
| Layer-window initializer | `CALayer(UIOSWindow)` | `initWithFrame:OSWindow:` ignores the `OSWindow` argument entirely. |
| Dependency declaration | `MulleObjCDeps(MulleUICore)` | Required public header for downstream loader dependency chains. |

## Local workflow

- Stay at the highest layer that fits the change. Most repo-local behavior is in the categories under `src/`, not in new root classes.
- Use the callback helper for a single `CGGraphicsLayer` window. Drop to the manual `UIApplication`/`UIWindow`/`UIView` path when you need retained mode, autoresizing, or explicit content-view setup like `demo/src/main-refresh.m`.
- Treat `demo/src/main-glfw-boing.m` as the escape hatch below MulleUICore: it uses `GLFWOSWindow` and a manual event/render loop when the convenience layer is intentionally bypassed.
- Keep `src/MulleObjCDeps+MulleUICore.h` public. Removing or privatizing it breaks downstream loader dependency contracts.

## Verify and report

- Say which family you changed: bootstrap, window/controller wiring, view/layer forwarding, shadow helper, or CG/UI bridge helpers.
- Cite the exact `src/...` and `demo/src/...` paths that justify the change.
- If you touched drawing callbacks, say whether the callback lives on the `UIView` or is only proxied by `UIWindow`.
