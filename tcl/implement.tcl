#
# TCL script: _impl_${project}_original
#
#  target: vivado
#
set project_name      [lindex $argv 0]
set project_directory [lindex $argv 1]

open_project ${project_directory}/${project_name}.xpr

set JOB_SIZE 1
if { [info exists ::env(VIVADO_JOB_SIZE)] } {
  set tmp [string trim $env(VIVADO_JOB_SIZE)]
  if { $tmp != "" } {
    set JOB_SIZE $tmp
  }
}

proc runImpl {run jobsize} {
  set name [get_property NAME $run]
  set isImpl [get_property IS_IMPLEMENTATION  $run]
  set isIncArchive [get_property INCLUDE_IN_ARCHIVE $run]
  set stat [get_property STATUS $run]
  if { $isImpl == 1 && $isIncArchive == 1 && $stat != "write_bitstream Complete!" } {
      puts "INFO: Run $name"
      launch_runs $run -jobs $jobsize -to_step write_bitstream
      wait_on_run $run
      set stat [get_property STATUS $run]
      if {$stat != "write_bitstream Complete!"} {
        puts "------------- Fail implements:$name: $stat --------------"
        exit 1
      }
      puts "Result:$name: $stat"
  } else {
    puts "INFO: Skip $name"
  }
}

set VIVADO_IMPLEMENTS ""
if { [info exists ::env(VIVADO_IMPLEMENTS)] } {
  set tmp [string trim [string map {";" " "} $env(VIVADO_IMPLEMENTS)]]
  if { $tmp != "" } {
    set VIVADO_IMPLEMENTS $tmp
  }
}

if { "$VIVADO_IMPLEMENTS" == "" } {
  foreach r [get_runs] {
    runImpl $r $JOB_SIZE
  }
} else {
  foreach run [strip $VIVADO_IMPLEMENTS " "] {
    set r [get_runs run]
    runImpl $r $JOB_SIZE
  }
}

close_project
