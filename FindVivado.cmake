# find vivado from
#  You can change the search location by
#  setting the following variables.
#
#  VIVADO_ROOT
#  XILINX_VIVADO Environment variable
#
# exp) cmake -DVIVADO_ROOT=/c/Xilinx/Vivado/2021.1
#
# VIVADO_REQUIRED_VERSION: Vivado version.
#   set(VIVADO_REQUIRED_VERSION 2022.1)
#

#default value
set(VIVADO_DEFAULT_IMPL "impl_1" CACHE STRING "default vivado impl name")
set(VIVADO_JOB "0" CACHE STRING "vivado implement job size")

include(${CMAKE_CURRENT_LIST_DIR}/utils.cmake)

# find path
vcmu_find_vivado_bin(VIVADO_BIN_DIR VIVADO_REQUIRED_VERSION VIVADO_REQUIRED_VERSION)

# find package
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Vivado
  REQUIRED_VARS
    VIVADO_BIN_DIR
)

# VIVADO_VERSION: Vivado Version
get_filename_component(VIVADO_VERSION "${VIVADO_BIN_DIR}" DIRECTORY)
get_filename_component(VIVADO_VERSION "${VIVADO_VERSION}" NAME)

if (VIVADO_REQUIRED_VERSION)
  if (NOT ${VIVADO_REQUIRED_VERSION} VERSION_EQUAL ${VIVADO_VERSION})
    message("  Found Vivado Path: ${VIVADO_BIN_DIR}/vivado")
    message(FATAL_ERROR "Found Vivado ${VIVADO_VERSION}. Reuquired Vivado ${VIVADO_REQUIRED_VERSION}")
  endif()
endif()

# save currrent directory
if(NOT VIVADO_PROJECT_REPOGITORY_ROOT_DIR)
  # `root` variable of create_vivado_project.tcl
  set(VIVADO_PROJECT_REPOGITORY_ROOT_DIR ${CMAKE_CURRENT_SOURCE_DIR})
endif()
set(VIVADO_CMAKE_DIR ${CMAKE_CURRENT_LIST_DIR})
set(VIVADO_TCL_DIR ${CMAKE_CURRENT_LIST_DIR}/tcl)
set(VIVADO_CMAKE_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR})
include(ProcessorCount)
ProcessorCount(VIVADO_PROCESSOR_COUNT)

# hide variable
mark_as_advanced(VIVADO_BIN_DIR VIVADO_CMAKE_DIR VIVADO_TCL_DIR VIVADO_PROCESSOR_COUNT)





macro (get_vivado_job_size OUTVAR)
  if(${VIVADO_JOB} STREQUAL "0")
    set(${OUTVAR} ${VIVADO_PROCESSOR_COUNT})
    if(${${OUTVAR}} EQUAL 0)
      set(${OUTVAR} 1)
    endif()
  else()
    set(${OUTVAR} ${VIVADO_JOB})
  endif()
endmacro()

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

add_custom_target(launch_vivado
  COMMAND ${VIVADO_EXE} &
)

include(${CMAKE_CURRENT_LIST_DIR}/utils.cmake)

# add_vivado_project(
#    <project>
#    BOARD <board name>
#    TOP   <top module>
#    [WD  <working directory>]
#    [DIR <directory name>]
#    [RTL <file/directory>...]
#    [CONSTRAINT <file/directory>...]
#    [IP <directory>...]
#    [DESIGN <tcl file>]
#    [DEPENDS <target>...]
#    [TCL0   <tcl file>...]
#    [TCL1   <tcl file>...]
#    [TCL2   <tcl file>...]
#    [DFX    <tcl file>]
#    [BOARD_REPO <directory>...]
#    [IMPLEMENTS <implimentation name>...]
#    [BETA   <beta device pattern>]
#    [PDI]
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
#                            :      JTAG     : jtag target
#                            :      HWSVR    : (option) connect url
#                            :      HWSVRPORT: (option) connect port
#                            :   exp) make JTAG=1 program_${project}
#  export_bd_${project}      : Save IP Integrator design tcl file
#  report_addr_${project}    : Report address
#                            :   Environment:
#                            :      REPORT_CSV: output csv file name
#                            :  exp) make REPORT_CSV=foobar.csv report_addr_${project}
#  xsa_${project}            : Export xsa file
#
# Argument:
#  project: target name
#
# Taged Arguments
#  BOARD  : board property
#  TOP    : Top module name
#
# Options
#  WD         : Working Directory
#  DIR        : project directory name (default is ${WD}/${projet}.prj)
#  RTL        : RTL files
#  CONSTRAINT : constraint files
#  IP         : IP directories
#  DESIGN     : Design tcl file
#  DEPENDS    : depends
#  TCL0       : Tcl script file. This file will be loaded before `create_project` command.
#  TCL1       : Tcl script file. This file will be loaded after adding RTL/constraints files in `create_vivado_project.tcl`.
#  DFX        : Enable Dynamic Function eXchange(Partial Reconfigu), and load setting tcl file.
#  TCL2       : Tcl script file. This file will be loaded before closeing project in `create_vivado_project.tcl`.
#  IMPLEMENTS : impelmentation name list
#  BOARD_REPO : set_param board.repoPaths
#  BETA       : enable_beta_device command arguments.
#  PDI        : PDI file(*.pdi) is generated, used for Versal instead of bitstream.
#
function(add_vivado_project project)
  cmake_parse_arguments(
    VARG
    "PDI"
    "BOARD;DIR;TOP;DFX;WD"
    "RTL;CONSTRAINT;IP;DEPENDS;IMPLEMENTS;TCL0;TCL1;TCL2;BOARD_REPO;DESIGN;BETA;"
    ${ARGN}
  )

  # Check arguments
  if (NOT VARG_BOARD)
    message(FATAL_ERROR "add_vivado_project: BOARD is not defined.")
  endif()

  if (NOT VARG_TOP)
    message(FATAL_ERROR "add_vivado_project: TOP (top module name) is not defined.")
  endif()

  # set default option value
  if (NOT VARG_DIR)
    set(VARG_DIR "${project}.prj")
  endif()

  if (NOT VARG_WD)
    set(WD ${CMAKE_CURRENT_BINARY_DIR})
  else()
    set(WD ${VARG_WD})
  endif()

  # filename extension
  if (NOT VARG_PDI)
    set(BIT_EXT "bit")
    set(PDI FALSE)
    set(USE_PDI 0)
  else()
    set(BIT_EXT "pdi")
    set(PDI TRUE)
    set(USE_PDI 1)
  endif()
  set(DBG_EXT "ltx")

  # fix relative path
  vcmu_map_abs_path(VARG_BOARD_REPO BOARD_REPO)
  vcmu_map_abs_path(VARG_RTL RTL_LIST)
  vcmu_map_abs_path(VARG_CONSTRAINT CONSTRAINT_LIST)
  vcmu_map_abs_path(VARG_IP IP_LIST)

  if (VARG_DESIGN)
    vcmu_map_abs_path(VARG_DESIGN DESIGN)
  else()
    set(DESIGN "")
  endif()

  vcmu_map_abs_path(VARG_TCL0 TCL0_LIST)
  vcmu_map_abs_path(VARG_TCL1 TCL1_LIST)
  vcmu_map_abs_path(VARG_TCL1 TCL2_LIST)

  if (VARG_DFX)
    vcmu_to_abs_path(${VARG_DFX} DFX)
  else()
    set(DFX "")
  endif()
  set(PRJDIR ${WD}/${VARG_DIR})
  set(PRJFILE ${PRJDIR}/${project}.xpr)

  if(NOT VARG_IMPLEMENTS)
    set(VARG_IMPLEMENTS ${VIVADO_DEFAULT_IMPL})
  endif()
  list(GET VARG_IMPLEMENTS 0 VARG_DEFAULT_IMPL)

  # Generate variable TCL file
  set(ENV_FILE ${CMAKE_CURRENT_BINARY_DIR}/env_vivado_${project}.tcl)
  vcmu_env_file_init(${ENV_FILE})
  vcmu_env_file_add_list(${ENV_FILE} rtl RTL_LIST)
  vcmu_env_file_add_list(${ENV_FILE} constrs CONSTRAINT_LIST)
  vcmu_env_file_add_list(${ENV_FILE} ips IP_LIST)
  vcmu_env_file_add_list(${ENV_FILE} tcl0 TCL0_LIST)
  vcmu_env_file_add_list(${ENV_FILE} tcl1 TCL1_LIST)
  vcmu_env_file_add_list(${ENV_FILE} tcl2 TCL2_LIST)
  vcmu_env_file_add_list(${ENV_FILE} designs DESIGN)
  vcmu_env_file_add_var(${ENV_FILE} board_part "${VARG_BOARD}")
  vcmu_env_file_add_list(${ENV_FILE} boardRepos BOARD_REPO)
  vcmu_env_file_add_var(${ENV_FILE} dfx "${DFX}")
  vcmu_env_file_add_var(${ENV_FILE} project_name "${project}")
  vcmu_env_file_add_var(${ENV_FILE} project_directory "${PRJDIR}")
  vcmu_env_file_add_var(${ENV_FILE} project_file "${PRJFILE}")
  vcmu_env_file_add_var(${ENV_FILE} top_module_name "${VARG_TOP}")
  vcmu_env_file_add_var(${ENV_FILE} tcl_directory "${VIVADO_TCL_DIR}")
  vcmu_env_file_add_var(${ENV_FILE} root "${VIVADO_PROJECT_REPOGITORY_ROOT_DIR}")
  vcmu_env_file_add_list(${ENV_FILE} impls VARG_IMPLEMENTS)
  vcmu_env_file_add_var(${ENV_FILE} use_beta_device "${VARG_BETA}")
  vcmu_env_file_add_var(${ENV_FILE} use_pdi ${USE_PDI})

  # define ${project} target(create Vivado project)
  add_custom_target(${project} SOURCES ${PRJFILE})
  set_target_properties(${project}
    PROPERTIES
      PROJECT_DIR  ${PRJDIR}
      RUNS_DIR     ${PRJDIR}/${project}.runs
      PROJECT_FILE ${PRJFILE}
  )

  add_custom_command(
    OUTPUT ${PRJFILE}
    DEPENDS
      ${VARG_DEPENDS}
      ${TCL0_LIST}
      ${TCL1_LIST}
      ${TCL2_LIST}
      ${DFX}
    COMMAND
      # Call vivado
      ${VIVADO_EXE}
        -mode batch
        -notrace
        -source ${VIVADO_TCL_DIR}/create_vivado_project.tcl
        -tclargs ${ENV_FILE}
  )

  # open project in vivado
  add_custom_target(open_${project}
    COMMAND ${VIVADO_EXE} ${PRJFILE} &
  )

  # get default impl name
  # The next line MUST NOT be moved before defining VARG_IMPLEMENTS_0.
  # VARG_IMPLEMENTS_0 must be empty when IMPLEMENTS is not defined.

  # synthesis,impl,gen bitstream target
  set(RUNS_DIR ${PRJDIR}/${project}.runs)
  set(BITSTREAM ${RUNS_DIR}/${VARG_DEFAULT_IMPL}/${VARG_TOP}.${BIT_EXT})
  set(LTX ${RUNS_DIR}/${VARG_DEFAULT_IMPL}/${VARG_TOP}.${DBG_EXT})
  get_vivado_job_size(JOB_SIZE)

  #    run impl: impl_${project} target
  add_custom_target(impl_${project} SOURCES ${BITSTREAM})
  add_custom_command(
    OUTPUT ${BITSTREAM}
    DEPENDS ${project}
    COMMAND
      # Call vivado
      ${VIVADO_EXE}
        -mode batch
        -notrace
        -source ${VIVADO_TCL_DIR}/implement.tcl
        -tclargs ${ENV_FILE} ${JOB_SIZE}
  )

  # write bitstream
  add_custom_target(program_${project}
    DEPENDS impl_${project}
    COMMAND ${VIVADO_WRITE_BITSTREAM} ${BITSTREAM} program_${project}
  )


  if(VARG_DESIGN)
    # write bd tcl file
    add_custom_target(
      export_bd_${project}
      COMMAND
      # Call vivado
      ${VIVADO_EXE}
        -mode batch
        -notrace
        -source ${VIVADO_TCL_DIR}/export_bd.tcl
        -tclargs ${ENV_FILE}
    )

    # report address
    add_custom_target(
      report_addr_${project}
      COMMAND
      # Call vivado
      ${VIVADO_EXE}
        -mode batch
        -notrace
        -source ${VIVADO_TCL_DIR}/report_addr.tcl
        -tclargs
          ${ENV_FILE}
          report_addr_${project}
          ${WD}
    )
  endif()

  # export xsa file
  set (XSA_FILE ${WD}/${project}.xsa)
  add_custom_target(xsa_${project} SOURCES ${XSA_FILE})
  add_custom_command(
    OUTPUT ${XSA_FILE}
    DEPENDS impl_${project}
    COMMAND
    ${VIVADO_EXE}
      -mode batch
      -notrace
      -source ${VIVADO_TCL_DIR}/export_hw_platform.tcl
      -tclargs
        ${project}
        ${PRJDIR}
        ${XSA_FILE}
  )

  # delete project target
  add_custom_target(clear_${project}
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${PRJDIR}
    COMMAND ${CMAKE_COMMAND} -E remove ${CMAKE_CURRENT_BINARY_DIR}/vivado*
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_CURRENT_BINARY_DIR}/.Xil
    COMMAND ${CMAKE_COMMAND} -E remove ${WD}/vivado*
    COMMAND ${CMAKE_COMMAND} -E remove ${XSA_FILE}
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${WD}/.Xil
  )

  # set target property
  set_target_properties(${project}
    PROPERTIES
      VIVADO_PROJECT VIVADO
      PROJECT_NAME   ${project}
      PROJECT_DIR    ${PRJDIR}
      RUNS_DIR       ${RUNS_DIR}
      PROJECT_FILE   ${PRJFILE}
      TOP_MODULE     ${VARG_TOP}
      TOP_BITSTREAM  ${BITSTREAM}
      TOP_LTX        ${LTX}
      IMPL_TARGET    impl_${project}
      IMPL           "${VARG_DEFAULT_IMPL}"
      IMPLS          "${VARG_IMPLEMENTS}"
      XSA            ${XSA_FILE}
      PDI            ${PDI}
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
#              JTAG     : jtag target
#              HWSVR    : (option) connect url
#              HWSVRPORT: (option) connect port
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
