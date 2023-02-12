# source from tcl files
# initialize project
open_project $project_name

if { $src != "" } {
  add_files -cflags "$cflags" $src
}

if { $tbsrc != "" } {
  add_files -tb -cflags "$tbcflags" $tbsrc
}

set_top $top
if { $is_vitis } {
  open_solution $solution -flow_target $flow_target
} else {
  open_solution $solution
}
set_part $part
create_clock -period $period -name default
