create_pblock pblock_myrtl
add_cells_to_pblock [get_pblocks pblock_myrtl] [get_cells -quiet [list myrtl]]
resize_pblock [get_pblocks pblock_myrtl] -add {SLICE_X22Y0:SLICE_X43Y48}
resize_pblock [get_pblocks pblock_myrtl] -add {DSP48_X1Y0:DSP48_X1Y17}
resize_pblock [get_pblocks pblock_myrtl] -add {RAMB18_X1Y0:RAMB18_X2Y17}
resize_pblock [get_pblocks pblock_myrtl] -add {RAMB36_X1Y0:RAMB36_X2Y8}
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets aclk]
