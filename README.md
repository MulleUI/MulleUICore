# MulleUI

#### 🌀 UI for mulle-objc - Desktop and Mobile

This library adds some convenience atop of MulleUIOS. It is the main starting
apoint for developing MulleUI code.

With MulleUI you can

* create windows with **UIWindow**
* layout window contents with **UIView**
* handle events as an **UIEvent** in your UIView
* do drawings in your UIView with **CALayer**
* animate your UIView or CALayer with **CAAnimation**

MulleUI will utilize a platform specific drawing library variant of **nanovg**.

This library does not provide any widgets. See MulleUIKit for that.


### You are here

![Overview](overview.dot.svg)



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
