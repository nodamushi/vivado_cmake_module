open_project $env(HLS_PROJECT_NAME)
open_solution $env(HLS_SOLUTION_NAME)

cosim_design -O \
    -ldflags "$env(HLS_LDFLAGS)" \
    -rtl verilog \
    -tool xsim \
    -trace_level $env(HLS_COSIM_TRACE_LEVEL)
exit
