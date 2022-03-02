set project_name      [lindex $argv 0]
set project_directory [lindex $argv 1]

open_project ${project_directory}/${project_name}.xpr

set project_status [get_property STATUS [get_runs impl_1]]
if {$project_status != "write_bitstream Complete!"} {
    launch_runs impl_1 -jobs 8 -to_step write_bitstream
    wait_on_run impl_1
}

close_project
