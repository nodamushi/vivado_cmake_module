#
# TCL Script: cosim_${project}
#
#  target: vitis_hls/vivado_hls
#
open_project $env(NHLS_PROJECT_NAME)
open_solution $env(NHLS_SOLUTION_NAME)

cosim_design -O \
    -ldflags "$env(NHLS_LDFLAGS)" \
    -rtl verilog \
    -tool xsim \
    -trace_level $env(NHLS_COSIM_TRACE_LEVEL)
exit
