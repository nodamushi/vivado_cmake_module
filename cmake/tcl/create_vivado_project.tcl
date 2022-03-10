#
# TCL script: ${project}
#
#  target: vivado
#
set project_name      [lindex $argv 0]
set project_directory [lindex $argv 1]
set board_name        [lindex $argv 2]
set full_path         [lindex $argv 3]
set top_module_name   [lindex $argv 4]
# source_directory: CMakeLists.txt directory
set source_directory  [lindex $argv 5]
# repository top directory
set root              [lindex $argv 6]

create_project -force $project_name $project_directory
set_property board $board_name [current_project]
if { [info exists ::env(VIVADO_IP_DIRECTORIES)] } {
  set_property IP_REPO_PATHS $env(VIVADO_IP_DIRECTORIES) [current_fileset]
}
update_ip_catalog

# Add file
if { [info exists ::env(VIVADO_RTL_LIST)] } {
  foreach file $env(VIVADO_RTL_LIST) {
    add_files $file
  }
}

# Add constraint
if { [info exists ::env(VIVADO_CONSTRAINT_LIST)] } {
  foreach file $env(VIVADO_CONSTRAINT_LIST) {
    add_files -fileset constrs_1 $file
  }
}

# load user script
if { [info exists ::env(VIVADO_CREATE_PROJECT_SOURCE_0)] } {
  set VIVADO_CREATE_PROJECT_SOURCE_0 $env(VIVADO_CREATE_PROJECT_SOURCE_0)
  if { [file exists ${VIVADO_CREATE_PROJECT_SOURCE_0}]} {
    source ${VIVADO_CREATE_PROJECT_SOURCE_0}
  } else {
    puts "ERROR!! Source file ${VIVADO_CREATE_PROJECT_SOURCE_0} not found"
    exit 1
  }
}

# load design file
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

if { "$top_module_name" != "" } {
  set_property top ${top_module_name} [current_fileset]
}

# load dfe setting tcl file
if { [info exists ::env(VIVADO_DFE_TCL)] } {
  puts "INFO: Enable Dynamic Function eXchange"
  if { [file exists $env(VIVADO_DFE_TCL)] } {
    set_property PR_FLOW 1 [current_project]
    source $env(VIVADO_DFE_TCL)
  } else {
    puts "ERROR!! Source file $env(VIVADO_DFE_TCL) is not found"
    exit 1
  }
}

# load user script
if { [info exists ::env(VIVADO_CREATE_PROJECT_SOURCE_1)] } {
  set VIVADO_CREATE_PROJECT_SOURCE_1 $env(VIVADO_CREATE_PROJECT_SOURCE_1)
  if { [file exists ${VIVADO_CREATE_PROJECT_SOURCE_1}]} {
    source ${VIVADO_CREATE_PROJECT_SOURCE_1}
  } else {
    puts "ERROR!! Source file ${VIVADO_CREATE_PROJECT_SOURCE_1} not found"
    exit 1
  }
}

close_project

puts "Create Project: ${full_path}"

