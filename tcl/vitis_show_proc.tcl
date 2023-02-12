set env_file      [lindex $argv 0]
source $env_file
set x [getprocessors ${xsa_file}]
puts "-----------------------------------------"
puts "Processors: ${xsa_file}"
puts "-----------------------------------------"
puts $x
puts "-----------------------------------------"
