<p style="text-align: center; color: blue; font-size: 20px;">基于Multiwfn Latest源码编译Windows二进制程序</p>



# 声明

此自动编译流程总是下载**最新Multiwfn源码**构建，仅限于测试，本人不保证完全正确。特别对于需要进行二次开发或者增添自定义功能的用户有很大帮助，自动化构建流程非常方便。

<p style="color:red;">使用此软件请严格按照要求正文引用原作者的文献: </p>

> Tian Lu, Feiwu Chen, Multiwfn: A Multifunctional Wavefunction Analyzer, J. Comput. Chem. 33, 580-592 (2012) DOI: 10.1002/jcc.22885

> Tian Lu, A comprehensive electron wavefunction analysis toolbox for chemists, Multiwfn, J. Chem. Phys., 161, 082503 (2024) DOI: 10.1063/5.0216272


-----------------------------
# 源码获取

[Multiwfn_latest_src_Linux.zip](http://sobereva.com/multiwfn/misc/Multiwfn_latest_src_Linux.zip)这个虽然写的是Linux的，但实际上源码和Windows一样。

# 编译方案

Visual Studio 2022 + Inter Fortran compiler and MKL (from Intel oneAPI).

原生编译，官方推荐的编译方式，性能好。


[![Win x64](https://github.com/liuyujie714/Multiwfn_compile/actions/workflows/Multiwfn_ifort.yml/badge.svg)](https://github.com/liuyujie714/Multiwfn_compile/actions/workflows/Multiwfn_ifort.yml) 

可直接点击下载最新编译好的二进制（**无任何源代码层面的改动**，只给Multiwfn.exe添加了一个图标），时间为每次触发编译时间：

[![Pre-release](https://img.shields.io/github/v/release/liuyujie714/Multiwfn_compile?include_prereleases&label=pre-release&color=orange)](https://github.com/liuyujie714/Multiwfn_compile/releases) [![Downloads](https://img.shields.io/github/downloads/liuyujie714/Multiwfn_compile/total)](https://github.com/liuyujie714/Multiwfn_compile/releases)

