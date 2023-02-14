onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib rom_8x256_opt

do {wave.do}

view wave
view structure
view signals

do {rom_8x256.udo}

run -all

quit -force
