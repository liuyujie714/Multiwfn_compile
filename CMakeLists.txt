cmake_minimum_required(VERSION 3.10)

# 只能用于Windows
if(NOT WIN32)
  message(FATAL_ERROR "Only Windows build is supported!")
endif()

# 打开Fotran支持
project(Multiwfn Fortran)

# 设置编译器为Intel Visual Fortran
set(CMAKE_Fortran_COMPILER ifort)

# 设置生成Visual Studio 2022解决方案
set(CMAKE_GENERATOR "Visual Studio 17 2022")

# Release
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release CACHE STRING
      "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel."
      FORCE)
endif()

# 设置编译选项 O2 级别
set(CMAKE_Fortran_FLAGS_RELEASE "/MP /O2 /Qopenmp /fpp /Qmkl:parallel /Qmkl /QxCORE-AVX2 /threads /stand:f08 /static-intel /DINTEL_MKL /D_WIN32")

# 设置链接器选项
set(CMAKE_EXE_LINKER_FLAGS "/STACK:1900000000 legacy_stdio_definitions.lib")

# 设置库路径和包含路径
set(LIB_base "")
set(LIB_GUI "disifl_d.lib")
set(LIB_noGUI "${LIB_base}")
set(INCLUDE "-I./ -I./ext -I./libreta_hybrid")

# 添加可执行文件
set(EXE "Multiwfn")
if (NOGUI)
    set(EXE_noGUI "Multiwfn_noGUI")
endif()

# 添加源文件
set(SOURCES
    define.f90
    util.f90
    plot.f90
    Bspline.f90
    sym.F
    function.f90
    GUI.f90
    sub.f90
    integral.f90
    Lebedev-Laikov.F
    DFTxclib.F
    edflib.f90
    fparser.f90
    fileIO.f90
    spectrum.f90
    DOS.f90
    Multiwfn.f90
    0123dim.f90
    LSB.f90
    population.f90
    orbcomp.f90
    bondorder.f90
    topology.f90
    excittrans.f90
    otherfunc.f90
    otherfunc2.f90
    otherfunc3.f90
    O1.f90
    surfana.f90
    procgriddata.f90
    AdNDP.f90
    fuzzy.f90
    CDA.f90
    basin.f90
    orbloc.f90
    visweak.f90
    EDA.f90
    CDFT.f90
    ETS_NOCV.f90
    atmraddens.f90
    NAONBO.f90
    grid.f90
    PBC.f90
    hyper_polar.f90
    deloc_aromat.f90
    cp2kmate.f90
    minpack.f90
    #ext/no2F2.f90
    ext/frj.f90
)

# 添加GUI源文件
set(SOURCES_GUI
    dislin_d.f90
)

# 添加无GUI的源文件
set(SOURCES_noGUI
    noGUI/dislin_d_empty.f90
)

set(LIBRETAPATH "./libreta_hybrid")

# 添加libreta的源文件
set(LIBRETA_SOURCES
    ${LIBRETAPATH}/libreta.f90
    # XXXhrr_012345.f90 O2编译非常耗时间
    ${LIBRETAPATH}/hrr_012345.f90
    ${LIBRETAPATH}/blockhrr_012345.f90
    ${LIBRETAPATH}/ean.f90
    ${LIBRETAPATH}/eanvrr_012345.f90
    ${LIBRETAPATH}/boysfunc.f90
    ${LIBRETAPATH}/naiveeri.f90
    ${LIBRETAPATH}/ryspoly.f90
)

# 添加可执行文件
add_executable(${EXE} ${SOURCES} ${SOURCES_GUI} ${LIBRETA_SOURCES})
# 设置编译选项
target_compile_options(${EXE} PRIVATE ${CMAKE_Fortran_FLAGS_RELEASE})
# 设置链接库
target_link_libraries(${EXE} ${LIB_GUI})
# 设置包含目录
target_include_directories(${EXE} PRIVATE ${INCLUDE})

if (NOGUI)
    add_executable(${EXE_noGUI} ${SOURCES} ${SOURCES_noGUI} ${LIBRETA_SOURCES})
    target_compile_options(${EXE_noGUI} PRIVATE ${CMAKE_Fortran_FLAGS_RELEASE})
    target_link_libraries(${EXE_noGUI} ${LIB_noGUI})
    target_include_directories(${EXE_noGUI} PRIVATE ${INCLUDE})
endif()
