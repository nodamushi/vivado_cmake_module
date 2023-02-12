#
# TCL script: ${project}
#
#  target: vivado
#
set env_file      [lindex $argv 0]
puts "INFO: \[Create TCL\] set environments for tcl script, $env_file"
source $env_file

if { "boardRepos" != "" } {
  puts "INFO: \[Create TCL\] Set board.repoPaths $boardRepos"
  set_param board.repoPaths $boardRepos
}

# load user script (TCL0)
foreach file $tcl0 {
  if { [file exists ${file}] } {
    puts "INFO: \[Create TCL\] source ${file}"
    source ${file}
  } else {
    puts "ERROR!! Source file ${file} not found"
    exit 1
  }
}


# if board part contains `*`, search board part.
if { [string first "*" $board_part] != -1 } {
  set find_board_part [get_board_parts -quiet -latest_file_version $board_part]
  if { $find_board_part eq "" } {
    puts "ERROR: `$board_part` board part is not found"
    exit 1
  }
  puts "INFO: \[Create TCL\] Board parts: `$board_part` -> `$find_board_part`"
  set board_part $find_board_part
}

create_project -force $project_name $project_directory
set_property board $board_part [current_project]
if { "$ips" != "" } {
  puts "INFO: \[Create TCL\] set_property IP_REPO_PATHS $ips"
  set_property IP_REPO_PATHS $ips [current_fileset]
}
update_ip_catalog

# Add file
if { $rtl != "" } {
  puts "INFO: \[Create TCL\] add_files $rtl"
  add_files $rtl
}


# Add constraint
if { $constrs != "" } {
  puts "INFO: \[Create TCL\] add_files -fileset constrs_1 $constrs"
  add_files -fileset constrs_1 $constrs
}


# load user script (TCL1)
foreach file $tcl1 {
  if { [file exists ${file}] } {
    puts "INFO: \[Create TCL\] source ${file}"
    source ${file}
  } else {
    puts "ERROR!! Source file ${file} not found"
    exit 1
  }
}

# load design file
foreach design $designs {
  if { $design != "" } {
    if { [file exists $design ] == 1 } {
      puts "INFO: \[Create TCL\] Load design file $design"
      source $design
      regenerate_bd_layout
      save_bd_design
      set design_bd_name [get_bd_designs]
      set bd_files [get_files $design_bd_name.bd]
      generate_target all $bd_files
      if { "$top_module_name" == "${design_bd_name}_wrapper" } {
        make_wrapper -files $bd_files -top -import
      }
    } else {
      puts "WARN: Skip load design: $design"
      set design_bd_name [file rootname [file tail $design]]
      create_bd_design $design_bd_name
      set bd_files [get_files $design_bd_name.bd]
      generate_target all $bd_files
      if { "$top_module_name" == "${design_bd_name}_wrapper" } {
        make_wrapper -files $bd_files -top -import
      }
    }
  }
}

if { "$top_module_name" != "" } {
  puts "INFO: \[Create TCL\] set_property top ${top_module_name}"
  set_property top ${top_module_name} [current_fileset]
}

# load dfx setting tcl file
if { $dfx != "" } {
  puts "INFO: \[Create TCL\] Enable Dynamic Function eXchange"
  if { [file exists $dfx] } {
    puts "INFO: \[Create TCL\] set_property PR_FLOW 1"
    set_property PR_FLOW 1 [current_project]
    puts "INFO: \[Create TCL\] source $dfx"
    source $dfx
  } else {
    puts "ERROR!! Source file $dfx is not found"
    exit 1
  }
}

# load user script (TCL2)
foreach file $tcl2 {
  if { [file exists ${file}] } {
    puts "INFO: \[Create TCL\] source ${file}"
    source ${file}
  } else {
    puts "ERROR!! Source file ${file} not found"
    exit 1
  }
}

puts "INFO: \[Create TCL\] close_project"
close_project
puts ""
puts "Create Project: ${project_file}"
puts ""

