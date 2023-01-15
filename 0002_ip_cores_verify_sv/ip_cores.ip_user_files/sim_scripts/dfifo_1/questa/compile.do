vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xil_defaultlib

vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work xil_defaultlib -64 \
"../../../ip/dfifo_1/sim/dfifo_1.v" \


vlog -work xil_defaultlib \
"glbl.v"

