set project_name      [lindex $argv 0]
set project_directory [lindex $argv 1]
set xsafile           [lindex $argv 2]

puts "INFO: open_project ${project_directory}/${project_name}.xpr"
open_project ${project_directory}/${project_name}.xpr
write_hw_platform \
  -fixed \
  -include_bit \
  -force \
  -file $xsafile

close_project
puts "Output: $xsafile"
