#
# TCL script: csynth_${project}
#
#  target: vitis_hls/vivado_hls
#
source $env(HLS_TCL_DIR)/_source_init_hls_project.tcl

csynth_design
export_design \
  -display_name $env(HLS_NAME) \
  -description $env(HLS_DESCRIPTION) \
  -ipname $env(HLS_IPNAME) \
  -taxonomy $env(HLS_IP_TAXONOMY) \
  -vendor $env(HLS_IP_VENDOR) \
  -version $env(HLS_IP_VERSION)
exit
