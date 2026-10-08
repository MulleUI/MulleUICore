### 0.1.1


* README now explains how to embed MulleUICore without mulle-sde by adding it and its transitive dependencies as git submodules, using `add_subdirectory()` and `target_link_libraries()`
* documents including the umbrella header via `<MulleUICore/MulleUICore.h>`
* relocated existing mulle-sde/clib integration instructions after the new CMake setup


* README now explains how to embed MulleUICore without mulle-sde by adding it and its transitive dependencies as git submodules, using `add_subdirectory()` and `target_link_libraries()`
* documents including the umbrella header via `<MulleUICore/MulleUICore.h>`
* existing mulle-sde add and clib integration instructions retained as alternatives

## 0.1.0




feature: add UIWindow image support for CGNullContext

* CGNullContext now conforms to the UIWindow framebuffer category, returning nil for image queries instead of crashing on the no-backend graphics context
* registered the new CGNullContext/UIWindow class pair in the ObjC dependency loader
