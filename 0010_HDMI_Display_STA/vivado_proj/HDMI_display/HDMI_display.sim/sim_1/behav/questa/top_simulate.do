######################################################################
#
# File name : top_simulate.do
# Created on: Sun Feb 12 16:18:44 +0800 2023
#
# Auto generated by Vivado for 'behavioral' simulation
#
######################################################################
vsim -lib xil_defaultlib top_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {top_wave.do}

view wave
view structure
view signals

do {top.udo}

run 1000ns
