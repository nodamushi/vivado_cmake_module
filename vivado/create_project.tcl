# Project name and directory are set from Makefile
set project_name      [lindex $argv 0]
set project_directory [lindex $argv 1]

set board_name           "digilentinc.com:cora-z7-07s:part0:1.0"
set rtl_directory        "../src/rtl"
set constraint_directory "../src/constraint"

# Create/Init Project
create_project $project_name $project_directory
set_property board $board_name [current_project]
update_ip_catalog

# Add sources
add_files $rtl_directory
add_files -fileset constrs_1 $constraint_directory/constraint.xdc

close_project
