open_project $env(HLS_PROJECT_NAME)
open_solution $env(HLS_SOLUTION_NAME)

csynth_design
export_design \
  -display_name $env(HLS_NAME) \
  -description $env(HLS_DESCRIPTION) \
  -ipname $env(HLS_IPNAME) \
  -taxonomy $env(HLS_IP_TAXONOMY) \
  -vendor $env(HLS_IP_VENDOR) \
  -version $env(HLS_IP_VERSION)
exit
