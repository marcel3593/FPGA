
vlog -novopt -lint -l comp.txt -timescale 1ns/1ps   ../src/sim/rpt_pkg.sv ../src/sim/uart_dv_pkg.sv ../src/sim/tb_uart.sv ../src/rtl/parameters_def.v ../src/rtl/uart.v 

vsim -i -wlf uart.wlf -default_radix hexadecimal -title uart  -novopt work.tb_uart

log -r /*

run 10us
