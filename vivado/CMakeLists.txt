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

get_target_property(prj_dir vivado_study PROJECT_DIR)
get_target_property(runs_dir vivado_study RUNS_DIR)

add_custom_target(program_vivado_study_pr0
  DEPENDS impl_vivado_study
  COMMAND ${VIVADO_WRITE_BITSTREAM}
   ${runs_dir}/impl_1/myrtl_myrtl_partial.bit
   program_vivado_study_pr0 # this target name
)

add_custom_target(program_vivado_study_pr1
  DEPENDS impl_vivado_study
  COMMAND ${VIVADO_WRITE_BITSTREAM}
   ${runs_dir}/child_0_impl_1/myrtl_myled2_partial.bit
   program_vivado_study_pr1 # this target name
)
