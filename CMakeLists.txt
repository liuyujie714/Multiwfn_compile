cmake_minimum_required(VERSION 3.10)

# 只能用于Windows系统构建
if(NOT WIN32)
  message(FATAL_ERROR "Only windows system is supported!")
endif()

# 需要flint相关库: flint, arb, gmp, mpfr, pthreads 
set(LIBRARIES
    FLINT
    ARB
    GMP
    MPFR
    PTHREADS
)
foreach(LIB ${LIBRARIES})
    set(${LIB}_INCLUDE "C:/vcpkg/packages/${LIB}_x64-windows-static/include" CACHE PATH "${LIB} include path")
    set(${LIB}_LIB "C:/vcpkg/packages/${LIB}_x64-windows-static/lib/${LIB}.lib" CACHE PATH "${LIB} library")
    # pthreads lib named pthreadVC3.lib
    if("${LIB}" STREQUAL "PTHREADS")
        set(${LIB}_LIB "C:/vcpkg/packages/${LIB}_x64-windows-static/lib/pthreadVC3.lib" CACHE PATH "${LIB} library" FORCE)
    endif()

    if(NOT EXISTS ${${LIB}_LIB})
        message(FATAL_ERROR "${LIB} library not found at ${${LIB}_LIB}")
    endif()

    message(STATUS "Found ${LIB} include path: ${${LIB}_INCLUDE}")
    message(STATUS "Found ${LIB} library: ${${LIB}_LIB}")
endforeach()

# 打开Fotran支持
project(Multiwfn Fortran C)

# 设置编译器为Intel Visual Fortran
set(CMAKE_Fortran_COMPILER ifort CACHE PATH "Intel Visual Fortran compiler")

# Release
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release CACHE STRING
      "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel."
      FORCE)
endif()

# 预定义宏
add_definitions(
    /DINTEL_MKL
    /D_WIN32
)

# 清除Release模式下的默认优化选项
set(CMAKE_Fortran_FLAGS_RELEASE "")

# 设置编译选项
set(COMMON_FLAGS
    /fpp
    /Qopenmp
    /Qopt-matmul
    /Qmkl:parallel
    /Qmkl
    /QxCORE-AVX2
    /threads
    /stand:f08
    /static
    /Qdiag-disable:10448,8290,8291,6371,10316,6178,6916,7416,5268,7342,7373,5120,5144,5082,5112,2554,5183,6182,7352,6843
)

# 设置链接器选项
set(CMAKE_EXE_LINKER_FLAGS "/STACK:1900000000 legacy_stdio_definitions.lib")

# 设置库路径和包含路径
set(LIB_GUI "${CMAKE_SOURCE_DIR}/disifl_d.lib")
set(INCLUDE "./ext" "./libreta_hybrid" )

set(EXE "Multiwfn")

# 添加源文件
file(GLOB SOURCES *.f90 *.F)
list(APPEND SOURCES ext/2F2.f90 ext/frj.f90)
list(REMOVE_ITEM SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/Multiwfn.f90")
message(STATUS "Final source files: ${SOURCES}")

# C接口
set(C_SRC ext/2F2.c)

# 添加GUI源文件
set(SOURCES_GUI
    dislin_d.f90
)

set(LIBRETAPATH "./libreta_hybrid")

# 添加libreta的源文件
set(LIBRETA_SOURCES
    ${LIBRETAPATH}/libreta.f90
    ${LIBRETAPATH}/ean.f90
    ${LIBRETAPATH}/eanvrr_012345.f90
    ${LIBRETAPATH}/boysfunc.f90
    ${LIBRETAPATH}/naiveeri.f90
    ${LIBRETAPATH}/ryspoly.f90
    ${LIBRETAPATH}/hrr_012345.f90
)

set(HRR_SOURCE
    # blockhrr_012345.f90 O2编译非常耗时间且容易报错
    ${LIBRETAPATH}/blockhrr_012345.f90
)

# 总是O1优化HRR
add_library(lib_hrr STATIC ${HRR_SOURCE})
target_compile_options(
        lib_hrr 
        PRIVATE 
        ${COMMON_FLAGS}
        "$<$<CONFIG:Debug>:/O1>"
        "$<$<CONFIG:Release>:/O1>"
)

# 编译C接口
add_library(lib_2f2 STATIC ${C_SRC})
target_include_directories(lib_2f2 PRIVATE ${FLINT_INCLUDE} ${GMP_INCLUDE} ${MPFR_INCLUDE} ${PTHREADS_INCLUDE} ${ARB_INCLUDE})
target_link_libraries(lib_2f2 ${FLINT_LIB} ${GMP_LIB} ${MPFR_LIB} ${PTHREADS_LIB} ${ARB_LIB})

# 生成目标文件
add_library(lib_base STATIC ${SOURCES_GUI} ${SOURCES} ${LIBRETA_SOURCES})
target_include_directories(lib_base PRIVATE ${INCLUDE})
target_compile_options(
        lib_base 
        PRIVATE 
        ${COMMON_FLAGS}
        "$<$<CONFIG:Release>:/O2>"
)
target_link_libraries(lib_base lib_hrr lib_2f2)

# 设置包含目录
add_executable(${EXE} "Multiwfn.f90" )
target_include_directories(${EXE} PRIVATE ${INCLUDE})
target_compile_options(
        ${EXE} 
        PRIVATE
        ${COMMON_FLAGS}
        "$<$<CONFIG:Release>:/O2>"
)
# 链接主程序
target_link_libraries(${EXE} lib_base ${LIB_GUI} gdi32)

# install all flint lib and include
if (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set(CMAKE_INSTALL_PREFIX "${CMAKE_SOURCE_DIR}/../flint_staticlib" CACHE STRING "Installation prefix" FORCE)
endif()

install(DIRECTORY 
    ${FLINT_INCLUDE}/..
    ${GMP_INCLUDE}/..
    ${MPFR_INCLUDE}/..
    ${PTHREADS_INCLUDE}/..
    ${ARB_INCLUDE}/..
    DESTINATION ${CMAKE_INSTALL_PREFIX}
)

# Multiwfn.exe
install(TARGETS ${EXE} DESTINATION ${CMAKE_BINARY_DIR})
