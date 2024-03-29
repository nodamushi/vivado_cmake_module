#
# TCL script: _impl_${project}_original
#
#  target: vivado
#
set env_file      [lindex $argv 0]
set jobsize       [lindex $argv 1]
puts "INFO: set environments for tcl script, $env_file"
source $env_file

if { "$use_beta_device" != "" } {
  puts "INFO: \[Create TCL\] Enable beta device. $use_beta_device"
  enable_beta_device $use_beta_device
}

puts "INFO: open_project ${project_directory}/${project_name}.xpr"
open_project ${project_directory}/${project_name}.xpr


proc is_not_completed {stat use_pdi} {
  set ok [expr {
    ($use_pdi == 1 && $stat == "write_device_image Complete!") \
    || ($use_pdi == 0 && $stat == "write_bitstream Complete!")
  }]
  return [expr { ! $ok }]
}

proc runImpl {run j use_pdi} {
  set name [get_property NAME $run]
  set isImpl [get_property IS_IMPLEMENTATION  $run]
  set isIncArchive [get_property INCLUDE_IN_ARCHIVE $run]
  set stat [get_property STATUS $run]
  if { $isImpl && $isIncArchive && [is_not_completed $stat $use_pdi] } {
      puts "INFO: Run $name"
      reset_runs $run
      launch_runs $run -jobs $j -to_step write_bitstream
      wait_on_run $run
      set stat [get_property STATUS $run]
      if {[is_not_completed $stat $use_pdi]} {
        puts "------------- Fail implements:$name: $stat --------------"
        exit 1
      }
      puts "Result:$name: $stat"
  } else {
    puts "INFO: Skip $name"
  }
}


if { "$impls" == "" } {
  foreach r [get_runs] {
    runImpl $r $jobsize $use_pdi
  }
} else {
  foreach run $impls {
    set r [get_runs $run]
    runImpl $r $jobsize $use_pdi
  }
}

close_project
