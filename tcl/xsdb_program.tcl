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

set url ""
set port ""

if { [info exists ::env(HWSVR)] } {
  set url [string trim $env(HWSVR)]
  if { $url != "" } {
    if { [info exists ::env(HWSVRPORT)] } {
      set port [string trim $env(HWSVRPORT)]
    }
  }
}

if { $url != "" } {
  if { $port != "" } {
    puts "Connect $url::$port hw_server"
    connect -url $url -port $port
  } else {
    puts "Connect $url hw_server"
    connect -url $url
  }
} else {
  puts "Connect local hw_server"
  connect
}

set jtag ""

if { [info exists ::env(JTAG)] } {
  set jtag [string trim $env(JTAG)]
}

if { $jtag != "" } {
  target $jtag
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