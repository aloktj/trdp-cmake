cmake_minimum_required(VERSION 3.16)
project(trdp C)

include(GNUInstallDirs)

option(TRDP_BUILD_TRDPAP "Build TRDP application/helper library when sources exist" ON)
option(TRDP_BUILD_EXAMPLES "Build example/tool executables when sources exist" OFF)
option(TRDP_BUILD_SHARED "Build shared libs (in addition to static) if supported" OFF)
option(TRDP_BUILD_CONSUMER_SMOKE "Build consumer smoke test against installed package" OFF)

set(TRDP_VERSION "1.3.3.0" CACHE STRING "TRDP version to build")
set(TRDP_SRC_DIR "${CMAKE_SOURCE_DIR}/versions/${TRDP_VERSION}")

if(NOT EXISTS "${TRDP_SRC_DIR}")
  message(FATAL_ERROR "TRDP source directory not found: ${TRDP_SRC_DIR}")
endif()

include(${CMAKE_SOURCE_DIR}/cmake/trdp-build.cmake)

include(CMakePackageConfigHelpers)

configure_package_config_file(
  ${CMAKE_SOURCE_DIR}/cmake/package/TRDPConfig.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/TRDPConfig.cmake
  INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/TRDP
)

write_basic_package_version_file(
  ${CMAKE_CURRENT_BINARY_DIR}/TRDPConfigVersion.cmake
  VERSION 1.0.0
  COMPATIBILITY SameMajorVersion
)

install(EXPORT TRDPTargets
  NAMESPACE trdp::
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/TRDP
)

install(FILES
  ${CMAKE_CURRENT_BINARY_DIR}/TRDPConfig.cmake
  ${CMAKE_CURRENT_BINARY_DIR}/TRDPConfigVersion.cmake
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/TRDP
)
