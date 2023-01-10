# find vivado from
#  You can change the search location by
#  setting the following variables.
#
#  VIVADO_ROOT
#  XILINX_VIVADO Environment variable
#
# exp) cmake -DVIVADO_ROOT=/c/Xilinx/Vivado/2021.1
#

#default value
set(VIVADO_DEFAULT_IMPL "impl_1" CACHE STRING "default vivado impl name")
set(VIVADO_JOB "0" CACHE STRING "vivado implement job size")

# find path
find_path(VIVADO_BIN_DIR
  vivado
  PATHS ${VIVADO_ROOT} ENV XILINX_VIVADO
  PATH_SUFFIXES bin
)

# save currrent directory
if(NOT VIVADO_PROJECT_REPOGITORY_ROOT_DIR)
  # `root` variable of create_vivado_project.tcl
  set(VIVADO_PROJECT_REPOGITORY_ROOT_DIR ${CMAKE_CURRENT_SOURCE_DIR})
endif()
set(VIVADO_CMAKE_DIR ${CMAKE_CURRENT_LIST_DIR})
set(VIVADO_TCL_DIR ${CMAKE_CURRENT_LIST_DIR}/tcl)
set(VIVADO_CMAKE_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR})

# hide variable
mark_as_advanced(VIVADO_BIN_DIR VIVADO_CMAKE_DIR VIVADO_TCL_DIR)

# find package
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Vivado
  REQUIRED_VARS
    VIVADO_BIN_DIR
)

# VIVADO_VERSION: Vivado Version
get_filename_component(VIVADO_VERSION "${VIVADO_BIN_DIR}" DIRECTORY)
get_filename_component(VIVADO_VERSION "${VIVADO_VERSION}" NAME)



if(VIVADO_JOB EQUAL 0)
  set(VIVADO_JOB_SIZE ${VIVADO_JOB})
else()
  include(ProcessorCount)
  ProcessorCount(VIVADO_JOB_SIZE)
  if(VIVADO_JOB_SIZE EQUAL 0)
    set(VIVADO_JOB_SIZE 1)
  endif()
endif()
set(VIVADO_EXE ${VIVADO_BIN_DIR}/vivado)

# xsdb target
if(WIN32)
  set(VIVADO_XSDB_EXE ${VIVADO_BIN_DIR}/xsdb.bat)
else()
  set(VIVADO_XSDB_EXE ${VIVADO_BIN_DIR}/xsdb)
endif()

# write bitstream command
#  ${VIVADO_XSDB_EXE} bitstream [make target name]
set(VIVADO_WRITE_BITSTREAM ${VIVADO_XSDB_EXE} ${VIVADO_TCL_DIR}/xsdb_program.tcl)

add_custom_target(xsdb
  COMMAND ${VIVADO_XSDB_EXE}
)

# add_vivado_project(
#    <project>
#    BOARD <board name>
#    TOP   <top module>
#    [DIR <directory name>]
#    [RTL <file/directory>...]
#    [CONSTRAINT <file/directory>...]
#    [IP <directory>...]
#    [DESIGN <tcl file>]
#    [DEPENDS <target>...]
#    [TCL1   <tcl file>...]
#    [TCL2   <tcl file>...]
#    [DFX    <tcl file>]
# )
#
# Define Targets:
#  ${project}                : Create Vivado project
#                            :    target property:
#                            :        PROJECT_NAME   : project name
#                            :        PROJECT_DIR    : project directory path
#                            :        PROJECT_FILE   : xpr file path
#                            :        RUNS_DIR       : .runs directory path
#                            :        IMPL           : default implementation name
#                            :        IMPLS          : implementation list
#                            :        TOP_MODULE     : top module name
#                            :        TOP_BITSTREAM  : top bit stream path
#                            :        TOP_LTX        : top bit stream ltx path
#                            :        IMPL_TARGET    : implementation target name
#                            :
#  open_${project}           : Open project in vivado
#  clear_${project}          : Delete Vivado project directory
#  impl_${project}           : Create bit stream (run impl)
#  program_${project}        : Write bitstream
#                            :   Environment:
#                            :      JTAG    : jtag target
#                            :      XSDB_URL: (option) connect url
#                            :   exp) make JTAG=1 program_${project}
#  export_bd_${project}      : Save IP Integrator design tcl file
#  report_addr_${project}    : Report address
#                            :   Environment:
#                            :      REPORT_CSV: output csv file name
#                            :  exp) make REPORT_CSV=foobar.csv report_addr_${project}
#
# Argument:
#  project: target name
#
# Taged Arguments
#  BOARD  : board property
#  TOP    : Top module name
#
# Options
#  DIR        : project directory name (default is ${projet}.prj)
#  RTL        : RTL files
#  CONSTRAINT : constraint files
#  IP         : IP directories
#  DESIGN     : Design tcl file
#  DEPENDS    : depends
#  TCL1       : Tcl script file. This file will be loaded after adding RTL/constraints files in `create_vivado_project.tcl`.
#  DFX        : Enable Dynamic Function eXchange(Partial Reconfigu), and load setting tcl file.
#  TCL2       : Tcl script file. This file will be loaded before closeing project in `create_vivado_project.tcl`.
#  IMPLEMENTS : impelmentation name list
#
function(add_vivado_project project)
  cmake_parse_arguments(
    VIVADO_ADD_PROJECT
    ""
    "BOARD;DESIGN;DIR;TOP;DFX"
    "RTL;CONSTRAINT;IP;DEPENDS;IMPLEMENTS;TCL1;TCL2"
    ${ARGN}
  )

  # Check arguments
  if(NOT VIVADO_ADD_PROJECT_BOARD)
    message(FATAL_ERROR "add_vivado_project: BOARD is not defined.")
  endif()

  if(NOT VIVADO_ADD_PROJECT_TOP)
    message(FATAL_ERROR "add_vivado_project: TOP (top module name) is not defined.")
  endif()

  # set default option value
  if(NOT VIVADO_ADD_PROJECT_DIR)
    set(VIVADO_ADD_PROJECT_DIR "${project}.prj")
  endif()

  # fix relative path
  set(VIVADO_ADD_PROJECT_RTL_0)
  foreach(VIVADO_ADD_PROJECT_PATH IN LISTS VIVADO_ADD_PROJECT_RTL)
    if (IS_ABSOLUTE ${VIVADO_ADD_PROJECT_PATH})
      list(APPEND VIVADO_ADD_PROJECT_RTL_0 ${VIVADO_ADD_PROJECT_PATH})
    else()
      list(APPEND VIVADO_ADD_PROJECT_RTL_0 ${CMAKE_CURRENT_SOURCE_DIR}/${VIVADO_ADD_PROJECT_PATH})
    endif()
  endforeach()

  set(VIVADO_ADD_PROJECT_CONSTRAINT_0)
  foreach(VIVADO_ADD_PROJECT_PATH IN LISTS VIVADO_ADD_PROJECT_CONSTRAINT)
    if (IS_ABSOLUTE ${VIVADO_ADD_PROJECT_PATH})
      list(APPEND VIVADO_ADD_PROJECT_CONSTRAINT_0 ${VIVADO_ADD_PROJECT_PATH})
    else()
      list(APPEND VIVADO_ADD_PROJECT_CONSTRAINT_0 ${CMAKE_CURRENT_SOURCE_DIR}/${VIVADO_ADD_PROJECT_PATH})
    endif()
  endforeach()

  set(VIVADO_ADD_PROJECT_IP_0)
  foreach(VIVADO_ADD_PROJECT_PATH IN LISTS VIVADO_ADD_PROJECT_IP)
    if (IS_ABSOLUTE ${VIVADO_ADD_PROJECT_PATH})
      list(APPEND VIVADO_ADD_PROJECT_IP_0 ${VIVADO_ADD_PROJECT_PATH})
    else()
      list(APPEND VIVADO_ADD_PROJECT_IP_0 ${CMAKE_CURRENT_SOURCE_DIR}/${VIVADO_ADD_PROJECT_PATH})
    endif()
  endforeach()

  if(VIVADO_ADD_PROJECT_DESIGN)
    if (NOT IS_ABSOLUTE ${VIVADO_ADD_PROJECT_DESIGN})
      set(VIVADO_ADD_PROJECT_DESIGN ${CMAKE_CURRENT_SOURCE_DIR}/${VIVADO_ADD_PROJECT_DESIGN})
    endif()
  endif()

  set(VIVADO_ADD_PROJECT_TCL1_0)
  foreach(VIVADO_ADD_PROJECT_PATH IN LISTS VIVADO_ADD_PROJECT_TCL1)
    if (IS_ABSOLUTE ${VIVADO_ADD_PROJECT_PATH})
      list(APPEND VIVADO_ADD_PROJECT_TCL1_0 ${VIVADO_ADD_PROJECT_PATH})
    else()
      list(APPEND VIVADO_ADD_PROJECT_TCL1_0 ${CMAKE_CURRENT_SOURCE_DIR}/${VIVADO_ADD_PROJECT_PATH})
    endif()
  endforeach()

  set(VIVADO_ADD_PROJECT_TCL2_0)
  foreach(VIVADO_ADD_PROJECT_PATH IN LISTS VIVADO_ADD_PROJECT_TCL2)
    if (IS_ABSOLUTE ${VIVADO_ADD_PROJECT_PATH})
      list(APPEND VIVADO_ADD_PROJECT_TCL2_0 ${VIVADO_ADD_PROJECT_PATH})
    else()
      list(APPEND VIVADO_ADD_PROJECT_TCL2_0 ${CMAKE_CURRENT_SOURCE_DIR}/${VIVADO_ADD_PROJECT_PATH})
    endif()
  endforeach()

  if(VIVADO_ADD_PROJECT_DFX)
    if (NOT IS_ABSOLUTE ${VIVADO_ADD_PROJECT_DFX})
      set(VIVADO_ADD_PROJECT_DFX ${CMAKE_CURRENT_SOURCE_DIR}/${VIVADO_ADD_PROJECT_DFX})
    endif()
  endif()

  # replace ";" -> " " for tcl scripts
  string(REPLACE ";" " " VIVADO_ADD_PROJECT_RTL_0        "${VIVADO_ADD_PROJECT_RTL_0}")
  string(REPLACE ";" " " VIVADO_ADD_PROJECT_IP_0         "${VIVADO_ADD_PROJECT_IP_0}")
  string(REPLACE ";" " " VIVADO_ADD_PROJECT_CONSTRAINT_0 "${VIVADO_ADD_PROJECT_CONSTRAINT_0}")
  string(REPLACE ";" " " VIVADO_ADD_PROJECT_IMPLEMENTS_0 "${VIVADO_ADD_PROJECT_IMPLEMENTS}")
  string(REPLACE ";" " " VIVADO_ADD_PROJECT_TCL1_1 "${VIVADO_ADD_PROJECT_TCL1_0}")
  string(REPLACE ";" " " VIVADO_ADD_PROJECT_TCL2_1 "${VIVADO_ADD_PROJECT_TCL2_0}")

  # define ${project} target(create Vivado project)
  set(VIVADO_ADD_PROJECT_DIR_0 ${CMAKE_CURRENT_BINARY_DIR}/${VIVADO_ADD_PROJECT_DIR})
  set(VIVADO_ADD_PROJECT_PROJECT ${VIVADO_ADD_PROJECT_DIR_0}/${project}.xpr)
  add_custom_target(${project} SOURCES ${VIVADO_ADD_PROJECT_PROJECT})
  set_target_properties(${project}
    PROPERTIES
      PROJECT_DIR  ${VIVADO_ADD_PROJECT_DIR_0}
      RUNS_DIR  ${VIVADO_ADD_PROJECT_DIR_0}/${project}.runs
      PROJECT_FILE ${VIVADO_ADD_PROJECT_PROJECT})
  add_custom_command(
    OUTPUT ${VIVADO_ADD_PROJECT_PROJECT}
    DEPENDS
      ${VIVADO_ADD_PROJECT_DEPENDS}
      ${VIVADO_ADD_PROJECT_TCL1_0}
      ${VIVADO_ADD_PROJECT_TCL2_0}
    COMMAND
      # Define global
      VIVADO_DESIGN_TCL=${VIVADO_ADD_PROJECT_DESIGN}
      VIVADO_RTL_LIST="${VIVADO_ADD_PROJECT_RTL_0}"
      VIVADO_CONSTRAINT_LIST="${VIVADO_ADD_PROJECT_CONSTRAINT_0}"
      VIVADO_IP_DIRECTORIES="${VIVADO_ADD_PROJECT_IP_0}"
      VIVADO_CREATE_PROJECT_SOURCE_0="${VIVADO_ADD_PROJECT_TCL1_1}"
      VIVADO_CREATE_PROJECT_SOURCE_1="${VIVADO_ADD_PROJECT_TCL2_1}"
      VIVADO_DFX_TCL="${VIVADO_ADD_PROJECT_DFX}"
      # Call vivado
      ${VIVADO_EXE}
        -mode batch
        -source ${VIVADO_TCL_DIR}/create_vivado_project.tcl
        -tclargs
          ${project}
          ${VIVADO_ADD_PROJECT_DIR}
          ${VIVADO_ADD_PROJECT_BOARD}
          ${VIVADO_ADD_PROJECT_DIR_0}
          ${VIVADO_ADD_PROJECT_TOP}
          ${CMAKE_CURRENT_SOURCE_DIR}
          ${VIVADO_PROJECT_REPOGITORY_ROOT_DIR}
  )

  # open project in vivado
  add_custom_target(open_${project}
    DEPENDS ${VIVADO_ADD_PROJECT_PROJECT}
    COMMAND ${VIVADO_EXE} ${VIVADO_ADD_PROJECT_PROJECT} &
  )

  # get default impl name
  # The next line MUST NOT be moved before defining VIVADO_ADD_PROJECT_IMPLEMENTS_0.
  # VIVADO_ADD_PROJECT_IMPLEMENTS_0 must be empty when IMPLEMENTS is not defined.
  if(NOT VIVADO_ADD_PROJECT_IMPLEMENTS)
    set(VIVADO_ADD_PROJECT_IMPLEMENTS ${VIVADO_DEFAULT_IMPL})
  endif()
  list(GET ${VIVADO_ADD_PROJECT_IMPLEMENTS} 0 VIVADO_ADD_PROJECT_DEFAULT_IMPL)

  # synthesis,impl,gen bitstream target
  set(VIVADO_ADD_PROJECT_RUNS_DIR ${VIVADO_ADD_PROJECT_DIR_0}/${project}.runs)
  set(VIVADO_ADD_PROJECT_BIT ${VIVADO_ADD_PROJECT_RUNS_DIR}/${VIVADO_ADD_PROJECT_DEFAULT_IMPL}/${VIVADO_ADD_PROJECT_TOP}.bit)
  set(VIVADO_ADD_PROJECT_LTX ${VIVADO_ADD_PROJECT_RUNS_DIR}/${VIVADO_ADD_PROJECT_DEFAULT_IMPL}/${VIVADO_ADD_PROJECT_TOP}.ltx)

  #    run impl: impl_${project} target
  add_custom_target(impl_${project} SOURCES ${VIVADO_ADD_PROJECT_BIT})
  add_custom_command(
    OUTPUT ${VIVADO_ADD_PROJECT_BIT}
    DEPENDS ${project} ${VIVADO_ADD_PROJECT_DESIGN}
    COMMAND
      # Define global
      VIVADO_DESIGN_TCL=${VIVADO_ADD_PROJECT_DESIGN}
      VIVADO_JOB_SIZE=${VIVADO_JOB_SIZE}
      VIVADO_IMPLEMENTS="${VIVADO_ADD_PROJECT_IMPLEMENTS_0}"
      # Call vivado
      ${VIVADO_EXE}
        -mode batch
        -source ${VIVADO_TCL_DIR}/implement.tcl
        -tclargs
          ${project}
          ${VIVADO_ADD_PROJECT_DIR}
  )

  # delete project target
  add_custom_target(clear_${project}
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${VIVADO_ADD_PROJECT_DIR_0}
    COMMAND ${CMAKE_COMMAND} -E remove ${CMAKE_CURRENT_BINARY_DIR}/vivado*
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_CURRENT_BINARY_DIR}/.Xil
  )

  # write bitstream
  add_custom_target(program_${project}
    DEPENDS impl_${project}
    COMMAND ${VIVADO_WRITE_BITSTREAM} ${VIVADO_ADD_PROJECT_BIT} program_${project}
  )


  if(VIVADO_ADD_PROJECT_DESIGN)
    # write bd tcl file
    add_custom_target(
      export_bd_${project}
      COMMAND
      # Call vivado
      ${VIVADO_EXE}
        -mode batch
        -source ${VIVADO_TCL_DIR}/export_bd.tcl
        -tclargs
          ${project}
          ${VIVADO_ADD_PROJECT_DIR}
          ${VIVADO_TCL_DIR}
          ${VIVADO_ADD_PROJECT_DESIGN}
          ""
    )

    # report address
    add_custom_target(
      report_addr_${project}
      COMMAND
      # Call vivado
      ${VIVADO_EXE}
        -mode batch
        -source ${VIVADO_TCL_DIR}/report_addr.tcl
        -tclargs
          ${project}
          ${VIVADO_ADD_PROJECT_DIR}
          ${VIVADO_TCL_DIR}
          report_addr_${project}
          ${VIVADO_CMAKE_BINARY_DIR}
          ""
    )
  endif()

  # set target property
  set_target_properties(${project}
    PROPERTIES
      PROJECT_NAME   ${project}
      PROJECT_DIR    ${VIVADO_ADD_PROJECT_DIR_0}
      RUNS_DIR       ${VIVADO_ADD_PROJECT_RUNS_DIR}
      PROJECT_FILE   ${VIVADO_ADD_PROJECT_PROJECT}
      TOP_MODULE     ${VIVADO_ADD_PROJECT_TOP}
      TOP_BITSTREAM  ${VIVADO_ADD_PROJECT_BIT}
      TOP_LTX        ${VIVADO_ADD_PROJECT_LTX}
      IMPL_TARGET    impl_${project}
      IMPL           "${VIVADO_ADD_PROJECT_DEFAULT_IMPL}"
      IMPLS          "${VIVADO_ADD_PROJECT_IMPLEMENTS}"
  )
endfunction()

# add_write_bitstream(project target_subname bitstream_path)
# add new target to write bitstream of project
#  Argument:
#      project        : target project
#      target_subname : write bitstream target name
#      bitstream_path : bitstream file path from project runs directory
#
#  Target:
#      program_${project}_${target_subname}
#           Environment:
#              JTAG    : jtag target
#              XSDB_URL: (option) connect url
#           exp) make JTAG=1 program_${project}_${target_subname}
#
function(add_write_bitstream project target_subname bitstream_path)
  add_custom_target(program_${project}_${target_subname}
    DEPENDS $<TARGET_PROPERTY:${project},IMPL_TARGET>
    COMMAND ${VIVADO_WRITE_BITSTREAM}
     $<TARGET_PROPERTY:${project},RUNS_DIR>/${bitstream_path}
     program_${project}_${target_subname}
  )

endfunction()
