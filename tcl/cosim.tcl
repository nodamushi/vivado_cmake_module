#
# TCL Script: cosim_${project}
#
#  target: vitis_hls/vivado_hls
#
open_project $project_name
open_solution $solution

# default setting
# user environment variable
# make TLEVEL=all cosim_foobar
if { [info exists ::env(TLEVEL)] } {
  set tmp [string trim $env(TLEVEL)]
  if { $tmp != "" } {
    set trace_level $tmp
  }
}

set argv ""
# make ARGV="-foo -bar" cosim_foobar
if { [info exists ::env(ARGV)] } {
  set tmp [string trim $env(ARGV)]
  if { $tmp != "" } {
    set argv $tmp
  }
}

cosim_design -O \
    -ldflags $cosim_ldflags \
    -rtl verilog \
    -tool xsim \
    -trace_level $trace_level \
    -argv "$argv"
exit
