#
# TCL script: program_${project}
#
#  target: xsdb
#
set bitstream [lindex $argv 0]
set target_name [lindex $argv 1]

if { "$target_name" == "" } {
  set target_name "<name>"
}

if { [info exists ::env(HWSVR)] } {
  if { [info exists ::env(HWSVRPORT)] } {
    puts "Connect $env(HWSVR)::$env(HWSVRPORT) hw_server"
    connect -url $env(HWSVR) -port $env(HWSVRPORT)
  } else {
    puts "Connect $env(HWSVR) hw_server"
    connect -url $env(HWSVR)
  }
} else {
  puts "Connect local hw_server"
  connect
}

if { [info exists ::env(JTAG)] } {
  target $env(JTAG)
  puts "Write Bitstream: ${bitstream}"
  fpga $bitstream
  puts "Done"
  exit 0
} else {
  puts "Undefine JTAG (jtag target number)"
  puts " exp) make JTAG=1 $target_name"
  puts ""
  puts "----------Target List----------"
  puts [target]
  puts "-------------------------------"
  exit 1
}