project(vivado_study)

add_vivado_project(vivado_study
  TOP        top
  BOARD      digilentinc.com:cora-z7-07s:part0:1.0
  DFE        dfe.tcl
  RTL        ${RTL_DIR} top.v
  CONSTRAINT ${CONSTRAINT_DIR} dfe.xdc
  IP         ${BUILD_HLS_DIR}
  DESIGN     design_1.tcl
  DEPENDS    csynth_hlsled
)
