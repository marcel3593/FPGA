#user defined variables
set proj  spi
set path_rtl ../src/rtl/
set path_sim ../src/sim/

set f_rtl_list {*.vh spi_master.v spi_flash_controller.v}
set f_sim_list {*.vh rpt_pkg.sv drv_mon_pkg.sv test_pkg.sv tb_spi_flash.sv} 

set tb tb_spi_flash_controller
set sim_time 1ns/1ps


# string handle
set vlog_command "vlog -novopt -lint -l comp.txt -timescale ${sim_time}"
set vsim_command "vsim -i -wlf ${proj}.wlf -default_radix hexadecimal -title ${proj} -novopt work.${tb} -l simlog.txt" 

foreach i ${f_rtl_list} {
    set vlog_command "$vlog_command ${path_rtl}$i "
}

foreach i ${f_sim_list} {
    set vlog_command "$vlog_command ${path_sim}$i "
}

#complier
eval $vlog_command

#sim
eval $vsim_command

#log and signals
log -r /*
add wave /tb_spi_flash_controller/dut/*
add wave /tb_spi_flash_controller/dut/u_spi/*
add wave /drv_mon_pkg::generator::data_bytes_t