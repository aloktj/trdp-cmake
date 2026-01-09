option(TRDP_MD_SUPPORT "Enable TRDP MD support" ON)

file(GLOB_RECURSE all_c CONFIGURE_DEPENDS "${TRDP_SRC_DIR}/*.c")
set(filtered_sources "${all_c}")
if(NOT TRDP_MD_SUPPORT)
  list(FILTER filtered_sources EXCLUDE REGEX ".*tlm.*\\.c$")
endif()
list(FILTER filtered_sources EXCLUDE REGEX "/(example|ladder|resources|test)/")
list(FILTER filtered_sources EXCLUDE REGEX "/vos/(windows|vxworks|esp|integrity)/")
list(FILTER filtered_sources EXCLUDE REGEX "/vos/windows_sim/")
list(FILTER filtered_sources EXCLUDE REGEX "/trdp_dllmain\\.c$")
list(FILTER filtered_sources EXCLUDE REGEX "/spy/")
list(FILTER filtered_sources EXCLUDE REGEX "/vos_sockTSN\\.c$")

add_library(trdp STATIC)
if(filtered_sources)
  target_sources(trdp PRIVATE ${filtered_sources})
endif()

target_compile_definitions(trdp PUBLIC POSIX)

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

foreach(include_dir IN LISTS trdp_include_candidates)
  if(EXISTS "${include_dir}")
    target_include_directories(trdp PUBLIC "${include_dir}")
  endif()
endforeach()

find_package(Threads REQUIRED)
target_link_libraries(trdp PUBLIC Threads::Threads)
