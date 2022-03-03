# find vivado from
#  You can change the search location by
#  setting the following variables.
#
#  VIVADO_ROOT
#  XILINX_VIVADO Environment variable
#
# exp) cmake -DVIVADO_ROOT=/c/Xilinx/Vivado/2021.1
#
find_path(VIVADO_BIN_DIR
  vivado
  PATHS ${VIVADO_ROOT} ENV XILINX_VIVADO
  PATH_SUFFIXES bin
)

# save currrent directory
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

# xsdb target
if(WIN32)
  add_custom_target(xsdb
    COMMAND ${VIVADO_BIN_DIR}/xsdb.bat
  )
else()
  add_custom_target(xsdb
    COMMAND ${VIVADO_BIN_DIR}/xsdb
  )
endif()

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
# )
#
# Define Targets:
#  ${project}                : Create Vivado project
#  clear_${project}          : Delete Vivado project directory
#  impl_${project}           : Create bit stream
#   _impl_${project}_original: Run vivado to genenarate bitstream
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
#
function(add_vivado_project project)
  cmake_parse_arguments(
    VIVADO_ADD_PROJECT
    ""
    "BOARD;DESIGN;DIR;TOP"
    "RTL;CONSTRAINT;IP;DEPENDS"
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

  # replace ";" -> " " for tcl scripts
  string(REPLACE ";" " " VIVADO_ADD_PROJECT_RTL_0        "${VIVADO_ADD_PROJECT_RTL_0}")
  string(REPLACE ";" " " VIVADO_ADD_PROJECT_IP_0         "${VIVADO_ADD_PROJECT_IP_0}")
  string(REPLACE ";" " " VIVADO_ADD_PROJECT_CONSTRAINT_0 "${VIVADO_ADD_PROJECT_CONSTRAINT_0}")

  # define ${project} target(create Vivado project)
  set(VIVADO_ADD_PROJECT_DIR_0 ${CMAKE_CURRENT_BINARY_DIR}/${VIVADO_ADD_PROJECT_DIR})
  set(VIVADO_ADD_PROJECT_PROJECT ${VIVADO_ADD_PROJECT_DIR_0}/${project}.xpr)
  add_custom_target(${project} SOURCES ${VIVADO_ADD_PROJECT_PROJECT})
  add_custom_command(
    OUTPUT ${VIVADO_ADD_PROJECT_PROJECT}
    DEPENDS ${VIVADO_ADD_PROJECT_DEPENDS}
    COMMAND
      # Define global
      VIVADO_DESIGN_TCL=${VIVADO_ADD_PROJECT_DESIGN}
      VIVADO_RTL_LIST="${VIVADO_ADD_PROJECT_RTL_0}"
      VIVADO_CONSTRAINT_LIST="${VIVADO_ADD_PROJECT_CONSTRAINT_0}"
      VIVADO_IP_DIRECTORIES="${VIVADO_ADD_PROJECT_IP_0}"
      # Call vitis_hls
      ${VIVADO_BIN_DIR}/vivado
        -mode batch
        -source ${VIVADO_TCL_DIR}/create_vivado_project.tcl
        -tclargs
          ${project}
          ${VIVADO_ADD_PROJECT_DIR}
          ${VIVADO_ADD_PROJECT_BOARD}
          ${VIVADO_ADD_PROJECT_DIR_0}
  )

  # synthesis,impl,gen bitstream target
  set(VIVADO_ADD_PROJECT_BIT ${VIVADO_ADD_PROJECT_DIR_0}/${project}.runs/impl_1/${VIVADO_ADD_PROJECT_TOP}.bit)
  set(VIVADO_ADD_PROJECT_BIT_COPY ${VIVADO_CMAKE_BINARY_DIR}/bit/${project}.bit)
  #    Run  vivado   : _impl_${project}_original target
  #    Copy bitstream: impl_${project} target
  add_custom_target(_impl_${project}_original SOURCES ${VIVADO_ADD_PROJECT_BIT})
  add_custom_target(impl_${project}
    DEPENDS _impl_${project}_original
    COMMAND ${CMAKE_COMMAND} -E copy ${VIVADO_ADD_PROJECT_BIT} ${VIVADO_ADD_PROJECT_BIT_COPY}
    COMMAND ${CMAKE_COMMAND} -E copy ${VIVADO_ADD_PROJECT_DIR_0}/${project}.runs/impl_1/${VIVADO_ADD_PROJECT_TOP}.* ${VIVADO_CMAKE_BINARY_DIR}/bit/
    COMMAND echo "Output BitStream: ${VIVADO_ADD_PROJECT_BIT} ${VIVADO_ADD_PROJECT_BIT_COPY}"
  )
  add_custom_command(
    OUTPUT ${VIVADO_ADD_PROJECT_BIT}
    DEPENDS ${project}
    COMMAND
      # Call vitis_hls
      ${VIVADO_BIN_DIR}/vivado
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

endfunction()
