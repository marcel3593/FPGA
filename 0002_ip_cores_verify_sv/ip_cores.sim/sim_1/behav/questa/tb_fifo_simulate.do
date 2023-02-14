######################################################################
#
# File name : tb_fifo_simulate.do
# Created on: Sun Jan 01 13:10:22 +0800 2023
#
# Auto generated by Vivado for 'behavioral' simulation
#
######################################################################
vsim -lib xil_defaultlib tb_fifo_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {tb_fifo_wave.do}

view wave
view structure
view signals

do {tb_fifo.udo}

run 1000ns
