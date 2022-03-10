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
  set JOB_SIZE $env(VIVADO_JOB_SIZE)
}

foreach run [get_runs] {
  set isImpl [get_property IS_IMPLEMENTATION  $run]
  set isIncArchive [get_property INCLUDE_IN_ARCHIVE $run]
  set stat [get_property STATUS $run]
  if { $isImpl == 1 && $isIncArchive == 1 && $stat != "write_bitstream Complete!" } {
      launch_runs $run -jobs $JOB_SIZE -to_step write_bitstream
      wait_on_run $run
      set stat [get_property STATUS $run]
      set name [get_property NAME $run]
      if {$stat != "write_bitstream Complete!"} {
        puts "------------- Fail implements:$name: $stat --------------"
        exit 1
      }
      puts "Result:$name: $stat"
  }
}

close_project
