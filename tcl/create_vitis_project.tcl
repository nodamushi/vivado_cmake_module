#
# Create vitis workspace, platform, application.
#

# load CMake setting file.
set env_file      [lindex $argv 0]
source $env_file

# set workspace
setws ${ws}

####################
# TCL0 user script
####################
foreach f $tcl0 {
  puts "Source TCL0 $f"
  source $f
}

###################
# Define platform
###################
platform create \
  -name ${platform} \
  -hw ${xsa_file}

domain create \
  -name ${domain} \
  -display-name ${long_domain} \
  -os ${os} \
  -proc ${proc} \
  -runtime {cpp}

platform active ${platform}
platform generate

####################
# TCL1 user script
####################
foreach f $tcl1 {
  puts "Source TCL1 $f"
  source $f
}

#####################
# Save processor path
#####################
set pcell [hsi::get_cells -filter {IP_TYPE==PROCESSOR} ${proc}]
set paddrtag  [common::get_property ADDRESS_TAG  $pcell]
set ppath [lindex [split $paddrtag ":"] 0]

set file [open $proc_file "w"]
puts -nonewline $file $ppath
close $file


###################
# project
###################
app create \
  -name $project \
  -platform ${platform} \
  -domain ${domain} \
  -template ${template} \
  -lang ${lang}

foreach f $src {
  importsources -name $project -path $f -soft-link
}

foreach config {Release Debug} {

  app config -name $project -set build-config $config

  foreach d $incdir {
    app config -name $project -add include-path $d
  }

  foreach d $defs {
    app config -name $project -add define-compiler-symbols $d
  }

  ####################
  # TCL2 user script
  ####################
  foreach f $tcl2 {
    puts "Source TCL2 $f"
    source $f
  }
}

app config -name $project -set build-config $build_mode

####################
# TCL3 user script
####################
foreach f $tcl3 {
  puts "Source TCL3 $f"
  source $f
}

