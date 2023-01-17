# source from tcl files
# initialize project
open_project $env(NHLS_PROJECT_NAME)

if { [info exists ::env(NHLS_SOURCES)] } {
  set tmp [string trim [string map {";" " "} $env(NHLS_SOURCES)]]
  if { $tmp != "" } {
    set cflags ""
    if { [info exists ::env(NHLS_CFLAGS)] } {
      set cflags [string map {";" " "} $env(NHLS_CFLAGS)]
    }
    add_files -cflags "$cflags" $tmp
  }
}

if { [info exists ::env(NHLS_TB_SOURCES)] } {
  set tmp [string trim [string map {";" " "} $env(NHLS_TB_SOURCES)]]
  if { $tmp != "" } {
    set tbcflags ""
    if { [info exists ::env(NHLS_TB_CFLAGS)] } {
      set tbcflags [string map {";" " "} $env(NHLS_TB_CFLAGS)]
    }
    add_files -tb -cflags "$tbcflags" $tmp
  }
}

set_top $env(NHLS_TOP)
if { $env(NHLS_IS_VITIS) == "TRUE" } {
  open_solution $env(NHLS_SOLUTION_NAME) -flow_target $env(NHLS_FLOW_TARGET)
} else {
  open_solution $env(NHLS_SOLUTION_NAME)
}
set_part $env(NHLS_PART)
create_clock -period $env(NHLS_PERIOD) -name default
