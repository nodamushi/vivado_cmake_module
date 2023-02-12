#
# TCL script: csynth_${project}
#
#  target: vitis_hls/vivado_hls
#
source $tcl_directory/_source_init_hls_project.tcl
csynth_design
export_design \
  -display_name $name \
  -description $description \
  -ipname $ipname \
  -taxonomy $taxonomy \
  -vendor $vendor \
  -version $version
exit
