#
# TCL script: ${project}
#
#  target: vivado
#
set project_name      [lindex $argv 0]
set project_directory [lindex $argv 1]
set board_name        [lindex $argv 2]
set full_path         [lindex $argv 3]

create_project -force $project_name $project_directory
set_property board $board_name [current_project]
if { [info exists ::env(VIVADO_IP_DIRECTORIES)] } {
  set_property IP_REPO_PATHS $env(VIVADO_IP_DIRECTORIES) [current_fileset]
}
update_ip_catalog
if { [info exists ::env(VIVADO_RTL_LIST)] } {
  foreach file $env(VIVADO_RTL_LIST) {
    add_files $file
  }
}

if { [info exists ::env(VIVADO_CONSTRAINT_LIST)] } {
  foreach file $env(VIVADO_CONSTRAINT_LIST) {
    add_files -fileset constrs_1 $file
  }
}

if { [info exists ::env(VIVADO_DESIGN_TCL)] } {
  if { [file exists $env(VIVADO_DESIGN_TCL) ] == 1 } {
    source $env(VIVADO_DESIGN_TCL)
    regenerate_bd_layout
    save_bd_design
    set design_bd_name [get_bd_designs]
    set bd_files [get_files $design_bd_name.bd]
    puts $bd_files
    generate_target all $bd_files
    make_wrapper -files $bd_files -top -import
  } else {
    puts "Skip load design: $env(VIVADO_DESIGN_TCL)"
  }
}

close_project

puts "Create Project: ${full_path}"