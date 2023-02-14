vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xil_defaultlib -64 -incr \
"../../../../ip_cores.srcs/sources_1/ip/rom_8x256/sim/rom_8x256.v" \


vlog -work xil_defaultlib \
"glbl.v"

