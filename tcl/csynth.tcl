#
# TCL script: csynth_${project}
#
#  target: vitis_hls/vivado_hls
#
source $env(NHLS_TCL_DIR)/_source_init_hls_project.tcl

csynth_design
export_design \
  -display_name $env(NHLS_NAME) \
  -description $env(NHLS_DESCRIPTION) \
  -ipname $env(NHLS_IPNAME) \
  -taxonomy $env(NHLS_IP_TAXONOMY) \
  -vendor $env(NHLS_IP_VENDOR) \
  -version $env(NHLS_IP_VERSION)
exit
