#
# TCL script: ${project}
#
#  target: vivado
#
set project_name      [lindex $argv 0]
set project_directory [lindex $argv 1]
set board_part        [lindex $argv 2]
set full_path         [lindex $argv 3]
set top_module_name   [lindex $argv 4]
# source_directory: CMakeLists.txt directory
set source_directory  [lindex $argv 5]
# repository top directory
set root              [lindex $argv 6]

# load user script (TCL0)
if { [info exists ::env(VIVADO_CREATE_PROJECT_SOURCE_0)] } {
  foreach file [split [string map {";" " "} $env(VIVADO_CREATE_PROJECT_SOURCE_0)] " "]  {
    if { [file exists ${file}] } {
      source ${file}
    } else {
      puts "ERROR!! Source file ${file} not found"
      exit 1
    }
  }
}

# if board part contains `*`, search board part.
if { [string first "*" $board_part] != -1 } {
  set find_board_part [get_board_parts -quiet -latest_file_version $board_part]
  if { $find_board_part eq "" } {
    puts "ERROR: `$board_part` board part is not found"
    exit 1
  }
  puts "INFO: Board parts: `$board_part` -> `$find_board_part`"
  set board_part $find_board_part
}

create_project -force $project_name $project_directory
set_property board $board_part [current_project]
if { [info exists ::env(VIVADO_IP_DIRECTORIES)] } {
  set tmp [string trim $env(VIVADO_RTL_LIST)]
  if { $tmp != "" } {
    set_property IP_REPO_PATHS $tmp [current_fileset]
  }
}
update_ip_catalog

# Add file
if { [info exists ::env(VIVADO_RTL_LIST)] } {
  set tmp [string trim [string map {";" " "} $env(VIVADO_RTL_LIST)]]
  if { $tmp != "" } {
    add_files $tmp
  }
}

# Add constraint
if { [info exists ::env(VIVADO_CONSTRAINT_LIST)] } {
  set tmp [string trim [string map {";" " "} $env(VIVADO_CONSTRAINT_LIST)]]
  if { $tmp != "" } {
    add_files -fileset constrs_1 $tmp
  }
}

# load user script (TCL1)
if { [info exists ::env(VIVADO_CREATE_PROJECT_SOURCE_1)] } {
  foreach file [split [string map {";" " "} $env(VIVADO_CREATE_PROJECT_SOURCE_1)] " "] {
    if { [file exists ${file}] } {
      source ${file}
    } else {
      puts "ERROR!! Source file ${file} not found"
      exit 1
    }
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

# load dfx setting tcl file
if { [info exists ::env(VIVADO_DFX_TCL)] } {
  set tmp [string trim [string map {";" " "} $env(VIVADO_DFX_TCL)]]
  if { $tmp != "" } {
    puts "INFO: Enable Dynamic Function eXchange"
    if { [file exists $tmp] } {
      set_property PR_FLOW 1 [current_project]
      source $tmp
    } else {
      puts "ERROR!! Source file $env(VIVADO_DFX_TCL) is not found"
      exit 1
    }
  }
}

# load user script (TCL2)
if { [info exists ::env(VIVADO_CREATE_PROJECT_SOURCE_2)] } {
  foreach file [split [string map {";" " "} $env(VIVADO_CREATE_PROJECT_SOURCE_2)] " "]  {
    if { [file exists ${file}] } {
      source ${file}
    } else {
      puts "ERROR!! Source file ${file} not found"
      exit 1
    }
  }
}

close_project

puts "Create Project: ${full_path}"

