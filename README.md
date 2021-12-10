# MulleUI

#### 🌀 UI for mulle-objc - Desktop and Mobile

This library ties all sublibraries together and adds conveniences. With
MulleUI you can create windows with **UIWindow**, structure the window content
with **UIView** handle events as **UIEvents** in your **UIView**. Your
drawing code will likely reside in **CALayers**, that will utilize a platform
specific drawing library variant of **nanovg**. Your layers can be easily
animated with **CAAnimation**.

This library does not provide any widgets or concrete layers. (See:
MulleUIKit for that)


### You are here

```
  .===========================================================.
  | MulleUI                                                   |
  '==========================================================='
  .-----------------------------------------------------------.
  | MulleUIOS                                                 |
  '-----------------------------------------------------------'
  .-----------..---------..-----------------------------------.
  | MulleGLFW || MulleCG || MulleUICore                       |
  '-----------''---------''-----------------------------------'
                          .----------------.
                          | mulle-quadtree |
                          '----------------'
  .------------------------------------------------..---------.
  | MulleUIView                                    || MulleCA |
  '------------------------------------------------''---------'
                                    .--------------.
                                    | mulle-layout |
                                    '--------------'
  .--------------------------------.
  | MulleUIBase                    |
  '--------------------------------'
  .--------------------------------.
  | mulle-framebuffer              |
  '--------------------------------'
  .----------------------..------------------------.
  | mulle-bitmap         || mulle-geometry         |
  '----------------------''------------------------'
                          .------------------------.
                          | mulle-time             |
                          '------------------------'
```


## Add

Use [mulle-sde](//github.com/mulle-sde) to add MulleUI to your project:

``` console
mulle-sde dependency add --c --github <|GITHUB_USER|> MulleUI
```

## Install

### mulle-sde

Use [mulle-sde](//github.com/mulle-sde) to build and install MulleUI
and all its dependencies:

```
mulle-sde install --prefix /usr/local \
   https://github.com/<|GITHUB_USER|>/MulleUI/archive/latest.tar.gz
```

### Manual Installation


Install the requirements:

Requirements                                      | Description
--------------------------------------------------|-----------------------
[some-requirement](//github.com/some/requirement) | Some requirement

Install into `/usr/local`:

```
mkdir build 2> /dev/null
(
   cd build ;
   cmake -DCMAKE_INSTALL_PREFIX=/usr/local \
         -DCMAKE_PREFIX_PATH=/usr/local \
         -DCMAKE_BUILD_TYPE=Release .. ;
   make install
)
```

### Steal

Read [STEAL.md](//github.com/mulle-c11/dox/STEAL.md) on how to steal the
source code and incorporate it in your own projects.
