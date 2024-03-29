#
# TCL script: report_addr_${project}
#
#  target: vivado
#
set env_file          [lindex $argv 0]
set target_name       [lindex $argv 1]
set rep_save_dir      [lindex $argv 2]

puts "INFO: \[TCL\] set environments for tcl script, $env_file"
source $env_file

if { "$use_beta_device" != "" } {
  puts "INFO: \[Create TCL\] Enable beta device. $use_beta_device"
  enable_beta_device $use_beta_device
}

# find bd file
source $tcl_directory/_source_find_bd.tcl
set bd_file [getBdFile "${project_directory}/${project_name}.srcs/sources_1/bd" ""]
if { "$bd_file" == "" } {
  exit 1
}

# report file
set save_file 0
if { [info exists ::env(REPORT_CSV)] } {
  set tmp [string trim $env(REPORT_CSV)]
  if { $tmp != "" } {
    set save_file $tmp
    if { [file pathtype $save_file] == "relative" } {
      set save_file "$rep_save_dir/$save_file"
    }
  }
}

# do function
# this function is defined to avoid displaying source code commment ('#') by vivado
proc do { prj bd_file target_name save_file} {
  open_project $prj
  open_bd_design $bd_file

  if { $save_file != 0 } {
    set fid [open $save_file w]
  } else {
    puts ""
    puts "INFO: if you want to save result as csv, set REPORT_CSV variable"
    puts "    :   exp) make REPORT_CSV=foobar.csv $target_name"
  }
  puts ""

  # display title
  puts "------ Begin Address Report-----"
  set title "Offset, Range, Access, Usage, Path, NAME"
  puts $title
  if {$save_file != 0} {
    puts $fid $title
  }

  # display properties of all segments
  foreach seg [get_bd_addr_segs] {
    # Property: ACCESS, CLASS, EXEIMG, MEMTYPE, NAME,
    #         : OFFSET, PATH, RANGE, REMAPPED, SECURE, USAGE
    set path [get_property PATH $seg]
    if { "$path" == "" } {
      continue
    }
    set name   [get_property NAME   $seg]
    set offset [get_property OFFSET $seg]
    set range  [get_property RANGE  $seg]
    set access [get_property ACCESS $seg]
    set usage  [get_property USAGE  $seg]
    set line "$offset,$range,$access,$usage,$path,$name"
    puts $line
    if {$save_file != 0} {
      puts $fid $line
    }
  }

  # close
  puts "------ End Address Report  -----"
  puts ""
  if {$save_file != 0} {
    close $fid
    puts "INFO: output report file: $save_file"
  }
  puts ""

  close_project
}

do ${project_directory}/${project_name}.xpr $bd_file $target_name $save_file
