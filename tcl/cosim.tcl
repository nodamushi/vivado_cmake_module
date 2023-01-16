#
# TCL Script: cosim_${project}
#
#  target: vitis_hls/vivado_hls
#
open_project $env(NHLS_PROJECT_NAME)
open_solution $env(NHLS_SOLUTION_NAME)

set ldflags ""
if { [info exists ::env(NHLS_COSIM_LDFLAGS)] } {
  set ldflags [string map {";" " "} "$env(NHLS_COSIM_LDFLAGS)"]
}
cosim_design -O \
    -ldflags "$ldflags" \
    -rtl verilog \
    -tool xsim \
    -trace_level $env(NHLS_COSIM_TRACE_LEVEL)
exit
