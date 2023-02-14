onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib dfifo_8x256_opt

do {wave.do}

view wave
view structure
view signals

do {dfifo_8x256.udo}

run -all

quit -force
