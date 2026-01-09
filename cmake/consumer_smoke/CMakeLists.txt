cmake_minimum_required(VERSION 3.20)
project(trdp_consumer_smoke C)

find_package(TRDP CONFIG REQUIRED)

add_executable(trdp_consumer_smoke main.c)

target_link_libraries(trdp_consumer_smoke PRIVATE trdp::trdp)

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
  endif()
endforeach()

if(TRDP_CONSUMER_INCLUDE STREQUAL "")
  message(FATAL_ERROR "Could not find installed TRDP API header (trdp_if_light.h) in imported include dirs: ${_inc_dirs}")
endif()

configure_file(
  ${CMAKE_CURRENT_LIST_DIR}/trdp_consumer_include.h.in
  ${CMAKE_CURRENT_BINARY_DIR}/trdp_consumer_include.h
  @ONLY
)

target_include_directories(trdp_consumer_smoke PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
