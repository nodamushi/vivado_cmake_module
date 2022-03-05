#
# TCL script: program_${project}
#
#  target: xsdb
#
set bitstream [lindex $argv 0]
set target_name [lindex $argv 1]


if { [info exists ::env(XSDB_URL)] } {
  puts "Connect $env(XSDB_URL)"
  connect -url $env(XSDB_URL)
} else {
  puts "Connect local server"
  connect
}

if { [info exists ::env(JTAG)] } {
  target $env(JTAG)
  puts "Write Bitstream: ${bitstream}"
  fpga $bitstream
  puts "Done"
  exit 0
} else {
  puts "Undefine JTAG (jtag target)"
  puts " exp) make JTAG=1 $target_name"
  puts ""
  puts "----------Target List----------"
  puts [target]
  puts "-------------------------------"
  exit 1
}