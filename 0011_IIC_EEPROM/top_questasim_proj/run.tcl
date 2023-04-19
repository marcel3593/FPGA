#user defined variables
set proj  spi
set path_rtl ../src/rtl/
set path_sim ../src/sim_top/

set f_rtl_list {sync_fifo.v iic_master.v eeprom_cntl.v uart_parameters.vh uart.v top_uart_eeprom_iic.v}
set f_sim_list {AT24C64D.v rpt_pkg.sv uart_dv_pkg.sv tb_top_uart_eeprom_iic.sv}

set tb tb_top_uart_eeprom_iic
set sim_time 1ns/10ps

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
add wave /${tb}/dut/*
