cmake_minimum_required(VERSION 3.16)
project(trdp C)

set(TRDP_VERSION "1.3.3.0" CACHE STRING "TRDP version to build")
set(TRDP_SRC_DIR "${CMAKE_SOURCE_DIR}/versions/${TRDP_VERSION}")

if(NOT EXISTS "${TRDP_SRC_DIR}")
  message(FATAL_ERROR "TRDP source directory not found: ${TRDP_SRC_DIR}")
endif()

include(${CMAKE_SOURCE_DIR}/cmake/trdp-build.cmake)
