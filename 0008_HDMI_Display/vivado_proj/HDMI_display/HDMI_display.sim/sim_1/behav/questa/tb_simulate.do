######################################################################
#
# File name : tb_simulate.do
# Created on: Sun Feb 12 17:00:02 +0800 2023
#
# Auto generated by Vivado for 'behavioral' simulation
#
######################################################################
vsim -lib xil_defaultlib tb_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {tb_wave.do}

view wave
view structure
view signals

do {tb.udo}

run 1000ns