######################################################################
#
# File name : tb_ram_simulate.do
# Created on: Wed Dec 07 14:06:24 +0800 2022
#
# Auto generated by Vivado for 'behavioral' simulation
#
######################################################################
vsim -voptargs="+acc" -L blk_mem_gen_v8_4_2 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -L xpm -lib xil_defaultlib xil_defaultlib.tb_ram xil_defaultlib.glbl

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {tb_ram_wave.do}

view wave
view structure
view signals

do {tb_ram.udo}

run 1000ns
