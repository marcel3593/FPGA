######################################################################
#
# File name : tb_lcd_display_simulate.do
# Created on: Wed Feb 08 15:38:35 +0800 2023
#
# Auto generated by Vivado for 'behavioral' simulation
#
######################################################################
vsim -lib xil_defaultlib tb_lcd_display_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {tb_lcd_display_wave.do}

view wave
view structure
view signals

do {tb_lcd_display.udo}

run 1000ns
