cmake_minimum_required(VERSION 3.20)
project(trdp_shared_smoke C)

find_package(TRDP CONFIG REQUIRED)

add_executable(trdp_shared_smoke main.c)
# Link against shared lib target exported by package (should resolve to .so when built/installed shared)
target_link_libraries(trdp_shared_smoke PRIVATE trdp::trdp)

# Optionally also test trdpap if available
if(TARGET trdp::trdpap)
  add_executable(trdp_shared_smoke_ap main.c)
  target_link_libraries(trdp_shared_smoke_ap PRIVATE trdp::trdpap)
endif()

# Find a stable header include within imported target include dirs
get_target_property(_inc_dirs trdp::trdp INTERFACE_INCLUDE_DIRECTORIES)
set(TRDP_CONSUMER_INCLUDE "")

foreach(dir IN LISTS _inc_dirs)
  if(EXISTS "${dir}/trdp_if_light.h")
    set(TRDP_CONSUMER_INCLUDE "trdp_if_light.h")
    break()
  elseif(EXISTS "${dir}/api/trdp_if_light.h")
    set(TRDP_CONSUMER_INCLUDE "api/trdp_if_light.h")
    break()
  elseif(EXISTS "${dir}/src_api/trdp_if_light.h")
    set(TRDP_CONSUMER_INCLUDE "src_api/trdp_if_light.h")
    break()
  elseif(EXISTS "${dir}/tlp.h")
    set(TRDP_CONSUMER_INCLUDE "tlp.h")
    break()
  elseif(EXISTS "${dir}/tlc.h")
    set(TRDP_CONSUMER_INCLUDE "tlc.h")
    break()
  elseif(EXISTS "${dir}/api/tlp.h")
    set(TRDP_CONSUMER_INCLUDE "api/tlp.h")
    break()
  elseif(EXISTS "${dir}/src_api/tlp.h")
    set(TRDP_CONSUMER_INCLUDE "src_api/tlp.h")
    break()
  elseif(EXISTS "${dir}/api/tlc.h")
    set(TRDP_CONSUMER_INCLUDE "api/tlc.h")
    break()
  elseif(EXISTS "${dir}/src_api/tlc.h")
    set(TRDP_CONSUMER_INCLUDE "src_api/tlc.h")
    break()
  endif()
endforeach()

if(TRDP_CONSUMER_INCLUDE STREQUAL "")
  message(FATAL_ERROR "Could not find installed TRDP API header (trdp_if_light.h/tlp.h/tlc.h) in imported include dirs: ${_inc_dirs}")
endif()

configure_file(
  ${CMAKE_CURRENT_LIST_DIR}/trdp_consumer_include.h.in
  ${CMAKE_CURRENT_BINARY_DIR}/trdp_consumer_include.h
  @ONLY
)

target_include_directories(trdp_shared_smoke PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
if(TARGET trdp_shared_smoke_ap)
  target_include_directories(trdp_shared_smoke_ap PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
endif()

# Ensure runtime can find shared libs without setting LD_LIBRARY_PATH:
# Set RPATH to the package lib dir(s) from imported targets.
get_target_property(_trdp_loc trdp::trdp IMPORTED_LOCATION_RELEASE)
if(NOT _trdp_loc)
  get_target_property(_trdp_loc trdp::trdp IMPORTED_LOCATION)
endif()

if(_trdp_loc)
  get_filename_component(_trdp_libdir "${_trdp_loc}" DIRECTORY)
  set_target_properties(trdp_shared_smoke PROPERTIES
    BUILD_RPATH "${_trdp_libdir}"
    INSTALL_RPATH "${_trdp_libdir}"
  )
  if(TARGET trdp_shared_smoke_ap)
    set_target_properties(trdp_shared_smoke_ap PROPERTIES
      BUILD_RPATH "${_trdp_libdir}"
      INSTALL_RPATH "${_trdp_libdir}"
    )
  endif()
endif()
