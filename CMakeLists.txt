cmake_minimum_required(VERSION 3.16)
project(trdp C)

option(TRDP_BUILD_TRDPAP "Build TRDP application/helper library when sources exist" ON)
option(TRDP_BUILD_EXAMPLES "Build example/tool executables when sources exist" OFF)
option(TRDP_BUILD_SHARED "Build shared libs (in addition to static) if supported" OFF)

set(TRDP_VERSION "1.3.3.0" CACHE STRING "TRDP version to build")
set(TRDP_SRC_DIR "${CMAKE_SOURCE_DIR}/versions/${TRDP_VERSION}")

if(NOT EXISTS "${TRDP_SRC_DIR}")
  message(FATAL_ERROR "TRDP source directory not found: ${TRDP_SRC_DIR}")
endif()

include(${CMAKE_SOURCE_DIR}/cmake/trdp-build.cmake)
