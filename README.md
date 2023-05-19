# vivado cmake module

Fork from [nodamushi/vivado_init_project](https://github.com/nodamushi/vivado_init_project)

## License

This repository is in the public domain. Please choose whichever of the following licenses is more convenient for you.

- Unlicense
- CC0 [![CC0](https://i.creativecommons.org/p/zero/1.0/88x31.png)](http://creativecommons.org/publicdomain/zero/1.0/deed.en)

## How to use

see [nodamushi/vivado_init_project](https://github.com/nodamushi/vivado_init_project)

- HLS sample: [src/hls/hlsled/CMakeLists.txt](https://github.com/nodamushi/vivado_init_project/blob/main/src/hls/hlsled/CMakeLists.txt)
- Vivado sample: [vivado/CMakeLists.txt](https://github.com/nodamushi/vivado_init_project/blob/main/vivado/CMakeLists.txt)


```cmake
# set vivado version
set(VIVADO_REQUIRED_VERSION 2021.1)

# ------ Download -----------------------
include(FetchContent)
FetchContent_Declare(
  vivado_cmake_module
  GIT_REPOSITORY  https://github.com/nodamushi/vivado_cmake_module.git
  GIT_TAG v0.0.11
)
FetchContent_MakeAvailable(vivado_cmake_module)
list(APPEND CMAKE_MODULE_PATH ${vivado_cmake_module_SOURCE_DIR})

# -------- find package ------------------
find_package(Vivado)
find_package(HLS)
find_package(Vitis)

# ---- define Vivado project ------------
add_vivado_project(my_vivado_prj
  TOP        top_module
  BOARD      target_board
  RTL        top_module.v sub_module.v
  CONSTRAINT cons.xdc
  DESIGN     design_1.tcl
)

# -- define vitis/vivado HLS project ---
add_hls_project(my_led
  TOP     HlsLED
  PART    target_part
  VERSION 1.0
  VENDOR  nodamushi
  NAME    "LED"
  PERIOD  10 # 100MHz
  SOURCES hlsled.cpp
  # Test bench
  TB_SOURCES tb.cpp
)

# --- define vitis application project ---
add_vitis_hw_project(
  my_vitis_prj
  C # Not C++
  XSA     my_vivado_prj
  PROC    ps7_cortexa9_0
  SOURCES src
)
```

### Build

```sh
mkdir build
cd build

cmake \
  -DVIVADO_ROOT=/tools/Xilinx/Vivado/2022.2 \
  -DVITIS_HLS_ROOT=/tools/Xilinx/Vitis_HLS/2022.2 \
  ..

# build hls project
make csynth_my_led

# build vivado project
make impl_my_vivado_prj
```

## Vivado

```cmake
find_package(Vivado)
```

### CMake Variables

- `VIVADO_ROOT`: option. Vivado hls root path. exp) `cmake -DVIVADO_HLS_ROOT=/tools/Xilinx/Vivado/2019.2`
    - `XILINX_VIVADO`: Environment variable defined by `source <path to Vivado>/settings64.sh`.
- `VIVADO_JOB`: option. implement job size

####  Other variables

- `VIVADO_VERSION`: Vitis/Vivado HLS version
- `VIVADO_EXE`: vivado command path
- `VIVADO_XSDB_VIVADO`: xsdb command path



### Define Vivado project

`add_vivado_project`

```cmake
add_vivado_project(
   <project>
   BOARD <board part name>
   TOP   <top module>
   [DIR <directory name>]
   [RTL <file/directory>...]
   [CONSTRAINT <file/directory>...]
   [IP <directory>...]
   [DESIGN <tcl file>]
   [DEPENDS <target>...]
   [TCL0   <tcl file>...]
   [TCL1   <tcl file>...]
   [TCL2   <tcl file>...]
   [DFX    <tcl file>]
   [IMPLEMENTS <implimentation name>...]
   [BOARD_REPO <directory>...]
   [BETA   <beta device pattern>]
   [PDI]
)
```

#### Argument

- `<project>`: target name

#### Taged Arguments

- `BOARD`  : Board property. When `*` is contained, find board part by Vivado command `[get_board_parts -quiet -latest_file_version <BOARD>]` .
- `TOP`    : Top module name

#### Options

- `DIR       ` : project directory name (default is `projet`.prj)
- `RTL       ` : RTL files
- `CONSTRAINT` : constraint files
- `IP        ` : IP directories
- `DESIGN    ` : Design tcl file
- `DEPENDS   ` : depends
- `TCL0      ` : Tcl script files. This file will be loaded before `create_project` command.
- `TCL1      ` : Tcl script files. This file will be loaded after adding RTL/constraints files in `create_vivado_project.tcl`.
- `TCL2      ` : Tcl script files. This file will be loaded before closeing project in `create_vivado_project.tcl`.
- `DFX       ` : Enable Dynamic Function eXchange(Partial Reconfigu), and load setting tcl file.
- `IMPLEMENTS` : impelmentation name list
- `BOARD_REPO` : set_param board.repoPaths
- `BETA      ` : enable_beta_device command arguments. `*` is all beta device enable.
- `PDI       ` : for Versal. Indicates that Vivado generates *.pdi files.

#### Define Targets

Note: `<project>` is the first argument of `add_vivado_projct`.

- `<project>`              : Create Vivado project
    - Target Properties
        - `PROJECT_NAME `  : project name
        - `PROJECT_DIR  `  : project directory path
        - `PROJECT_FILE `  : xpr file path
        - `RUNS_DIR     `  : .runs directory path
        - `IMPL         `  : default implementation name
        - `IMPLS        `  : implementation list
        - `TOP_MODULE   `  : top module name
        - `TOP_BITSTREAM`  : top bit stream path
        - `TOP_LTX      `  : top bit stream ltx path
        - `IMPL_TARGET  `  : implementation target name
                           :
- `open_<project>`           : Open project in vivado
- `clear_<project>`          : Delete Vivado project directory
- `impl_<project>`           : Create bit stream (run impl)
- `program_<project>`        : Write bitstream
    - Environment Variables:
        - `JTAG`    : jtag target
        - `HWSVR`   : (option)`hw_server` url
        - `HWSVRPORT`: (option) `hw_server` port
    - exp) `make JTAG=1 program_<project>`
- `export_bd_<project>`      : Save IP Integrator design tcl file
- `report_addr_<project>`    : Report address
    -  Environment Variables:
        - `REPORT_CSV`: output csv file name
    - exp) `make REPORT_CSV=foobar.csv report_addr_<project>`

### add write bitstream target

Add new target to write bitstream of project.

```cmake
add_write_bitstream(project target_subname bitstream_path)
```

#### Argument
- `project       ` : target project
- `target_subname` : write bitstream target name
- `bitstream_path` : bitstream file path from project runs directory

####  Target

- `program_<project>_<target_subname>`
    - Environment Variables:
        - `JTAG     `: jtag target
        - `HWSVR    `: (option) connect url
        - `HWSVRPORT`: (option) connect port
    - exp) make JTAG=1 program_${project}_${target_subname}

## Vivado/Vitis HLS

```cmake
find_package(HLS)
```


### CMake Variables

- `VITIS_HLS_ROOT`: option. Vitis hls root path. exp) `cmake -DVITIS_HLS_ROOT=/tools/Xilinx/Vitis_HLS/2022.2`
    - `XILINX_HLS`: Environment variable defined by `source <path to Vitis HLS>/settings64.sh`.
- `VIVADO_ROOT`: option. Vivado hls root path. exp) `cmake -DVIVADO_HLS_ROOT=/tools/Xilinx/Vivado/2019.2`
    - `XILINX_VIVADO`: Environment variable defined by `source <path to Vivado>/settings64.sh`.
- `HLS_VENDOR_NAME`: option. Default IP vendor name.
- `HLS_TAXONOMY`: option. Default IP category name.
- `HLS_DEFAULT_VERSION`: option. Default IP Version
- `VITIS_HLS_FLOW_TARGET`: option. Default Vitis HLS flow target.

#### Other variables

- `HLS_VERSION`: Vitis/Vivado HLS version
- `HLS_IS_VITIS`: whether Vitis HLS is detected
- `HLS_IS_VIVADO`: whether Vivado HLS is detected
- `HLS_BIN_DIR`: `bin` directory path of Vitis/Vivado HLS
- `HLS_INCLUDE_DIR`: `include` directory path of Vitis/Vivado HLS

### Define HLS project

```cmake
add_hls_project(
 <project>
 TOP      <top module>
 PERIOD   <clock period(ns)>
 PART     <board part>
 SOURCES  <C++ source file>...
 [INCDIRS    <include directory>...]
 [LINK       <link library>...]
 [TB_SOURCES <test bench C++ file>...]
 [TB_INCDIRS <include directory>...]
 [TB_LINK    <link libray>...]
 [DEPENDS    <depends target>...]
 [NAME    <display name>]
 [IPNAME  <IP name>]
 [VENDOR  <your name>]
 [TAXONOMY <category>]
 [VERSION  <version(x.y)>]
 [SOLUTION <solution name>]
 [COSIM_LDFLAGS <flag string>]
 [COSIM_TRACE_LEVEL <none|all|port|port_hier>]
 [FLOW_TARGET <vivado|vitis>]
 [CFLAG <flags>...]
 [TB_CFLAG <flags>...]
 [DEFINE <macro[=value]>...]
 [TB_DEFINE <macro[=value]>...]
 [CTEST]
 [NO_O0]
)
```

**sample code**

```cmake
add_hls_project(
  hlsled                   # project name

  # Project info
  TOP     HlsLED           # top module function name
  VERSION 1.0              # IP version
  VENDOR  "foobar"         # vendor name
  NAME    "HLS LED Chika"  # display name
  PERIOD  10               # clock period[ns] (10 = 100MHz)
  PART    xc7z007sclg400-1 # fpga part

  # source
  SOURCES hlsled.cpp       # source file list
  LINK    my_hls_lib       # add library. see `add_hls_interface`

  # test
  TB_SOURCES tb.cpp        # test bench file list
  TB_LINK my_test_lib      # add library. see `add_hls_interface`
  CTEST                    # add_test(NAME test_hlsled COMMAND $<TARGET_FILE:build_test_hlsled>)
)
```

#### Argument
- `<project>` : target name

#### Taged Arguments
- `TOP    ` : Top module name
- `PERIOD ` : Clock Period (ns)
- `PART   ` : Device part
- `SOURCES` : HLS source file

#### Options

- `NAME       `   : IP display name. (Default is `<project>`)
- `IPNAME     `   : IP name.(Default is `<project>`)
- `VENDOR     `   : Your name.(Default is `HLS_VENDOR_NAME` variable)
- `TAXONOMY   `   : IP category.(Default is `HLS_TAXONOMY` variable)
- `VERSION    `   : IP version(x.y).(Default is `HLS_DEFAULT_VERSION` variable)
- `SOLUTION   `   : Solution name.(Default is `HLS_SOLUTION_NAME` variable)
- `TB_SOURCES `   : Test Bench source files
- `INCDIRS    `   : Include directories
- `TB_INCDIRS `   : Include directories for test bench
- `DEPENDS    `   : Dependency for create project
- `LINK       `   : Link library
- `TB_LINK    ` : Link library for testing
- `COSIM_LDFLAGS` : cosim_design -ldflags
- `COSIM_TRACE_LEVEL`: default none, all, port, port_hier. (Default is `HLS_TRACE_LEVEL` variable)
- `FLOW_TARGET`   : (vitis_hls only). vivado or vitis.(Default is `VITIS_HLS_FLOW_TARGET` variable)
- `CFLAG      `   : Additional compile flag
- `TB_CFLAG   `   : Additional test bench compile flag
- `DEFINE     `   : Define macro
- `TB_DEFINE  `   : Define macro for test bench
- `NO_O0      `   : Disable -O0 option of `test_<project>` target.
- `CTEST      `   : call `add_test`.

#### Define Targets

Note: `<project>` is the first argument of `add_hls_projct`.

- `create_project_<project>` : Create Vitis Project
- `clear_<project>         ` : Delete Vitis project directory
- `csynth_<project>        ` : Run synthesis
- `lib_<project>           ` : Compile C++
- `test_<project>          ` : Compile TestBench
- `wave_<project>          ` : Open cosim wave database in Vivado
- `cosim_<project>         ` : C/RTL simulation
    - `TLEVEL`: trace level. `make TLEVEL=all cosim_<project>`
    - `ARGV`  : arguments. `make ARGV="-foo -bar" cosim_<project>`

### Avoid "`__gmp_const` does not name a type"

see: [Vitis HLS 2021.x - Use of gmp.h for Co-simulation](https://support.xilinx.com/s/article/Use-of-gmp-h-for-Co-simulation?language=en_US)

By always including the following code at the beginning of the test code, this problem can be avoided.

```c
#include <_gmp_const.h>
```

`gmp_const.h` is [`gmp/gmp_const.h`](./gmp/gmp_const.h) or [`nogmp/gmp_const.h`](./nogmp/gmp_const.h).

### Define header only HLS project

```cmake
 add_hls_interface(
  project
  [INCDIRS <directory>...]
  [DEPENDS <target>...]
 )
```

#### Argument

- `project`: interface library target name

#### Options

- `INCDIRS`: header directories.If this option is not specified, the current directory is set.
- `DEPENDS`: depends targets

#### Defined Target

- `<project>`: interface library target


## Vitis

```cmake
find_package(Vitis)
```

### Define Vitis hw application

```cmake
add_vitis_hw_project(
  <project>
  XSA  <vivado project|xsa file>
  PROC <proecessor name>
  [C|CPP]
  [OS  <os name>]
  [DIR <workspace directory>]
  [DOMAIN_NAME <domain short name>]
  [DOMAIN_LONG <domain long name>]
  [TEMPLATE    <project tempalte name>]
  [SOURCES     <source file|directory>...]
  [DEPENDS     <denpend target>...]
  [INCDIR      <include directory>...]
  [DEFINE      <macro>...]
  [TCL0        <user tcl script>...]
  [TCL1        <user tcl script>...]
  [TCL2        <user tcl script>...]
  [TCL3        <user tcl script>...]
  [ARCH        microblaze|aarch64|aarch32|armr5]
)
```

**sample code:**

```cmake
# * source vivado project *
add_vivado_project(
  sample_vivado
  DESIGN  top.tcl
  TOP     top_wrapper
  BOARD   <your target board>
)

##########################
## Sample Vitis project ##
##########################
add_vitis_hw_project(
  sample_vitis            # project name
  C                       # C language. (Default is C++)
  XSA     sample_vivado   # source vivado project
  PROC    ps7_cortexa9_0  # processor name
  SOURCES src             # source directory
)
```

### Targets:

- `create_${project}` : Generate workspace / platform / application
- `${projecte}      ` : Build project
- `clear_${project} ` : Delete workspace
- `open_${project}  ` : Open workspace in Vitis
- `show_proc_${project}` : Show processor list

⚠️ If `create_${project}` fails, run `clear_${project}` before trying again.

### Arguments:

- `<project>` : project name
- `PROC     ` : processor name
- `XSA      ` : vivado project or xsa file path

### Options:

- `C|CPP      ` : Supported language. C => C language, CPP => C++ language. If this option is not defined, `VITIS_DEFAULT_LANG` will be used.
- `OS         ` : project os. default is standalone.
- `DIR        ` : workspace directory
- `DOMAIN_NAME` : domain name.
- `DOMAIN_LONG` : domain display name.
- `TEMPLATE   ` : application project template name. If this option is not defined, `VITIS_XXX_TEMPLATE` will be used.
- `SOURCES    ` : source files or directories
- `DEPENDS    ` : depends
- `INCDIR     ` : include directories.
- `DEFINE     ` : macro
- `TCL0,1,2,3 ` : user tcl scripts. see `tcl/create_vitis_project.tcl`
- `ARCH       ` : microblaze or aarch64 or aarch32 or armr5
