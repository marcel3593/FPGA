onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -t 1ps -L blk_mem_gen_v8_4_2 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -L xpm -lib xil_defaultlib xil_defaultlib.s_ram_8x256 xil_defaultlib.glbl

do {wave.do}

view wave
view structure
view signals

do {s_ram_8x256.udo}

run -all

quit -force
