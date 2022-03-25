# source from tcl files
# initialize project
open_project $env(HLS_PROJECT_NAME)

foreach src $env(HLS_SOURCES) {
  add_files ${src} -cflags $env(HLS_CFLAGS)
}

if { [info exists ::env(HLS_TB_SOURCES)] } {
  foreach src $env(HLS_TB_SOURCES) {
    add_files -tb ${src} -cflags $env(HLS_TB_CFLAGS)
  }
}

set_top $env(HLS_TOP)
if { $env(HLS_IS_VITIS) == "TRUE" } {
  open_solution $env(HLS_SOLUTION_NAME) -flow_target $env(HLS_FLOW_TARGET)
} else {
  open_solution $env(HLS_SOLUTION_NAME)
}
set_part $env(HLS_PART)
create_clock -period $env(HLS_PERIOD) -name default