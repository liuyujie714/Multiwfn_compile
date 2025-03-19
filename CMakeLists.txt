cmake_minimum_required(VERSION 3.10)

# 只能用于Windows系统构建
if(NOT WIN32 AND NOT MINGW)
  message(FATAL_ERROR "Only windows system is supported!")
endif()

# 打开Fotran支持
project(Multiwfn Fortran C)

# 清除Release模式下的默认优化选项
set(CMAKE_Fortran_FLAGS_RELEASE "")

# 需要flint相关库: flint, arb, gmp, mpfr, pthreads 
if(MINGW)
    set(CMAKE_FIND_LIBRARY_SUFFIXES ".a")
    set(CMAKE_FIND_LIBRARY_PREFIXES "lib")

    find_package(FLINT REQUIRED)
    if(${FLINT_VERSION_MAJOR} LESS 3)
        message(FATAL_ERROR "FLINT version must be >= 3.0")
    endif()
    find_package(GMP REQUIRED)
    find_package(MPFR REQUIRED)

    find_package(lapack REQUIRED)

    get_filename_component(LIB_PATH ${GMP_LIBRARY} DIRECTORY)
    set(LIBRARY_PATH ${GMP_INCLUDE_DIRS})
    set(FLINT_INCLUDE "${LIBRARY_PATH}")
    set(GMP_INCLUDE "${LIBRARY_PATH}")
    set(MPFR_INCLUDE "${LIBRARY_PATH}")

    set(FLINT_LIB "${LIB_PATH}/libflint.dll.a")
    set(GMP_LIB "${LIB_PATH}/libgmp.a")
    set(MPFR_LIB "${LIB_PATH}/libmpfr.a")
    set(LAPACK_LIB "${LIB_PATH}/liblapack.a")
    set(BLAS_LIB "${LIB_PATH}/libblas.a")

    add_definitions(
        -D_WIN32
    )

    # 设置编译选项
    set(COMMON_FLAGS
        -cpp
        -fopenmp
        -static
        -ffree-line-length-none
        #-fmax-stack-var-size=1900000000
    )

    # OPT_O1 只用于blockhrr_012345.f90
    set(OPT_O1 "-O2")
    set(OPT_O2 "-O2")
    set(LIB_GUI "${CMAKE_SOURCE_DIR}/dismg_d.a")    

else()
    # for MSVC and Ifort
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

    # 设置编译器为Intel Visual Fortran
    set(CMAKE_Fortran_COMPILER ifort CACHE PATH "Intel Visual Fortran compiler")

    # 预定义宏
    add_definitions(
        /DINTEL_MKL
        /D_WIN32
    )

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

    set(OPT_O1 "/O1")
    set(OPT_O2 "/O2")
    set(LIB_GUI "${CMAKE_SOURCE_DIR}/disifl_d.lib")

    # 设置链接器选项
    set(CMAKE_EXE_LINKER_FLAGS ${CMAKE_EXE_LINKER_FLAGS} "/STACK:1900000000 legacy_stdio_definitions.lib")

    # install all flint lib and include
    if (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set(CMAKE_INSTALL_PREFIX "${CMAKE_SOURCE_DIR}/../flint_staticlib" CACHE STRING "Installation prefix" FORCE)
    endif()

    # 设置安装路径
    if (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set(CMAKE_INSTALL_PREFIX "${CMAKE_SOURCE_DIR}/../flint_staticlib" CACHE STRING "Installation prefix" FORCE)
    endif()

    # 安装每个 *_x64-windows-static 文件夹
    foreach(LIB ${LIBRARIES})
    get_filename_component(${LIB}_PARENT_DIR ${${LIB}_INCLUDE} DIRECTORY)
    install(DIRECTORY ${${LIB}_PARENT_DIR}
            DESTINATION ${CMAKE_INSTALL_PREFIX}
    )
    endforeach()

endif()


# Release
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release CACHE STRING
      "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel."
      FORCE)
endif()

# 设置库路径和包含路径
set(INCLUDE "./ext" "./libreta_hybrid" )

set(EXE "Multiwfn")

# 添加源文件
file(GLOB SOURCES *.f90 *.F)
list(APPEND SOURCES ext/2F2.f90 ext/frj.f90)
list(REMOVE_ITEM SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/Multiwfn.f90")

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

# 总是OPT_O1优化HRR
add_library(lib_hrr STATIC ${HRR_SOURCE})
target_compile_options(
        lib_hrr 
        PRIVATE 
        ${COMMON_FLAGS}
        "$<$<CONFIG:Debug>:${OPT_O1}>"
        "$<$<CONFIG:Release>:${OPT_O1}>"
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
        "$<$<CONFIG:Release>:${OPT_O2}>"
)
target_link_libraries(lib_base lib_hrr lib_2f2 ${LAPACK_LIB} ${BLAS_LIB})

# 设置包含目录
add_executable(${EXE} "Multiwfn.f90" )
target_include_directories(${EXE} PRIVATE ${INCLUDE})
target_compile_options(
        ${EXE} 
        PRIVATE
        ${COMMON_FLAGS}
        "$<$<CONFIG:Release>:${OPT_O2}>"
)

# 链接主程序
if(MINGW)
    target_link_libraries(${EXE} lib_base ${LIB_GUI} opengl32 gdi32 gomp user32 msvcrt)
else()
    target_link_libraries(${EXE} lib_base ${LIB_GUI} opengl32 gdi32)
endif()

# Multiwfn.exe
install(TARGETS ${EXE} DESTINATION ${CMAKE_BINARY_DIR})
