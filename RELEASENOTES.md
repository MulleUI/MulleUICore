## 0.1.0




feature: add UIWindow image support for CGNullContext

* CGNullContext now conforms to the UIWindow framebuffer category, returning nil for image queries instead of crashing on the no-backend graphics context
* registered the new CGNullContext/UIWindow class pair in the ObjC dependency loader
