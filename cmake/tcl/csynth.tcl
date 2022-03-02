open_project $env(VITIS_HLS_PROJECT_NAME)
open_solution $env(VITIS_HLS_SOLUTION_NAME)

csynth_design
export_design \
  -display_name $env(VITIS_HLS_NAME) \
  -description $env(VITIS_HLS_DESCRIPTION) \
  -ipname $env(VITIS_HLS_IPNAME) \
  -taxonomy $env(VITIS_HLS_IP_TAXONOMY) \
  -vendor $env(VITIS_HLS_IP_VENDOR) \
  -version $env(VITIS_HLS_IP_VERSION)
exit
