# source from tcl files
# find bd file of vivado
#  bd_base_dir: ${project_directory}/${project_name}.srcs/sources_1/bd
#  design_name: (option)design name.
proc getBdFile { bd_base_dir {design_name ""} } {

  if { "$design_name" != "" } {
    set bd_file "$bd_base_dir/$design_name/$design_name.bd"
    if { [file exists $bd_file ] != 1 } {
      puts "ERROR: $design_name.bd is not found."
      return ""
    }
    return $bd_file
  } else {
    set bd_dirs [glob -directory $bd_base_dir -type d *]
    set bd_dirs_len [llength bd_dirs]
    if { ${bd_dirs_len} == 0 } {
      puts "ERROR: bd directory not found"
      exit 1
    } elseif { ${bd_dirs_len} != 1 } {
      puts "ERROR: Multiple board directories were found. Please specify the name of the design."
      puts ${bd_dirs}
      return ""
    }
    set bd_dir [lindex $bd_dirs 0]
    set bd_dir_files [glob -directory $bd_dir -type f *.bd]
    if { [llength $bd_dir_files] != 1 } {
      puts "ERROR: bd file not found in '${bd_dir}'"
      return ""
    }
    set bd_file [lindex $bd_dir_files 0]
    return $bd_file
  }

}
