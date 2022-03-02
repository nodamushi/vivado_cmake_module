cmake_minimum_required(VERSION 3.14)
project(study)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
set(CMAKE_CXX_STANDARD 11)
find_package(HLS REQUIRED)
find_package(Vivado REQUIRED)

add_subdirectory(src)
add_subdirectory(vivado)
