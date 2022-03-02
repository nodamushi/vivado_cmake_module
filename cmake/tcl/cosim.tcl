open_project $env(VITIS_HLS_PROJECT_NAME)
open_solution $env(VITIS_HLS_SOLUTION_NAME)

cosim_design -O \
    -ldflags "$env(VITIS_HLS_LDFLAGS)" \
    -rtl verilog \
    -tool xsim \
    -trace_level $env(VITIS_HLS_COSIM_TRACE_LEVEL)
exit
