project(vivado_study)

add_vivado_project(vivado_study
  TOP        design_1_wrapper
  BOARD      digilentinc.com:cora-z7-07s:part0:1.0
  RTL        ${RTL_DIR}
  CONSTRAINT ${CONSTRAINT_DIR}
  IP         ${BUILD_HLS_DIR}
  DESIGN     design_1.tcl
  DEPENDS    csynth_hlsled
)
