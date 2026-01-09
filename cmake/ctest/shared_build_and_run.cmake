if(NOT DEFINED REPO_DIR)
  message(FATAL_ERROR "REPO_DIR is required")
endif()
if(NOT DEFINED BUILD_DIR)
  message(FATAL_ERROR "BUILD_DIR is required")
endif()
if(NOT DEFINED INSTALL_DIR)
  message(FATAL_ERROR "INSTALL_DIR is required")
endif()
if(NOT DEFINED TRDP_VERSION)
  message(FATAL_ERROR "TRDP_VERSION is required")
endif()
if(NOT DEFINED TRDP_BUILD_TRDPAP)
  message(FATAL_ERROR "TRDP_BUILD_TRDPAP is required")
endif()

set(SHARED_BUILD_DIR "${BUILD_DIR}")
set(CONSUMER_BUILD_DIR "${BUILD_DIR}_consumer")
set(SHARED_SMOKE_DIR "${REPO_DIR}/cmake/shared_smoke")

execute_process(
  COMMAND ${CMAKE_COMMAND}
    -S "${REPO_DIR}"
    -B "${SHARED_BUILD_DIR}"
    -DTRDP_VERSION=${TRDP_VERSION}
    -DTRDP_BUILD_SHARED=ON
    -DTRDP_BUILD_TRDPAP=${TRDP_BUILD_TRDPAP}
    -DTRDP_MD_SUPPORT=ON
  RESULT_VARIABLE config_result
)
if(NOT config_result EQUAL 0)
  message(FATAL_ERROR "Configure failed with code ${config_result}")
endif()

execute_process(
  COMMAND ${CMAKE_COMMAND} --build "${SHARED_BUILD_DIR}" --parallel
  RESULT_VARIABLE build_result
)
if(NOT build_result EQUAL 0)
  message(FATAL_ERROR "Build failed with code ${build_result}")
endif()

execute_process(
  COMMAND ${CMAKE_COMMAND} --install "${SHARED_BUILD_DIR}" --prefix "${INSTALL_DIR}"
  RESULT_VARIABLE install_result
)
if(NOT install_result EQUAL 0)
  message(FATAL_ERROR "Install failed with code ${install_result}")
endif()

execute_process(
  COMMAND ${CMAKE_COMMAND}
    -S "${SHARED_SMOKE_DIR}"
    -B "${CONSUMER_BUILD_DIR}"
    -DCMAKE_PREFIX_PATH=${INSTALL_DIR}
  RESULT_VARIABLE consumer_config_result
)
if(NOT consumer_config_result EQUAL 0)
  message(FATAL_ERROR "Consumer configure failed with code ${consumer_config_result}")
endif()

execute_process(
  COMMAND ${CMAKE_COMMAND} --build "${CONSUMER_BUILD_DIR}" --parallel
  RESULT_VARIABLE consumer_build_result
)
if(NOT consumer_build_result EQUAL 0)
  message(FATAL_ERROR "Consumer build failed with code ${consumer_build_result}")
endif()

execute_process(
  COMMAND "${CONSUMER_BUILD_DIR}/trdp_shared_smoke"
  RESULT_VARIABLE run_result
)
if(NOT run_result EQUAL 0)
  message(FATAL_ERROR "Shared smoke run failed with code ${run_result}")
endif()

if(EXISTS "${CONSUMER_BUILD_DIR}/trdp_shared_smoke_ap")
  execute_process(
    COMMAND "${CONSUMER_BUILD_DIR}/trdp_shared_smoke_ap"
    RESULT_VARIABLE run_ap_result
  )
  if(NOT run_ap_result EQUAL 0)
    message(FATAL_ERROR "Shared smoke AP run failed with code ${run_ap_result}")
  endif()
endif()
