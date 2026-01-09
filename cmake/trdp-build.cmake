option(TRDP_MD_SUPPORT "Enable TRDP MD support" ON)

file(GLOB_RECURSE all_c CONFIGURE_DEPENDS "${TRDP_SRC_DIR}/*.c")
set(filtered_sources "${all_c}")
if(NOT TRDP_MD_SUPPORT)
  list(FILTER filtered_sources EXCLUDE REGEX ".*tlm.*\\.c$")
endif()
list(FILTER filtered_sources EXCLUDE REGEX "/(example|examples|ladder|resources|test)/")
list(FILTER filtered_sources EXCLUDE REGEX "/vos/(windows|vxworks|esp|integrity)/")
list(FILTER filtered_sources EXCLUDE REGEX "/vos/windows_sim/")
list(FILTER filtered_sources EXCLUDE REGEX "/trdp_dllmain\\.c$")
list(FILTER filtered_sources EXCLUDE REGEX "/spy/")
list(FILTER filtered_sources EXCLUDE REGEX "/vos_sockTSN\\.c$")
list(FILTER filtered_sources EXCLUDE REGEX "/common/old/")

set(optional_sources "${filtered_sources}")
list(FILTER optional_sources INCLUDE REGEX "(/tau/|/helpers?/|/helper/|/apps?/|/app/|/xml/|/marshall/|/[^/]*tau_.*\\.c$|/[^/]*marshall[^/]*\\.c$|/[^/]*_xml[^/]*\\.c$|/[^/]*xml[^/]*\\.c$)")
list(REMOVE_DUPLICATES optional_sources)

set(core_sources "${filtered_sources}")
if(optional_sources)
  list(REMOVE_ITEM core_sources ${optional_sources})
endif()

set(trdp_include_candidates
  "${TRDP_SRC_DIR}/src/api"
  "${TRDP_SRC_DIR}/src/common"
  "${TRDP_SRC_DIR}/src/vos/api"
  "${TRDP_SRC_DIR}/src/vos/common"
  "${TRDP_SRC_DIR}/src/vos/posix"
  "${TRDP_SRC_DIR}/api"
  "${TRDP_SRC_DIR}/vos/api"
  "${TRDP_SRC_DIR}/vos/common"
  "${TRDP_SRC_DIR}/vos/posix"
  "${TRDP_SRC_DIR}/src"
)

set(TRDP_PUBLIC_INCLUDE_DIRS "")
foreach(include_dir IN LISTS trdp_include_candidates)
  if(EXISTS "${include_dir}")
    list(APPEND TRDP_PUBLIC_INCLUDE_DIRS "${include_dir}")
  endif()
endforeach()
list(REMOVE_DUPLICATES TRDP_PUBLIC_INCLUDE_DIRS)

set(trdp_install_header_roots
  "${TRDP_SRC_DIR}/src/api|src_api"
  "${TRDP_SRC_DIR}/api|api"
  "${TRDP_SRC_DIR}/src/vos/api|vos_api"
  "${TRDP_SRC_DIR}/vos/api|vos_api"
  "${TRDP_SRC_DIR}/src/vos/common|vos_common"
  "${TRDP_SRC_DIR}/vos/common|vos_common"
)

set(TRDP_INSTALL_INCLUDE_DIRS "")
foreach(mapping IN LISTS trdp_install_header_roots)
  string(REPLACE "|" ";" parts "${mapping}")
  list(GET parts 0 header_root)
  list(GET parts 1 header_dest)
  if(EXISTS "${header_root}")
    list(APPEND TRDP_INSTALL_INCLUDE_DIRS
      "${CMAKE_INSTALL_INCLUDEDIR}/trdp/${TRDP_VERSION}/${header_dest}"
    )
  endif()
endforeach()
list(REMOVE_DUPLICATES TRDP_INSTALL_INCLUDE_DIRS)

find_package(Threads REQUIRED)
include(CheckLibraryExists)

set(trdp_link_libs Threads::Threads)
check_library_exists(rt clock_gettime "" TRDP_HAVE_LIBRT)
if(TRDP_HAVE_LIBRT)
  list(APPEND trdp_link_libs rt)
endif()
check_library_exists(uuid uuid_generate "" TRDP_HAVE_LIBUUID)
if(TRDP_HAVE_LIBUUID)
  list(APPEND trdp_link_libs uuid)
endif()

function(trdp_apply_settings target_name)
  target_compile_definitions(${target_name} PUBLIC POSIX)
  foreach(include_dir IN LISTS TRDP_PUBLIC_INCLUDE_DIRS)
    target_include_directories(${target_name} PUBLIC "$<BUILD_INTERFACE:${include_dir}>")
  endforeach()
  foreach(install_dir IN LISTS TRDP_INSTALL_INCLUDE_DIRS)
    target_include_directories(${target_name} PUBLIC "$<INSTALL_INTERFACE:${install_dir}>")
  endforeach()
  target_link_libraries(${target_name} PUBLIC ${trdp_link_libs})
endfunction()

add_library(trdp STATIC ${core_sources})
add_library(trdp::trdp ALIAS trdp)
trdp_apply_settings(trdp)

install(TARGETS trdp
  EXPORT TRDPTargets
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

if(TRDP_BUILD_SHARED)
  add_library(trdp_shared SHARED ${core_sources})
  set_target_properties(trdp_shared PROPERTIES OUTPUT_NAME trdp)
  trdp_apply_settings(trdp_shared)
  install(TARGETS trdp_shared
    EXPORT TRDPTargets
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  )
endif()

if(TRDP_BUILD_TRDPAP AND optional_sources)
  add_library(trdpap STATIC ${core_sources} ${optional_sources})
  add_library(trdp::trdpap ALIAS trdpap)
  target_link_libraries(trdpap PUBLIC trdp)
  trdp_apply_settings(trdpap)
  install(TARGETS trdpap
    EXPORT TRDPTargets
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  )
  if(TRDP_BUILD_SHARED)
    add_library(trdpap_shared SHARED ${core_sources} ${optional_sources})
    set_target_properties(trdpap_shared PROPERTIES OUTPUT_NAME trdpap)
    target_link_libraries(trdpap_shared PUBLIC trdp)
    trdp_apply_settings(trdpap_shared)
    install(TARGETS trdpap_shared
      EXPORT TRDPTargets
      ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
      LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
      RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    )
  endif()
elseif(TRDP_BUILD_TRDPAP)
  message(STATUS "TRDPAP not built: no optional sources detected for ${TRDP_VERSION}")
endif()

foreach(mapping IN LISTS trdp_install_header_roots)
  string(REPLACE "|" ";" parts "${mapping}")
  list(GET parts 0 header_root)
  list(GET parts 1 header_dest)
  if(EXISTS "${header_root}")
    install(DIRECTORY "${header_root}/"
      DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/trdp/${TRDP_VERSION}/${header_dest}/
      FILES_MATCHING PATTERN "*.h"
    )
  endif()
endforeach()

if(TRDP_BUILD_EXAMPLES)
  set(example_dir_candidates
    "${TRDP_SRC_DIR}/example"
    "${TRDP_SRC_DIR}/examples"
    "${TRDP_SRC_DIR}/tools"
    "${TRDP_SRC_DIR}/test"
  )
  set(example_dirs "")
  foreach(example_dir IN LISTS example_dir_candidates)
    if(EXISTS "${example_dir}")
      list(APPEND example_dirs "${example_dir}")
    endif()
  endforeach()
  if(example_dirs)
    set(example_sources "")
    foreach(example_dir IN LISTS example_dirs)
      file(GLOB_RECURSE dir_example_sources CONFIGURE_DEPENDS "${example_dir}/*.c")
      list(APPEND example_sources ${dir_example_sources})
    endforeach()
    list(REMOVE_DUPLICATES example_sources)
  endif()
  if(example_sources)
    string(REPLACE "." "_" trdp_version_slug "${TRDP_VERSION}")
    foreach(example_source IN LISTS example_sources)
      get_filename_component(example_base "${example_source}" NAME_WE)
      set(example_target "trdp_ex_${example_base}_${trdp_version_slug}")
      add_executable(${example_target} "${example_source}")
      if(TARGET trdpap)
        target_link_libraries(${example_target} PRIVATE trdpap)
      else()
        target_link_libraries(${example_target} PRIVATE trdp)
      endif()
      set_target_properties(${example_target} PROPERTIES OUTPUT_NAME "trdp_ex_${example_base}_${TRDP_VERSION}")
    endforeach()
  endif()
endif()
