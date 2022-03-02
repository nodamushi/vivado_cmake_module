set project_name      [lindex $argv 0]
set project_directory [lindex $argv 1]

set board_name           "digilentinc.com:cora-z7-07s:part0:1.0"
set rtl_directory        "../src/rtl"
set constraint_directory "../src/constraint"
set ip_dir               "../build/src/hls"
set design_tcl_file      "design_1.tcl"

# Create/Init Project
create_project $project_name $project_directory
set_property board $board_name [current_project]
set_property IP_REPO_PATHS $ip_dir [current_fileset]
update_ip_catalog

# Add sources
add_files $rtl_directory
add_files -fileset constrs_1 $constraint_directory/constraint.xdc


source $design_tcl_file
regenerate_bd_layout
save_bd_design
set design_bd_name [get_bd_designs]
set bd_files [get_files $design_bd_name.bd]
puts $bd_files
generate_target all $bd_files
make_wrapper -files $bd_files -top -import

close_project
