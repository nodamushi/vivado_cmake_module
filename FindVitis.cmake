
set(VITIS_CPP_TEMPLATE "{Empty Application (C++)}" CACHE STRING "Default C++ project template name.")
set(VITIS_C_TEMPLATE "{Empty Application(C)}" CACHE STRING "Default C project template name")
set(VITIS_DEFAULT_LANG "CPP" CACHE STRING "Default C/C++ language. C or CPP")

include(${CMAKE_CURRENT_LIST_DIR}/utils.cmake)

find_path(VITIS_BIN_DIR
  vitis
  PATHS ${VITIS_ROOT} ENV XILINX_VITIS
  PATH_SUFFIXES bin
)

if (${VITIS_BIN_DIR} STREQUAL "VITIS_BIN_DIR-NOTFOUND")
  vcmu_find_vivado_bin(VITIS_VIVADO_BIN_DIR VITIS_REQUIRED_VERSION VIVADO_REQUIRED_VERSION)

  if (${VITIS_VIVADO_BIN_DIR} STREQUAL "VITIS_VIVADO_BIN_DIR-NOTFOUND")
    message("  FindVitis: Vitis not found.")
    message("  Please specified the following cmake option:")
    message("    -DVIVADO_ROOT=/tools/Xilinx/Vivado/yyyy.v")
    message("  or")
    message("    -DVITIS_ROOT=/tools/Xilinx/Vitis/yyyy.v")
    message(FATAL_ERROR "Vitis not found.")
  endif()

  get_filename_component(VITIS_VERSION "${VITIS_VIVADO_BIN_DIR}" DIRECTORY)
  get_filename_component(VITIS_VERSION "${VITIS_VERSION}" NAME)

  find_path(VITIS_BIN_DIR
    vitis
    PATHS ${VITIS_VIVADO_BIN_DIR}/../../../Vitis/${VITIS_VERSION}
    PATH_SUFFIXES bin
  )
endif()

find_path(VITIS_ROOT_DIR
  settings64.sh
  PATHS ${VITIS_BIN_DIR}/..
)


# VITIS_VERSION: Vitis VITIS Version
get_filename_component(VITIS_VERSION "${VITIS_BIN_DIR}" DIRECTORY)
get_filename_component(VITIS_VERSION "${VITIS_VERSION}" NAME)

if (VITIS_REQUIRED_VERSION)
  if (NOT ${VITIS_REQUIRED_VERSION} VERSION_EQUAL ${VITIS_VERSION})
    message("  Found Vitis Path: ${VITIS_BIN_DIR}")
    message(FATAL_ERROR "Found Vitis ${VITIS_VERSION}. Reuquired Vitis ${VITIS_REQUIRED_VERSION}")
  endif()
elseif (VIVADO_REQUIRED_VERSION)
  if (NOT ${VIVADO_REQUIRED_VERSION} VERSION_EQUAL ${VITIS_VERSION})
    message("  Found Vitis Path: ${VITIS_BIN_DIR}")
    message(FATAL_ERROR "Found Vitis ${VITIS_VERSION}. Reuquired Vivado ${VIVADO_REQUIRED_VERSION}")
  endif()
endif()

# find package
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Vitis
  REQUIRED_VARS
    VITIS_BIN_DIR
)

# vivado
if (NOT VITIS_VIVADO_BIN_DIR)
  find_path(VITIS_VIVADO_BIN_DIR
    vivado
    PATHS ${VITIS_BIN_DIR}/../../../Vivado/${VITIS_VERSION}
    PATH_SUFFIXES bin
  )
endif()

set(VITIS_VIVADO_EXE ${VITIS_VIVADO_BIN_DIR}/vivado)
set(VITIS_XSCT ${VITIS_BIN_DIR}/xsct)
set(VITIS_EXE ${VITIS_BIN_DIR}/vitis)
set(VITIS_UPDATEMEM ${VITIS_BIN_DIR}/updatemem)

if (WIN32)
  set(VITIS_RUN_UPDATEMEM ${CMAKE_CURRENT_LIST_DIR}/os/win/updatemem.bat)
else ()
  set(VITIS_RUN_UPDATEMEM ${CMAKE_CURRENT_LIST_DIR}/os/linux/updatemem.sh)
endif()


# save current directory
set(VITIS_CMAKE_DIR ${CMAKE_CURRENT_LIST_DIR})
set(VITIS_TCL_DIR ${CMAKE_CURRENT_LIST_DIR}/tcl)
set(VITIS_CMAKE_LIB_DIR ${CMAKE_CURRENT_BINARY_DIR}/lib)

# Include Directory
macro(_find_vitis_append_incdir VAR DIR)
  file(GLOB _find_vitis_append_incdir_children RELATIVE ${DIR} ${DIR}/*/include*)
  foreach(_find_vitis_append_incdir_child ${_find_vitis_append_incdir_children})
    list(APPEND ${VAR} ${DIR}/${_find_vitis_append_incdir_child})
  endforeach()
endmacro()

# 32-bit starndard
set(VITIS_AARCH32_INCROOT ${VITIS_ROOT_DIR}/gnu/aarch32/lin)
set(VITIS_AARCH32_INCDIRS
   ${AARCH32_INCROOT}/gcc-arm-none-eabi/aarch32-xilinx-eabi/usr/include)
   _find_vitis_append_incdir(VITIS_AARCH32_INCDIRS ${VITIS_AARCH32_INCROOT}/gcc-arm-none-eabi/x86_64-oesdk-linux/usr/lib/arm-xilinx-eabi/gcc/arm-xilinx-eabi)

# TODO...
set(VITIS_MICROBLAZE_INCROOT ${VITIS_ROOT_DIR}/gnu/microblaze/lin)
set(VITIS_MICROBLAZE_INCDIRS
  ${MICROBLAZE_INCROOT}/microblazeeb-xilinx-elf/usr/include
)
_find_vitis_append_incdir(VITIS_MICROBLAZE_INCDIRS ${MICROBLAZE_INCROOT}/x86_64-oesdk-linux/usr/lib/microblaze-xilinx-elf/gcc/microblaze-xilinx-elf)


#
# add_vitis_hw_project(
#   <project>
#   XSA  <vivado project|xsa file>
#   PROC <proecessor name>
#   [C|CPP]
#   [RELEASE|DEBUG]
#   [OS  <os name>]
#   [DIR <workspace directory>]
#   [DOMAIN_NAME <domain short name>]
#   [DOMAIN_LONG <domain long name>]
#   [TEMPLATE    <project tempalte name>]
#   [SOURCES     <source file|directory>...]
#   [DEPENDS     <denpend target>...]
#   [INCDIR      <include directory>...]
#   [DEFINE      <macro>...]
#   [TCL0        <user tcl script>...]
#   [TCL1        <user tcl script>...]
#   [TCL2        <user tcl script>...]
#   [TCL3        <user tcl script>...]
#   [ARCH        microblaze|aarch64|aarch32|armr5]
#   [BIT <bitstream file>]
# )
#
# define single platform/application project.
#
# Arguments:
#  <project>: project name
#  PROC     : processor name
#  XSA      : vivado project or xsa file path
#
# Options:
#  C|CPP       : Supported language. C => C language, CPP => C++ language
#              : If this option is not defined, `VITIS_DEFAULT_LANG` will be used.
# RELEASE|DEBUG: default build mode. default is release.
#  OS          : project os. default is standalone.
#  DIR         : workspace directory
#  DOMAIN_NAME : domain name.
#  DOMAIN_LONG : domain display name.
#  TEMPLATE    : application project template name.
#              : If this option is not defined, `VITIS_XXX_TEMPLATE` will be used.
#  SOURCES     : source files or directories
#  DEPENDS     : depends
#  INCDIR      : include directories.
#  DEFINE      : macro
#  TCL0,1,2,3  : user tcl scripts. see `tcl/create_vitis_project.tcl`
#  ARCH        : microblaze or aarch64 or aarch32 or armr5
#  BIT         : bitstream file path. If an XSA file path is specified, the BIT must also be specified.
#
# Targets:
#  create_${project} : Generate workspace / platform / application
#  ${projecte}       : Build
#  clear_${project}  : Delete workspace
#  open_${project}   : Open workspace in Vitis
#  update_bit_${project}: run updatemem
#
function(add_vitis_hw_project project)
  cmake_parse_arguments(
    VARG
    "C;CPP;DEBUG;RELEASE"
    "XSA;MEM;BIT;PROC;ARCH;OS;DIR;DOMAIN_NAME;DOMAIN_LONG;TEMPLATE"
    "SOURCES;DEPENDS;INCDIR;DEFINE;TCL0;TCL1;TCL2;TCL3"
    ${ARGN}
  )
  if (NOT VARG_XSA)
    message(FATAL_ERROR "add_vitis_hw_project:${project}: XSA(exported hardware) is not defined.")
  endif()

  if (NOT VARG_PROC)
    message(FATAL_ERROR "add_vitis_hw_project:${project}: CPU is not defined")
  endif()

  # Checl C or C++
  if (VARG_C AND VARG_CPP)
    message(FATAL_ERROR "add_vitis_hw_project: ${project}: bonth C and CPP are defined.")
  endif()

  if ((NOT VARG_C) AND (NOT VARG_CPP))
    if ((${VITIS_DEFAULT_LANG} STREQUAL "c") OR (${VITIS_DEFAULT_LANG} STREQUAL "C"))
      set(VARG_C ON)
    else()
      set(VARG_CPP ON)
    endif()
  endif()

  if (VARG_C)
    set(LANG "{c}")
    set(DEFAULT_TEMPLATE ${VITIS_C_TEMPLATE})
  else()
    set(LANG "{c++}")
    set(DEFAULT_TEMPLATE ${VITIS_CPP_TEMPLATE})
  endif()

  # Default build config
  set(build_mode Release)
  if (VARG_DEBUG)
    if(VARG_RELEASE)
      message(FATAL_ERROR "Both RELEASE and DEBUG are defined in ${project}")
    endif()

    set(build_mode Debug)
  endif()

  # select arch
  if (NOT VARG_ARCH)
    if (${VARG_PROC} MATCHES ".*microblaze.*")
      set(VARG_ARCH "microblaze")
    elseif(${VARG_PROC} MATCHES ".*cortexa53.*")
      set(VARG_ARCH "aarch64")
    elseif(${VARG_PROC} MATCHES ".*cortexa72.*")
      set(VARG_ARCH "aarch64")
    elseif(${VARG_PROC} MATCHES ".*cortexr5.*")
      set(VARG_ARCH "armr5")
    else()
      set(VARG_ARCH "aarch32")
    endif()
  endif()

  # set template
  if (VARG_TEMPLATE)
    set(template ${VARG_TEMPLATE})
  else()
    set(template ${DEFAULT_TEMPLATE})
  endif()

  # set os
  if (VARG_OS)
    set(os ${VARG_OS})
  else()
    set(os "standalone")
  endif()

  # init depends
  set(DEPENDS)
  if (VARG_DEPENDS)
    set(DEPENDS ${VARG_DEPENDS})
  endif()

  # set xsa file
  if (TARGET ${VARG_XSA})
    get_property(is_vivado_prj TARGET ${VARG_XSA} PROPERTY VIVADO_PROJECT})
    if (NOT ${is_vivado_prj} STREQUAL "VIVADO")
      message(FATAL_ERROR "${VARG_XSA} target is not a vivado project.")
    endif()

    # get xsa file from vivado target
    get_property(xsa_file TARGET ${VARG_XSA} PROPERTY XSA)
    set(platform_name ${VARG_XSA})
    list(APPEND DEPENDS xsa_${VARG_XSA})
    set(XSA_DEPEND xsa_${VARG_XSA})
  else()
    # may be xsa file
    set(xsa_file ${VARG_XSA})
    get_filename_component(platform_name ${xsa_file} NAME_WE)
    if(NOT EXISTS ${VARG_XSA})
      message(WARNING "${VARG_XSA} not found.")
    endif()
    list(APPEND DEPENDS ${xsa_file})
    set(XSA_DEPEND ${xsa_file})
  endif()

  # set domain
  ##  short name
  if (VARG_DOMAIN_NAME)
    set(domain ${VARG_DOMAIN_NAME})
  else()
    set(domain "${os}_${platform_name}")
  endif()

  ##  display name
  if (VARG_DOMAIN_LONG)
    set(long_domain ${VARG_DOMAIN_LONG})
  else()
    set(long_domain "${os}_${platform_name}")
  endif()

  # set workspace directory
  if (VARG_DIR)
    vcmu_to_abs_path(${VARG_DIR} workspace)
  else()
    set(workspace ${CMAKE_CURRENT_BINARY_DIR}/${project})
  endif()
  # set project directory
  set(PRJDIR ${workspace}/${project})
  set(PRJFILE ${PRJDIR}/.project)
  set(DebugELF ${PRJDIR}/Debug/${project}.elf)
  set(ReleaseELF ${PRJDIR}/Release/${project}.elf)
  if (${build_mode} STREQUAL "Debug")
    set(ELF ${DebugELF})
  else()
    set(ELF ${ReleaseELF})
  endif()
  set(bit_file ${PRJDIR}/_ide/bitstream/${platform_name}.bit)
  set(mmi_file ${PRJDIR}/_ide/bitstream/${platform_name}.mmi)
  set(UPDATE_BITSTREAM ${workspace}/${project}.bit)

  # fix relative path
  vcmu_map_abs_path(VARG_SOURCES SRC_LIST)
  vcmu_map_abs_path(VARG_TCL0 TCL0)
  vcmu_map_abs_path(VARG_TCL1 TCL1)
  vcmu_map_abs_path(VARG_TCL2 TCL2)
  vcmu_map_abs_path(VARG_TCL3 TCL3)
  vcmu_map_abs_path(VARG_INCDIR INCDIR)

  # generate environment file
  set(ENV_FILE ${CMAKE_CURRENT_BINARY_DIR}/env_vitis_${project}.tcl)
  set(PROC_FILE ${CMAKE_CURRENT_BINARY_DIR}/proc_vitis_${project}.tcl)
  vcmu_env_file_init(${ENV_FILE})
  vcmu_env_file_add_var(${ENV_FILE} ws "${workspace}")
  vcmu_env_file_add_var(${ENV_FILE} project "${project}")
  vcmu_env_file_add_var(${ENV_FILE} build_mode "${build_mode}")
  vcmu_env_file_add_var(${ENV_FILE} xsa_file "${xsa_file}")
  vcmu_env_file_add_var(${ENV_FILE} mmi_file "${mmi_file}")
  vcmu_env_file_add_var(${ENV_FILE} bit_file "${bit_file}")
  vcmu_env_file_add_var(${ENV_FILE} template "${template}")
  vcmu_env_file_add_var(${ENV_FILE} lang "${LANG}")
  vcmu_env_file_add_var(${ENV_FILE} os "${os}")
  vcmu_env_file_add_var(${ENV_FILE} tcldir "${VITIS_TCL_DIR}")
  vcmu_env_file_add_var(${ENV_FILE} proc "${VARG_PROC}")
  vcmu_env_file_add_var(${ENV_FILE} arch "${VARG_ARCH}")
  vcmu_env_file_add_var(${ENV_FILE} domain "${domain}")
  vcmu_env_file_add_var(${ENV_FILE} long_domain "${long_domain}")
  vcmu_env_file_add_var(${ENV_FILE} platform "${platform_name}")
  vcmu_env_file_add_list(${ENV_FILE} src SRC_LIST)
  vcmu_env_file_add_list(${ENV_FILE} tcl0 TCL0)
  vcmu_env_file_add_list(${ENV_FILE} tcl1 TCL1)
  vcmu_env_file_add_list(${ENV_FILE} tcl2 TCL2)
  vcmu_env_file_add_list(${ENV_FILE} tcl3 TCL3)
  vcmu_env_file_add_list(${ENV_FILE} incdir INCDIR)
  vcmu_env_file_add_list(${ENV_FILE} defs VARG_DEFINE)
  vcmu_env_file_add_var(${ENV_FILE} proc_file "${PROC_FILE}")

  ############## define targets ########################################
  # generate workspace and project
  add_custom_target(create_${project} SOURCES ${PRJFILE})
  add_custom_command(
    OUTPUT ${PRJFILE} ${PROC_FILE}
    DEPENDS ${DEPENDS}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${workspace}
    COMMAND ${VITIS_XSCT} ${VITIS_TCL_DIR}/create_vitis_project.tcl ${ENV_FILE}
  )

  # build project
  add_custom_target(${project} SOURCES ${ELF})
  add_custom_command(
    OUTPUT ${ELF}
    DEPENDS create_${project}
    COMMAND ${VITIS_XSCT} ${VITIS_TCL_DIR}/vitis_build.tcl ${ENV_FILE}
  )

  # update bitstream
  add_custom_target(update_bit_${project} SOURCES ${UPDATE_BITSTREAM})
  add_custom_command(
    OUTPUT ${UPDATE_BITSTREAM}
    DEPENDS ${ELF} ${mmi_file} ${PROC_FILE}
    COMMAND ${VITIS_RUN_UPDATEMEM}
      ${VITIS_UPDATEMEM} ${mmi_file} ${bit_file} ${ELF} ${UPDATE_BITSTREAM} ${PROC_FILE}
  )

  # show processor
  add_custom_target(show_proc_${project}
    DEPENDS ${XSA_DEPEND}
    COMMAND ${VITIS_XSCT} ${VITIS_TCL_DIR}/vitis_show_proc.tcl ${ENV_FILE}
  )

  # open project
  add_custom_target(open_${project}
    COMMAND ${VITIS_EXE} -workspace ${workspace}&
  )

  # delete project target
  add_custom_target(clear_${project}
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${workspace}
  )

  # Define a project to enable VSCode C++ completion to work.
  # Note: after `make create_${project}`,  run `CMake: Delete Cache and Reconfigure` vscode command.
  set(src2)
  foreach(SRC IN LISTS SRC_LIST)
    if (IS_DIRECTORY ${SRC})
      file(GLOB_RECURSE src3  "${SRC}/*.cpp" "${SRC}/*.c" )
      list(APPEND src2 ${src3})
      file(GLOB_RECURSE src3  "${SRC}/**/*.cpp" "${SRC}/**/*.c")
      list(APPEND src2 ${src3})
    else()
      list(APPEND src2 ${SRC})
    endif()
  endforeach()

  add_library(lib_${project}
    STATIC
      ${src2}
  )

  if (${os} STREQUAL "standalone")
    if (${VARG_ARCH} STREQUAL "microblaze")
      target_include_directories(lib_${project} PUBLIC ${VITIS_MICROBLAZE_INCDIRS})
    elseif (${VARG_ARCH} STREQUAL "aarch64")
      # TODO
      message(NOTICE "TODO FindVitis:${project}: aarch64 is not supported")
    elseif (${VARG_ARCH} STREQUAL "armr5")
      # TODO
      message(NOTICE "TODO FindVitis:${project}: armr5 is not supported")
    else()
      target_include_directories(lib_${project} PUBLIC ${VITIS_AARCH32_INCDIRS})
    endif()
  else()
    message(NOTICE "TODO FindVitis:${project}: os ${os} is not supported")
  endif()

  target_include_directories(lib_${project}
    PUBLIC
    ${workspace}/${platform_name}/export/${platform_name}/sw/${platform_name}/${domain}/bspinclude/include
    ${INCDIR}
  )
  if (VARG_DEFINE)
    target_compile_definitions(lib_${project}
      PUBLIC
        ${VARG_DEFINE}
    )
  endif()

  # set target property
  set_target_properties(${project}
    PROPERTIES
      VIVADO_PROJECT VITIS
      PROJECT_NAME   ${project}
      PROJECT_DIR    ${PRJDIR}
      PROJECT_FILE   ${PRJFILE}
      TOP_BITSTREAM  ${BITSTREAM}
      UPDATE_BITSTREAM  ${UPDATE_BITSTREAM}
      # TOP_LTX        ${LTX}
      IMPL_TARGET    ${project}
      XSA            "${xsa_file}"
  )
endfunction()
