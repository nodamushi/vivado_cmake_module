find_path(HLS_BIN_DIR
  vitis_hls
  PATHS ${VITIS_HLS_ROOT} ENV XILINX_HLS
  PATH_SUFFIXES bin
)

find_path(HLS_INCLUDE_DIR
  NAMES hls_stream.h
  PATHS ${VITIS_HLS_ROOT} ENV XILINX_HLS
  PATH_SUFFIXES include
)

set(HLS_CMAKE_DIR ${CMAKE_CURRENT_LIST_DIR})
set(HLS_TCL_DIR ${CMAKE_CURRENT_LIST_DIR}/tcl)
set(HLS_CMAKE_LIB_DIR ${CMAKE_CURRENT_BINARY_DIR}/lib)

mark_as_advanced(HLS_INCLUDE_DIR HLS_CMAKE_DIR HLS_TCL_DIR HLS_CMAKE_LIB_DIR)


include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(HLS
  REQUIRED_VARS
    HLS_BIN_DIR
    HLS_INCLUDE_DIR
    HLS_TCL_DIR)

if(HLS_FOUND AND NOT TARGET HLS::HLS)
  add_library(HLS::HLS INTERFACE IMPORTED)
  set_target_properties(HLS::HLS
    PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES ${HLS_INCLUDE_DIR}
  )
endif()

# デフォルトの CFLAGS
set(HLS_CFLAGS -Wall)


function(add_hls_project project)
  # Argument
  #  project: target name
  #    : targets
  #    :    create_project_${project} : Create Vitis Project
  #    :    csynth_${project} : Run synthesis
  #    :    lib_${project} : Compile C++
  #    :    test_${project}: Compile TestBench
  #    :    cosim_${project}: C/RTL simulation
  #    :    clear_${project}: Delete Vitis project directory
  #
  # Taged Arguments
  #  TOP    : Top module name
  #  PERIOD : Clock Period (ns)
  #  PART   : Device part
  #  SOURCES: HLS source file
  #
  # Options
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
  #  TEST_LINK     : Link library for testing
  #  COSIM_LDFLAGS : cosim_design -ldflags
  #  COSIM_TRACE_LEVEL: none, all, port, port_hier
  #
  cmake_parse_arguments(
    HLS_ADD_PROJECT
    ""
    # Must: TOP,PERIOD,PART
    "TOP;PERIOD;PART;SOLUTION;FLOW_TARGET;VERSION;DESCRIPTION;NAME;IPNAME;TAXONOMY;VENDOR;COSIM_TRACE_LEVEL"
    # Must: SOURCES
    "SOURCES;TB_SOURCES;INCDIRS;TB_INCDIRS;DEPENDS;LINK;TEST_LINK;COSIM_LDFLAGS"
    ${ARGN}
  )

  if(NOT HLS_ADD_PROJECT_TOP)
    message(FATAL_ERROR "add_hls_project: TOP (top module name) is not defined.")
  endif()

  if(NOT HLS_ADD_PROJECT_PERIOD)
    message(FATAL_ERROR "add_hls_project: PERIOD (clock period) is not defined.")
  endif()

  if(NOT HLS_ADD_PROJECT_PART)
    message(FATAL_ERROR "add_hls_project: PART (device part) is not defined.")
  endif()

  if(NOT HLS_ADD_PROJECT_SOURCES)
    message(FATAL_ERROR "add_hls_project: SOURCES (HLS source file) is not defined.")
  endif()

  if(NOT HLS_ADD_PROJECT_VERSION)
    set(HLS_ADD_PROJECT_VERSION "0.0")
  endif()
  string(REPLACE "." "_" HLS_ADD_PROJECT_VERSION_ ${HLS_ADD_PROJECT_VERSION})

  if(NOT HLS_ADD_PROJECT_DESCRIPTION)
    set(HLS_ADD_PROJECT_DESCRIPTION ${project})
  endif()

  if(NOT HLS_ADD_PROJECT_NAME)
    set(HLS_ADD_PROJECT_NAME ${project})
  endif()


  if(NOT HLS_ADD_PROJECT_VENDOR)
  set(HLS_ADD_PROJECT_VENDOR "Anonymous")
  endif()

  if(NOT HLS_ADD_PROJECT_IPNAME)
    string(REPLACE "_" "." HLS_ADD_PROJECT_IPNAME "${project}")
  endif()

  if(NOT HLS_ADD_PROJECT_TAXONOMY)
    set(HLS_ADD_PROJECT_TAXONOMY "Virus")
  endif()



  set(HLS_ADD_PROJECT_SOURCES_0)
  foreach(HLS_ADD_PROJECT_SRC IN LISTS HLS_ADD_PROJECT_SOURCES)
    if (IS_ABSOLUTE ${HLS_ADD_PROJECT_SRC})
      list(APPEND HLS_ADD_PROJECT_SOURCES_0 ${HLS_ADD_PROJECT_SRC})
    else()
      list(APPEND HLS_ADD_PROJECT_SOURCES_0 ${CMAKE_CURRENT_SOURCE_DIR}/${HLS_ADD_PROJECT_SRC})
    endif()
  endforeach()

  set(HLS_ADD_PROJECT_TB_SOURCES_0)
  foreach(HLS_ADD_PROJECT_SRC IN LISTS HLS_ADD_PROJECT_TB_SOURCES)
    if (IS_ABSOLUTE ${HLS_ADD_PROJECT_SRC})
      list(APPEND HLS_ADD_PROJECT_TB_SOURCES_0 ${HLS_ADD_PROJECT_SRC})
    else()
      list(APPEND HLS_ADD_PROJECT_TB_SOURCES_0 ${CMAKE_CURRENT_SOURCE_DIR}/${HLS_ADD_PROJECT_SRC})
    endif()
  endforeach()


  if(NOT HLS_ADD_PROJECT_SOLUTION)
    set(HLS_ADD_PROJECT_SOLUTION "solution1")
  endif()

  if(NOT HLS_ADD_PROJECT_FLOW_TARGET)
    set(HLS_ADD_PROJECT_FLOW_TARGET "vivado")
  endif()

  set(HLS_ADD_PROJECT_CFLAG ${HLS_CFLAGS} -I${CMAKE_CURRENT_SOURCE_DIR})
  foreach(HLS_ADD_PROJECT_INCDIR IN LISTS HLS_ADD_PROJECT_INCDIRS)
    if (IS_ABSOLUTE ${HLS_ADD_PROJECT_INCDIR})
      list(APPEND HLS_ADD_PROJECT_CFLAG -I${HLS_ADD_PROJECT_INCDIR})
    else()
      list(APPEND HLS_ADD_PROJECT_CFLAG -I${CMAKE_CURRENT_SOURCE_DIR}/${HLS_ADD_PROJECT_INCDIR})
    endif()
  endforeach()

  get_directory_property(HLS_ADD_PROJECT_INCDIRS_2 INCLUDE_DIRECTORIES)
  foreach(HLS_ADD_PROJECT_INCDIR IN LISTS HLS_ADD_PROJECT_INCDIRS_2)
    if (IS_ABSOLUTE ${HLS_ADD_PROJECT_INCDIR})
      list(APPEND HLS_ADD_PROJECT_CFLAG -I${HLS_ADD_PROJECT_INCDIR})
    else()
      list(APPEND HLS_ADD_PROJECT_CFLAG -I${CMAKE_CURRENT_SOURCE_DIR}/${HLS_ADD_PROJECT_INCDIR})
    endif()
  endforeach()

  set(HLS_ADD_PROJECT_TB_CFLAG ${HLS_ADD_PROJECT_CFLAG})
  foreach(HLS_ADD_PROJECT_INCDIR IN LISTS HLS_ADD_PROJECT_TB_INCDIRS )
    if (IS_ABSOLUTE ${HLS_ADD_PROJECT_INCDIR})
      list(APPEND HLS_ADD_PROJECT_TB_CFLAG -I${HLS_ADD_PROJECT_INCDIR})
    else()
      list(APPEND HLS_ADD_PROJECT_TB_CFLAG -I${CMAKE_CURRENT_SOURCE_DIR}/${HLS_ADD_PROJECT_INCDIR})
    endif()
  endforeach()

  if(NOT HLS_ADD_PROJECT_COSIM_TRACE_LEVEL)
    set(HLS_ADD_PROJECT_COSIM_TRACE_LEVEL port_hier)
  endif()


  set(HLS_ADD_PROJECT_DIR ${CMAKE_CURRENT_BINARY_DIR}/${project})
  set(HLS_ADD_PROJECT_PROJECT ${HLS_ADD_PROJECT_DIR}/${project}.app)

# message(${HLS_ADD_PROJECT_SOURCES})

  add_library(lib_${project} STATIC ${HLS_ADD_PROJECT_SOURCES})
  target_link_libraries(lib_${project}
    PUBLIC
      HLS::HLS
      ${HLS_ADD_PROJECT_LINK}
  )
  target_include_directories(lib_${project}
    PUBLIC
      ${HLS_ADD_PROJECT_INCDIRS}
  )

  if(HLS_ADD_PROJECT_TB_SOURCES)
    add_executable(test_${project}
        ${HLS_ADD_PROJECT_TB_SOURCES}
    )
    target_link_libraries(test_${project}
      PUBLIC
        ${HLS_ADD_PROJECT_TEST_LINK}
        lib_${project}
    )
    target_include_directories(test_${project}
      PUBLIC
        ${HLS_ADD_PROJECT_TB_INCDIRS}
    )
  endif()



  add_custom_target(create_project_${project}
  SOURCES ${HLS_ADD_PROJECT_PROJECT})

  string(REPLACE ";" " " HLS_ADD_PROJECT_SOURCES_0 "${HLS_ADD_PROJECT_SOURCES_0}")
  string(REPLACE ";" " " HLS_ADD_PROJECT_TB_SOURCES_0 "${HLS_ADD_PROJECT_TB_SOURCES_0}")
  string(REPLACE ";" " " HLS_ADD_PROJECT_CFLAG "${HLS_ADD_PROJECT_CFLAG}")
  string(REPLACE ";" " " HLS_ADD_PROJECT_TB_CFLAG "${HLS_ADD_PROJECT_TB_CFLAG}")
  string(REPLACE ";" " " HLS_ADD_PROJECT_COSIM_LDFLAGS "-L${HLS_CMAKE_LIB_DIR};${HLS_ADD_PROJECT_COSIM_LDFLAGS}")

  add_custom_command(
    OUTPUT ${HLS_ADD_PROJECT_PROJECT}
    DEPENDS ${HLS_ADD_PROJECT_DEPENDS}
    COMMAND
      # Define Environment Variables
      VITIS_HLS_PROJECT_NAME=${project}
      VITIS_HLS_SOLUTION_NAME="${HLS_ADD_PROJECT_SOLUTION}"
      VITIS_HLS_CFLAGS="${HLS_ADD_PROJECT_CFLAG}"
      VITIS_HLS_TB_CFLAGS="${HLS_ADD_PROJECT_TB_CFLAG}"
      VITIS_HLS_SOURCES="${HLS_ADD_PROJECT_SOURCES_0}"
      VITIS_HLS_TB_SOURCES="${HLS_ADD_PROJECT_TB_SOURCES_0}"
      VITIS_HLS_TOP="${HLS_ADD_PROJECT_TOP}"
      VITIS_HLS_PART="${HLS_ADD_PROJECT_PART}"
      VITIS_HLS_PERIOD="${HLS_ADD_PROJECT_PERIOD}"
      VITIS_HLS_FLOW_TARGET="${HLS_ADD_PROJECT_FLOW_TARGET}"
      # Call vitis_hls
      ${HLS_BIN_DIR}/vitis_hls ${HLS_TCL_DIR}/create_vitis_HLS_project.tcl -f
  )

  set(HLS_ADD_PROJECT_CSYNTH_ZIP ${HLS_ADD_PROJECT_DIR}/${project}/${HLS_ADD_PROJECT_SOLUTION}/impl/ip/${HLS_ADD_PROJECT_VENDER}_hls_${HLS_ADD_PROJECT_TOP}_${HLS_ADD_PROJECT_VERSION_}.zip)

  add_custom_target(csynth_${project} SOURCES ${HLS_ADD_PROJECT_CSYNTH_ZIP})
  add_custom_command(OUTPUT ${HLS_ADD_PROJECT_CSYNTH_ZIP}
    DEPENDS create_project_${project}
    COMMAND
      # Define Environment Variables
      VITIS_HLS_PROJECT_NAME=${project}
      VITIS_HLS_SOLUTION_NAME="${HLS_ADD_PROJECT_SOLUTION}"
      VITIS_HLS_NAME="${HLS_ADD_PROJECT_NAME}"
      VITIS_HLS_DESCRIPTION="${HLS_ADD_PROJECT_DESCRIPTION}"
      VITIS_HLS_IPNAME="${HLS_ADD_PROJECT_IPNAME}"
      VITIS_HLS_IP_TAXONOMY="${HLS_ADD_PROJECT_TAXONOMY}"
      VITIS_HLS_IP_VENDOR="${HLS_ADD_PROJECT_VENDOR}"
      VITIS_HLS_IP_VERSION="${HLS_ADD_PROJECT_VERSION}"
      # Call vitis_hls
      ${HLS_BIN_DIR}/vitis_hls ${HLS_TCL_DIR}/csynth.tcl -f
  )

  add_custom_target(cosim_${project}
    DEPENDS csynth_${project}
    COMMAND
      # Define Environment Variables
      VITIS_HLS_PROJECT_NAME=${project}
      VITIS_HLS_SOLUTION_NAME="${HLS_ADD_PROJECT_SOLUTION}"
      VITIS_HLS_LDFLAGS="${HLS_ADD_PROJECT_COSIM_LDFLAGS}"
      VITIS_HLS_COSIM_TRACE_LEVEL=${HLS_ADD_PROJECT_COSIM_TRACE_LEVEL}
      # Call vitis_hls
      ${HLS_BIN_DIR}/vitis_hls ${HLS_TCL_DIR}/cosim.tcl -f
  )

  add_custom_target(clear_${project}
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${HLS_ADD_PROJECT_DIR}
  )

endfunction()

