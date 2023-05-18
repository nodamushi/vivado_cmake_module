#
# TCL script: export_bd_${project}
#
#  target: vivado
#
set env_file      [lindex $argv 0]
puts "INFO: \[TCL\] set environments for tcl script, $env_file"
source $env_file

if { "$use_beta_device" != "" } {
  puts "INFO: \[Create TCL\] Enable beta device. $use_beta_device"
  enable_beta_device $use_beta_device
}
source $tcl_directory/_source_find_bd.tcl

puts "${project_directory}/${project_name}.xpr"
open_project ${project_directory}/${project_name}.xpr

foreach fpath $designs {
  set fname [file tail $fpath]
  set design_bd_name [file rootname $fname]
  set bdpath ${project_directory}/${project_name}.srcs/sources_1/bd

  set bd_file [getBdFile $bdpath $design_bd_name]
  if { "$bd_file" == "" } {
    puts "ERROR: $design_bd_name not found."
  } else {
    puts "INFO: Save $design_bd_name => $fpath"
    open_bd_design $bd_file
    write_bd_tcl -force $fpath
  }
}

close_project
