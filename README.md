<p style="text-align: center; color: blue; font-size: 20px;">基于Multiwfn 3.8(dev)源码编译Windows二进制程序</p>



# 声明

此自动编译流程总是下载**最新Multiwfn源码**构建，仅限于测试，本人不保证完全正确。特别对于需要进行二次开发或者增添自定义功能的用户有很大帮助，自动化构建流程非常方便。

<p style="color:red;">使用此软件请严格按照要求正文引用原作者的文献: </p>

> Tian Lu, Feiwu Chen, Multiwfn: A Multifunctional Wavefunction Analyzer, J. Comput. Chem. 33, 580-592 (2012) DOI: 10.1002/jcc.22885

> Tian Lu, A comprehensive electron wavefunction analysis toolbox for chemists, Multiwfn, J. Chem. Phys., 161, 082503 (2024) DOI: 10.1063/5.0216272



# 鼠标拖拽旋转功能

目前Multiwfn官网已经加入了对Windows系统下图形界面的分子旋转，平移等功能。

最近，本人又尝试添加了`Linux`系统的支持，效果不算非常好，主要是每次进行拖拽旋转的时候**必须先点击一下图形区域**，然后**再次点击并拖拽**就可以旋转了。因为Linux下底层是采用的X11，没有Win32那么好用，详情可以自行查看`mouserotate.f90`中的代码部分:
``` fortran
! use X11 & fortran-xlib
module mouse_rotate_mod
...
```
这一部分主要利用X11的[fortran-xlib](https://github.com/interkosmos/fortran-xlib)接口进行底层操作，需要链接这个xlib库`libfortran-xlib.a`。

**注意:**
如果是在Linux上是采用的`ifort`编译器进行编译，务必添加下列编译选项，确保C bind的bool行为和Inter Fortran的一致:
```
-fpscomp logicals
```
同时`fortran-xlib`这个库也要利用`ifort`进行编译，比如：
```bash
ifort -O2 -fpscomp logicals -c src/xlib.f90
ifort -O2 -fpscomp logicals -c src/xpm.f90
ar rcs libfortran-xlib.a xlib.o xpm.o
```


-----------------------------
# 源码获取

[Multiwfn_3.8_dev_src_Linux.zip](http://sobereva.com/multiwfn/misc/Multiwfn_3.8_dev_src_Linux.zip)这个源码虽然写的是Linux的，但是实测在Windows上可以正常编译和运行的。


# 编译方案

## Windows系统

### 方案1

Visual Studio 2022 + Inter Fortran compiler and MKL (from Intel oneAPI).

原生编译，官方推荐的编译方式，性能好。


[![Win x64](https://github.com/liuyujie714/Multiwfn_compile/actions/workflows/Multiwfn_ifort.yml/badge.svg)](https://github.com/liuyujie714/Multiwfn_compile/actions/workflows/Multiwfn_ifort.yml) 

可直接点击下载最新编译好的二进制，时间为每次触发编译时间：

[![Pre-release](https://img.shields.io/github/v/release/liuyujie714/Multiwfn_compile?include_prereleases&label=pre-release&color=orange)](https://github.com/liuyujie714/Multiwfn_compile/releases) [![Downloads](https://img.shields.io/github/downloads/liuyujie714/Multiwfn_compile/total)](https://github.com/liuyujie714/Multiwfn_compile/releases)



### 方案2

MingW64 + GNU Fortran + lapack

[![Win x64](https://github.com/liuyujie714/Multiwfn_compile/actions/workflows/Multiwfn_mingw64.yml/badge.svg)](https://github.com/liuyujie714/Multiwfn_compile/actions/workflows/Multiwfn_mingw64.yml)


此方案编译出的二进制程序性能比方案1略差，因为采用的是Mingw64下的gfortran本身就有性能问题，注意链接的是ucrt64库


## Linux系统
可采用Ifort或者GCC进行编译，推荐使用Ifort

Ifort + MKL + 支持鼠标拖拽旋转

[![Linux x64](https://github.com/liuyujie714/Multiwfn_compile/actions/workflows/Linux64_mouse.yml/badge.svg)](https://github.com/liuyujie714/Multiwfn_compile/actions/workflows/Linux64_mouse.yml)
[![Downloads](https://img.shields.io/github/downloads/liuyujie714/Multiwfn_compile/total)](https://github.com/liuyujie714/Multiwfn_compile/releases)
 
