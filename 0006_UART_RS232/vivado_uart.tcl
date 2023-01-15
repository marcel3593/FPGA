
create_project -force project_uart ./project_uart -part xc7z020clg400-2
set_property design_mode GateLvl [current_fileset]
add_files -norecurse {../synplify/wujian100_open_200t_3b_rev/wujian100_open.edf}
set_property top wujian100_open [get_filesets sources_1]
add_files -fileset constrs_1 -norecurse {../synplify/wujian100_open_200t_3b_rev/wujian100_open_edif.xdc ../xdc/XC7A200T3B.xdc}
set_property top_file ../synplify/wujian100_open_200t_3b_rev/wujian100_open.edf [current_fileset]
launch_runs impl_1 -to_step write_bitstream
