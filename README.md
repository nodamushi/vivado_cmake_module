# vivado init project

Simple sample project for Cora Z7 07S.

## Build

```sh
mkdir build
cd build
cmake ..
make impl_vivado_study
```

### CMake Option

- `-DVIVADO_ROOT=<Vivado Directory>` : Vivado install directory(exp: C:/Xilinx/Vivado/2021.1)
- `-DVITIS_HLS_ROOT=<Vitis HLS Directory>` : Vitis HLS install directory(exp: C:/Xilinx/Vitis_HLS/2021.1)

## Make Target

- `xsdb`: run xsdb
- `vivado_study` : Create [vivado_study](./vivado) Vivado project
- `clear_vivado_study` : Delete [vivado_study](./vivado) Vivado project
- `impl_vivado_study` : Generate bitstream
- `create_project_hlsled` : Create [hlsled](./src/hls/hlsled) Vitis HLS project
- `clear_hlsled` : Delete [hlsled](./src/hls/hlsled) Vitis HLS project
- `test_hlsled` : Compile C++ Test of [hlsled](./src/hls/hlsled) (* You can run this test using `ctest`)
- `csynth_hlsled` : Perform high-level synthesis of [hlsled](./src/hls/hlsled)
- `cosim_hlsled` : Run C/RTL simulation of [hlsled](./src/hls/hlsled) (It don't work)

## Directory

- src/constraint/ : constraints
- src/rtl/ : Verilog RTL
- vivado/ : vivado project
- cmake/  : cmake codes

## Generated Vivado Project Directory

- `build/vivado/vivado_study.prj` : Vivado project
- `build/src/hls/hlsled/hlsled` : Vitis HLS project

