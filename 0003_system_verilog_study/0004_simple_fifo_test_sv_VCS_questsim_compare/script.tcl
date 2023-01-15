

vlog -novopt -lint -l comp.txt -timescale 1ns/1ps  src/*.v src/*.sv 

vsim -i -wlf sfifo.wlf -default_radix hexadecimal -title sfifo  -novopt work.tb1

log -r /*

run 1us

