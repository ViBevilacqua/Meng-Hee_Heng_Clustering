### CMakeLists.txt for CUDA and OpenCV

project( main )
cmake_minimum_required(VERSION 2.8)
find_package(CUDA QUIET REQUIRED)
find_package( OpenCV REQUIRED )

# Pass options to NVCC
set(
    CUDA_NVCC_FLAGS
    ${CUDA_NVCC_FLAGS};
    -arch=sm_30
    #--relocatable-device-code true
    )

# Specify include directories
include_directories(
#    kernels
#    utility
    )

# Specify library paths
#link_directories(
#    /opt/foobar/lib
#    /opt/joestuff/lib
#    )

# For compilation ...
# Specify target & source files to compile it from
SET(CUDA_SEPARABLE_COMPILATION ON)
cuda_add_executable(
    main
    main.cpp
    utility.hpp
    utility.cpp
    MengHeeHeng.cuh
    MengHeeHeng.cu
    CudaTimer.cuh
    CudaTimer.cu
    )

# For linking ...
target_link_libraries( ${PROJECT_NAME} ${OpenCV_LIBS} )