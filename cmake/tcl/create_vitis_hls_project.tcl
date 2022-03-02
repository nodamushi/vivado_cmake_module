open_project $env(VITIS_HLS_PROJECT_NAME)

foreach src $env(VITIS_HLS_SOURCES) {
  add_files ${src} -cflags $env(VITIS_HLS_CFLAGS)
}

if { [info exists ::env(VITIS_HLS_TB_SOURCES)] } {
  foreach src $env(VITIS_HLS_TB_SOURCES) {
    add_files -tb ${src} -cflags $env(VITIS_HLS_TB_CFLAGS)
  }
}

set_top $env(VITIS_HLS_TOP)
open_solution $env(VITIS_HLS_SOLUTION_NAME) -flow_target $env(VITIS_HLS_FLOW_TARGET)
set_part $env(VITIS_HLS_PART)
create_clock -period $env(VITIS_HLS_PERIOD) -name default

exit