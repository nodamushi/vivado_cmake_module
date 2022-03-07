#
# TCL script: export_bd_${project}
#
#  target: vivado
#
set project_name      [lindex $argv 0]
set project_directory [lindex $argv 1]
set tcl_directory     [lindex $argv 2]
set output_tcl_file   [lindex $argv 3]
set design_name       [lindex $argv 4]

source $tcl_directory/_source_find_bd.tcl


puts "${project_directory}/${project_name}.xpr"
puts [pwd]

open_project ${project_directory}/${project_name}.xpr
set bd_file [getBdFile "${project_directory}/${project_name}.srcs/sources_1/bd" $design_name]
if { "$bd_file" == "" } {
  exit 1
}

open_bd_design $bd_file
write_bd_tcl -force $output_tcl_file
close_project
