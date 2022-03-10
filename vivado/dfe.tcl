create_partition_def -name led -module myrtl
create_reconfig_module -name myrtl -partition_def [get_partition_defs led ]  -define_from myrtl

create_reconfig_module -name myled2 -partition_def [get_partition_defs led ]
add_files ${root}/src/rtl/myrtl2.v \
          ${root}/src/rtl/_myrtl2.sv \
          -of_objects [get_reconfig_modules myled2]

update_compile_order

# Create configuration set
create_pr_configuration -name config_1 -partitions [list myrtl:myrtl ]
create_pr_configuration -name config_2 -partitions [list myrtl:myled2 ]
set_property PR_CONFIGURATION config_1 [get_runs impl_1]
create_run child_0_impl_1 \
           -parent_run impl_1 \
           -flow {Vivado Implementation 2021} \
           -pr_config config_2


