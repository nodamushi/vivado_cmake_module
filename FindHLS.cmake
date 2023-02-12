# Find Vitis HLS
#  You can change the search location by
#  setting the following variables.
# vitis hls
#  VITIS_HLS_ROOT
#  VIVADO_ROOT (search save version of Vitis_HLS)
#  XILINX_HLS Environment variable
#
# vivado hls
#  VIVADO_ROOT
#  XILINX_VIVADO Environment variable
#
# exp) cmake -DVITIS_HLS_ROOT=/c/Xilinx/${HLS_EXEC}/2021.1
#
# VIVADO_REQUIRED_VERSION: Vivado version
# HLS_REQUIRED_VERSION: HLS version
#  set(VIVADO_REQUIRED_VERSION 2022.1)
#
# Default Values
set(HLS_VENDOR_NAME "Anonymous" CACHE STRING "default hls ip vendor name for add_hls_project")
set(HLS_TAXONOMY "UserIP" CACHE STRING "default taxonomy for add_hls_project")
set(HLS_SOLUTION_NAME "solution1" CACHE STRING "default project solution name")
set(HLS_TRACE_LEVEL "port_hier" CACHE STRING "default cosim trace level")
set(VITIS_HLS_FLOW_TARGET "vivado" CACHE STRING  "default vitis hls flow target for add_hls_project")
set(HLS_DEFAULT_VERSION "0.0" CACHE STRING "default hls ip version")
set(HLS_PROJECT_FILE_NAME "hls.app" CACHE STRING "default hls project file name.")
set(HLS_CFLAGS "" CACHE STRING "default hls compile option")
set(HLS_TBOUT "" CACHE STRING "default test bench exec file output directory")

include(${CMAKE_CURRENT_LIST_DIR}/utils.cmake)

# find vitis_hls
find_path(VITIS_HLS_BIN_DIR
  vitis_hls
  PATHS ${VITIS_HLS_ROOT} ENV XILINX_HLS
  PATH_SUFFIXES bin
)

find_path(VITIS_HLS_INCLUDE_DIR
  NAMES hls_stream.h
  PATHS ${VITIS_HLS_ROOT} ENV XILINX_HLS
  PATH_SUFFIXES include
)

# retry to find vitis_hls from vivado
if (${VITIS_HLS_BIN_DIR} STREQUAL "VITIS_HLS_BIN_DIR-NOTFOUND")
  # find vivado path
  vcmu_find_vivado_bin(HLS_VIVADO_BIN_DIR HLS_REQUIRED_VERSION VIVADO_REQUIRED_VERSION)

  if (${HLS_VIVADO_BIN_DIR} STREQUAL "HLS_VIVADO_BIN_DIR-NOTFOUND")
    message("  FindHLS: Vivado / Vitis HLS not found.")
    message("  Please specified the following cmake option:")
    message("    -DVIVADO_ROOT=/tools/Xilinx/Vivado/yyyy.v")
    message("  or")
    message("    -DVITIS_HLS_ROOT=/tools/Xilinx/Vitis_HLS/yyyy.v")
    message(FATAL_ERROR "Vivado / Vitis HLS not found.")
  endif()

  get_filename_component(HLS_VERSION "${HLS_VIVADO_BIN_DIR}" DIRECTORY)
  get_filename_component(HLS_VERSION "${HLS_VERSION}" NAME)

  find_path(VITIS_HLS_BIN_DIR
    vitis_hls
    PATHS ${HLS_VIVADO_BIN_DIR}/../../../Vitis_HLS/${HLS_VERSION}
    PATH_SUFFIXES bin
  )
  find_path(VITIS_HLS_INCLUDE_DIR
    NAMES hls_stream.h
    PATHS ${HLS_VIVADO_BIN_DIR}/../../../Vitis_HLS/${HLS_VERSION}
    PATH_SUFFIXES include
  )
endif()

# find vivado_hls when vitis is not found
if (${VITIS_HLS_BIN_DIR} STREQUAL "VITIS_HLS_BIN_DIR-NOTFOUND")
  set(HLS_EXEC vivado_hls)
  set(HLS_IS_VITIS FALSE)
  set(HLS_IS_VIVADO TRUE)
  find_path(HLS_BIN_DIR
    ${HLS_EXEC}
    PATHS ${VIVADO_ROOT} ENV XILINX_VIVADO
    PATH_SUFFIXES bin
  )

  find_path(HLS_INCLUDE_DIR
    NAMES hls_stream.h
    PATHS ${VIVADO_ROOT} ENV XILINX_VIVADO
    PATH_SUFFIXES include
  )
else()
  set(HLS_EXEC vitis_hls)
  set(HLS_IS_VITIS TRUE)
  set(HLS_IS_VIVADO FALSE)
  set(HLS_BIN_DIR ${VITIS_HLS_BIN_DIR})
  set(HLS_INCLUDE_DIR ${VITIS_HLS_INCLUDE_DIR})
endif()

# HLS_VERSION: Vitis HLS Version
get_filename_component(HLS_VERSION "${HLS_BIN_DIR}" DIRECTORY)
get_filename_component(HLS_VERSION "${HLS_VERSION}" NAME)


if (HLS_REQUIRED_VERSION)
  if (NOT ${HLS_REQUIRED_VERSION} VERSION_EQUAL ${HLS_VERSION})
    message("  Found HLS Path: ${HLS_BIN_DIR}")
    message(FATAL_ERROR "Found HLS ${HLS_VERSION}. Reuquired HLS ${HLS_REQUIRED_VERSION}")
  endif()
elseif (VIVADO_REQUIRED_VERSION)
  if (NOT ${VIVADO_REQUIRED_VERSION} VERSION_EQUAL ${HLS_VERSION})
    message("  Found HLS Path: ${HLS_BIN_DIR}")
    message(FATAL_ERROR "Found HLS ${HLS_VERSION}. Reuquired Vivado ${VIVADO_REQUIRED_VERSION}")
  endif()
endif()

# vivado
if (NOT HLS_VIVADO_BIN_DIR)
  find_path(HLS_VIVADO_BIN_DIR
    vivado
    PATHS ${HLS_BIN_DIR}/../../../Vivado/${HLS_VERSION}
    PATH_SUFFIXES bin
  )
endif()

set(HLS_VIVADO_EXE ${HLS_VIVADO_BIN_DIR}/vivado)

# save current directory
set(HLS_CMAKE_DIR ${CMAKE_CURRENT_LIST_DIR})
set(HLS_TCL_DIR ${CMAKE_CURRENT_LIST_DIR}/tcl)
set(HLS_CMAKE_LIB_DIR ${CMAKE_CURRENT_BINARY_DIR}/lib)

include(CheckIncludeFile)
CHECK_INCLUDE_FILE(gmp.h HLS_GMP_EXISTS)
if (HLS_GMP_EXISTS)
  set(HLS_GMP_INC_DIR ${CMAKE_CURRENT_LIST_DIR}/gmp)
else()
  set(HLS_GMP_INC_DIR ${CMAKE_CURRENT_LIST_DIR}/nogmp)
endif()

# hide variables
mark_as_advanced(
  HLS_VIVADO_BIN_DIR
  HLS_VIVADO_EXE
  HLS_INCLUDE_DIR
  HLS_CMAKE_DIR
  HLS_TCL_DIR
  HLS_CMAKE_LIB_DIR
  HLS_PROJECT_FILE_NAME
  HLS_GMP_INC_DIR
  HLS_GMP_EXISTS
)

# find package
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(HLS
  REQUIRED_VARS
    HLS_BIN_DIR
    HLS_INCLUDE_DIR
    HLS_TCL_DIR
)

# reset HLS_EXEC
set(HLS_EXEC ${HLS_BIN_DIR}/${HLS_EXEC})

# provide HLS::HLS
if(HLS_FOUND AND NOT TARGET HLS::HLS)
  add_library(HLS::HLS INTERFACE IMPORTED)
  set_target_properties(HLS::HLS
    PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES ${HLS_INCLUDE_DIR}
  )
endif()

macro(_hls_append_link CFLAG LINK)
  foreach(TMP IN LISTS ${LINK})
    get_target_property(TMP2 ${TMP} TYPE)
    if (NOT ${TMP2} STREQUAL "INTERFACE_LIBRARY")
      message(FATAL_ERROR "LINK: `${TMP}` is not an INTERFACE library")
    endif()

    get_target_property(TMP2 ${TMP} INTERFACE_INCLUDE_DIRECTORIES)
    foreach(TMP3 ${TMP2})
      vcmu_to_abs_path(${TMP3} TMP3)
      if (NOT ${TMP3} STREQUAL ${HLS_INCLUDE_DIR})
        list(APPEND ${CFLAG} -I${TMP3})
      endif()
    endforeach()
  endforeach()
endmacro()

# add_hls_project(
#  <project>
#  TOP      <top module>
#  PERIOD   <clock period(ns)>
#  PART     <board part>
#  SOURCES  <C++ source file>...#  [INCDIRS    <include directory>...]
#  [DIR        <direcotry>]
#  [LINK       <link library>...]
#  [TB_SOURCES <test bench C++ file>...]
#  [TB_INCDIRS <include directory>...]
#  [TB_LINK    <link libray>...]
#  [DEPENDS    <depends target>...]
#  [NAME    <display name>]
#  [IPNAME  <IP name>]
#  [VENDOR  <your name>]
#  [TAXONOMY <category>]
#  [VERSION  <version(x.y)>]
#  [SOLUTION <solution name>]
#  [COSIM_LDFLAGS <flag string>]
#  [COSIM_TRACE_LEVEL <none|all|port|port_hier>]
#  [FLOW_TARGET <vivado|vitis>]
#  [CFLAG <flags>...]
#  [TB_CFLAG <flags>...]
#  [DEFINE <macro>...]
#  [TB_DEFINE <macro>...]
#  [TBOUT <direcotry>]
#  [NO_O0]
#  [CTEST]
# )
#
# Define Targets:
#   create_project_${project} : Create Vitis Project
#   clear_${project}          : Delete Vitis project directory
#   csynth_${project}         : Run synthesis
#   cosim_${project}          : C/RTL simulation
#   lib_${project}            : Compile C++
#   build_test_${project}     : Compile TestBench
#   test_${project}           : Run TestBench (NOT Csim/Cosim)
#
# Argument
#  project: target name
#
# Taged Arguments
#  TOP    : Top module name
#  PERIOD : Clock Period (ns)
#  PART   : Device part
#  SOURCES: HLS source file
#
# Options
#  DIR           : Project parent directory
#  NAME          : IP display name
#  IPNAME        : IP name
#  VENDOR        : Your name
#  TAXONOMY      : IP category
#  VERSION       : IP version(x.y)
#  SOLUTION      : Solution name
#  TB_SOURCES    : Test Bench source files
#  INCDIRS       : Include directories
#  TB_INCDIRS    : Include directories for test bench
#  DEPENDS       : Dependency for create project
#  LINK          : Link library
#  TB_LINK       : Link library for testing
#  CFLAG         : additional cflag
#  TB_CFLAG      : additional cflag for test bench
#  COSIM_LDFLAGS : cosim_design -ldflags
#  TRACE_LEVEL   : none, all, port, port_hier
#  FLOW_TARGET   : (vitis_hls only). vivado, vitis
#  DEFINE        : define macro
#  TB_DEFINE     : define macro for test bench
#  NO_O0         : disable -O0 option of test_${project}
#  TBOUT         : test_$<project> output directory
#  CTEST         : add_test(build_test_${project})
#
function(add_hls_project project)
  cmake_parse_arguments(
    HARG
    "NO_O0;CTEST"
    "TOP;PERIOD;PART;SOLUTION;FLOW_TARGET;VERSION;DESCRIPTION;NAME;IPNAME;TAXONOMY;VENDOR;TRACE_LEVEL;TBOUT;WD"
    "SOURCES;TB_SOURCES;INCDIRS;TB_INCDIRS;DEPENDS;LINK;TB_LINK;COSIM_LDFLAGS;CFLAG;TB_CFLAG;DEFINE;TB_DEFINE"
    ${ARGN}
  )

  # Check arguments
  if(NOT HARG_TOP)
    message(FATAL_ERROR "add_hls_project: TOP (top module name) is not defined.")
  endif()

  if(NOT HARG_PERIOD)
    message(FATAL_ERROR "add_hls_project: PERIOD (clock period) is not defined.")
  endif()

  if(NOT HARG_PART)
    message(FATAL_ERROR "add_hls_project: PART (device part) is not defined.")
  endif()

  if(NOT HARG_SOURCES)
    message(FATAL_ERROR "add_hls_project: SOURCES (HLS source file) is not defined.")
  endif()
  if (NOT HARG_DIR)
    set(DIR ${CMAKE_CURRENT_BINARY_DIR})
  else()
    vcmu_to_abs_path(${HARG_DIR} DIR)
  endif()

  # set default option value
  if(NOT HARG_VERSION)
    set(VERSION ${HLS_DEFAULT_VERSION})
  else()
    set(VERSION ${HARG_VERSION})
  endif()
  #  * Version string separated by underscores
  string(REPLACE "." "_" VERSION_ ${VERSION})

  if(NOT HARG_DESCRIPTION)
    set(DESCRIPTION ${project})
  else()
    set(DESCRIPTION ${HARG_DESCRIPTION})
  endif()

  if(NOT HARG_NAME)
    set(HARG_NAME ${project})
  endif()

  if(NOT HARG_VENDOR)
    set(VENDOR "${HLS_VENDOR_NAME}")
  else()
    set(VENDOR "${HARG_VENDOR}")
  endif()

  if(NOT HARG_IPNAME)
    string(REPLACE "-" "_" IPNAME "${project}")
    string(REPLACE "." "_" IPNAME "${IPNAME}")
  else()
    set(IPNAME ${HARG_IPNAME})
  endif()

  if(NOT HARG_TAXONOMY)
    set(TAXONOMY "${HLS_TAXONOMY}")
  else()
    set(TAXONOMY "${HARG_TAXONOMY}")
  endif()

  if(NOT HARG_SOLUTION)
    set(SOLUTION "${HLS_SOLUTION_NAME}")
  else()
    set(SOLUTION "${HARG_SOLUTION}")
  endif()

  if(NOT HARG_FLOW_TARGET)
    set(FLOW_TARGET ${VITIS_HLS_FLOW_TARGET})
  else()
    set(FLOW_TARGET ${HARG_FLOW_TARGET})
  endif()

  if(NOT HARG_TRACE_LEVEL)
    set(TRACE_LEVEL ${HLS_TRACE_LEVEL})
  else()
    set(TRACE_LEVEL ${HARG_TRACE_LEVEL})
  endif()

  list(APPEND HARG_COSIM_LDFLAGS "-L${HLS_CMAKE_LIB_DIR}")

  # fix relative path
  vcmu_map_abs_path(HARG_SOURCES SRC_LIST)
  vcmu_map_abs_path(HARG_TB_SOURCES TBSRC_LIST)

  # create -I** option
  if (NOT HARG_CFLAG)
    set(HARG_CFLAG ${HLS_CFLAGS} -I${CMAKE_CURRENT_SOURCE_DIR})
  else()
    list(APPEND HARG_CFLAG ${HLS_CFLAGS} -I${CMAKE_CURRENT_SOURCE_DIR})
  endif()
  list(APPEND HARG_CFLAG -I${HLS_GMP_INC_DIR})

  vcmu_map_abs_path(HARG_INCDIRS HARG_CFLAG -I)

  get_directory_property(HARG_INCDIRS_2 INCLUDE_DIRECTORIES)
  vcmu_map_abs_path(HARG_INCDIRS_2 HARG_CFLAG -I)
  _hls_append_link(HARG_CFLAG HARG_LINK)

  foreach(HARG_DEF IN LISTS HARG_DEFINE)
    list(APPEND HARG_CFLAG -D${HARG_DEF})
  endforeach()

  ###  tb cflag
  if (NOT HARG_TB_CFLAG)
    set(HARG_TB_CFLAG ${HARG_CFLAG})
  else()
    list(APPEND HARG_TB_CFLAG ${HARG_CFLAG})
  endif()

  vcmu_map_abs_path(HARG_TB_INCDIRS HARG_TB_CFLAG -I)


  foreach(HARG_LINK_LIB IN LISTS HARG_TB_LINK)
    get_target_property(HARG_LINK_TYPE ${HARG_LINK_LIB} TYPE)
    if (${HARG_LINK_TYPE} STREQUAL "INTERFACE_LIBRARY")
      get_target_property(HARG_LINK_DIR ${HARG_LINK_LIB} INTERFACE_INCLUDE_DIRECTORIES)
    elseif(${HARG_LINK_TYPE} STREQUAL "STATIC_LIBRARY")
      get_target_property(HARG_LINK_OUTDIR ${HARG_LINK_LIB} LIBRARY_OUTPUT_DIRECTORY)
      if (NOT HARG_LINK_OUTDIR)
        get_target_property(HARG_LINK_OUTDIR ${HARG_LINK_LIB} BINARY_DIR)
      endif()
      list(APPEND HARG_COSIM_LDFLAGS -L${HARG_LINK_OUTDIR})

      get_target_property(HARG_LINK_DIR ${HARG_LINK_LIB} INCLUDE_DIRECTORIES)
      get_target_property(HARG_LINK_NAME ${HARG_LINK_LIB} NAME)
      list(APPEND HARG_COSIM_LDFLAGS -l${HARG_LINK_NAME})
    else()
      message(FATAL_ERROR "TB_LINK: `${HARG_LINK_LIB}` is not a library")
    endif()

    foreach(HARG_INCDIR ${HARG_LINK_DIR})
      vcmu_to_abs_path(${HARG_INCDIR} HARG_INCDIR)
      if (NOT ${HARG_INCDIR} STREQUAL ${HLS_INCLUDE_DIR})
        list(APPEND HARG_TB_CFLAG -I${HARG_INCDIR})
      endif()
    endforeach()
  endforeach()

  foreach(HARG_DEF IN LISTS HARG_TB_DEFINE)
    list(APPEND HARG_TB_CFLAG -D${HARG_DEF})
  endforeach()

  # define compile target
  add_library(lib_${project} STATIC ${HARG_SOURCES})
  target_link_libraries(lib_${project}
    PUBLIC
      HLS::HLS
      ${HARG_LINK}
  )
  if (HARG_DEFINE)
    target_compile_definitions(lib_${project} PUBLIC ${HARG_DEFINE})
  endif()
  target_include_directories(lib_${project}
    PUBLIC
      ${HARG_INCDIRS}
      ${HLS_GMP_INC_DIR}
  )

  # define test-bench compile target
  if(HARG_TB_SOURCES)
    add_executable(build_test_${project}
        ${HARG_TB_SOURCES}
    )
    target_compile_options(build_test_${project} PUBLIC -g)
    if (NOT HARG_NO_O0)
      target_compile_options(build_test_${project} PUBLIC -O0)
    endif()

    if (HARG_TB_DEFINE)
      target_compile_definitions(build_test_${project} PUBLIC ${HARG_TB_DEFINE})
    endif()

    target_link_libraries(build_test_${project}
      PUBLIC
        ${HARG_TB_LINK}
        lib_${project}
    )
    target_include_directories(build_test_${project}
      PUBLIC
        ${HARG_TB_INCDIRS}
        ${HLS_GMP_INC_DIR}
    )
    if (HARG_TBOUT)
      vcmu_to_abs_path(${HARG_TBOUT} TBOUT)
      set_target_properties(build_test_${project}
        PROPERTIES
          RUNTIME_OUTPUT_DIRECTORY ${TBOUT}
      )
    elseif(NOT HLS_TBOUT STREQUAL "")
      set_target_properties(build_test_${project}
        PROPERTIES
          RUNTIME_OUTPUT_DIRECTORY ${HLS_TBOUT}
      )
    endif()
    add_custom_target(test_${project}
      DEPENDS test_${project}
    )
    add_custom_command(
      TARGET test_${project}
      POST_BUILD
      COMMAND echo "[INFO] Run ${project} test program."
      COMMAND $<TARGET_FILE:build_test_${project}>
      COMMAND echo "[INFO] Test Done."
    )

    if (HARG_CTEST)
      add_test(NAME test_${project} COMMAND $<TARGET_FILE:build_test_${project}>)
    endif()
  endif()

  # define vitis hls project target
  set(PRJ_NAME "${project}")
  set(PRJ_DIR ${DIR}/${PRJ_NAME})
  set(PRJ_FILE ${PRJ_DIR}/${HLS_PROJECT_FILE_NAME})
  set(ENV_FILE ${CMAKE_CURRENT_BINARY_DIR}/env_hls_${project}.tcl)

  vcmu_env_file_init(${ENV_FILE})
  vcmu_env_file_add_var(${ENV_FILE} project_name "${PRJ_NAME}")
  vcmu_env_file_add_var(${ENV_FILE} tcl_directory "${HLS_TCL_DIR}")
  vcmu_env_file_add_var(${ENV_FILE} solution "${SOLUTION}")
  vcmu_env_file_add_list(${ENV_FILE} cflags HARG_CFLAG)
  vcmu_env_file_add_list(${ENV_FILE} tbcflags HARG_TB_CFLAG)
  vcmu_env_file_add_var(${ENV_FILE} top "${HARG_TOP}")
  vcmu_env_file_add_var(${ENV_FILE} part "${HARG_PART}")
  vcmu_env_file_add_var(${ENV_FILE} period "${HARG_PERIOD}")
  vcmu_env_file_add_var(${ENV_FILE} flow_target "${FLOW_TARGET}")
  vcmu_env_file_add_list(${ENV_FILE} src SRC_LIST)

  vcmu_env_file_add_list(${ENV_FILE} tbsrc TBSRC_LIST)
  if (${HLS_IS_VITIS})
    vcmu_env_file_add_var(${ENV_FILE} is_vitis "yes")
  else()
    vcmu_env_file_add_var(${ENV_FILE} is_vitis "no")
  endif()
  vcmu_env_file_add_var(${ENV_FILE} name "\"${HARG_NAME}\"")
  vcmu_env_file_add_var(${ENV_FILE} description "\"${DESCRIPTION}\"")
  vcmu_env_file_add_var(${ENV_FILE} ipname "\"${IPNAME}\"")
  vcmu_env_file_add_var(${ENV_FILE} taxonomy "\"${TAXONOMY}\"")
  vcmu_env_file_add_var(${ENV_FILE} vendor "\"${VENDOR}\"")
  vcmu_env_file_add_var(${ENV_FILE} version "\"${VERSION}\"")
  vcmu_env_file_add_list(${ENV_FILE} cosim_ldflags HARG_COSIM_LDFLAGS)
  vcmu_env_file_add_var(${ENV_FILE} trace_level "${TRACE_LEVEL}")

  add_custom_target(create_project_${project} SOURCES ${PRJ_FILE})
  vcmu_create_tcl_script(hls create_hls_project.tcl)
  add_custom_command(
    OUTPUT ${PRJ_FILE}
    WORKING_DIRECTORY ${DIR}
    DEPENDS ${HARG_DEPENDS}
    COMMAND
      # Call ${HLS_EXEC}
      ${HLS_EXEC} -f ${SCRIPT}
  )

  # synthesis target
  set(CSYNTH_ZIP ${PRJ_DIR}/${SOLUTION}/impl/ip/${VENDOR}_hls_${project}_${VERSION_}.zip)
  add_custom_target(csynth_${project} SOURCES ${CSYNTH_ZIP})
  vcmu_create_tcl_script(hls csynth.tcl)
  add_custom_command(
    OUTPUT ${CSYNTH_ZIP}
    DEPENDS create_project_${project} lib_${project}
    COMMAND
      # Define Environment Variables
      # Call ${HLS_EXEC}
      ${HLS_EXEC} -f ${SCRIPT}
  )

  # C/RTL simulation target
  vcmu_create_tcl_script(hls cosim.tcl)
  add_custom_target(cosim_${project}
    DEPENDS csynth_${project}
    COMMAND
      # Define Environment Variables
      # Call ${HLS_EXEC}
      ${HLS_EXEC} -f ${SCRIPT}
  )


  # delete project target
  add_custom_target(clear_${project}
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${PRJ_DIR}
  )

  # open project
  add_custom_target(open_${project}
    COMMAND ${HLS_EXEC} -p ${PRJ_DIR}&
  )

  # open wave file
  set(WAVE_DATABASE ${PRJ_DIR}/${SOLUTION}/sim/verilog/${HARG_TOP}.wdb)
  if (EXISTS ${HLS_VIVADO_EXE})
    add_custom_target(wave_${project}
      COMMAND ${HLS_VIVADO_EXE} ${WAVE_DATABASE}&
    )
  endif()

endfunction()

#
# Define header only library for Vivado/Vitis HLS
#
# add_hls_interface(project
#   [INCDIRS <directory>...]
#   [DEPENDS <target>...]
# )
#
# Argument:
#   project: interface library target name
#
# Options:
#  INCDIRS: header directories.
#           If this option is not specified, the current directory is set.
#  DEPENDS: depends targets
#
# Targets:
#   ${project}: interface library target
#
function(add_hls_interface project)
  cmake_parse_arguments(
    HARG
    ""
    ""
    "INCDIRS;DEPENDS;"
    ${ARGN}
  )
  add_library(${project} INTERFACE)
  if(NOT HARG_INCDIRS)
    target_include_directories(${project}
      INTERFACE
        ${HLS_INCLUDE_DIR}
        ${CMAKE_CURRENT_SOURCE_DIR} # default
    )
  else()
    target_include_directories(${project}
      INTERFACE
        ${HLS_INCLUDE_DIR}
        ${HARG_INCDIRS}
    )
  endif()
  if (HARG_DEPENDS)
    add_dependencies(${project} ${HARG_DEPENDS})
  endif()
endfunction()
