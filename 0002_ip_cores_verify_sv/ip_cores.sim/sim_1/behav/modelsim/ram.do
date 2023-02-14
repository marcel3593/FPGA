onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_ram/clka
add wave -noupdate /tb_ram/ena
add wave -noupdate /tb_ram/sys_rst_n
add wave -noupdate /tb_ram/wea
add wave -noupdate -radix unsigned /tb_ram/addra
add wave -noupdate -radix unsigned /tb_ram/dina_t
add wave -noupdate -radix unsigned /tb_ram/dina
add wave -noupdate -radix unsigned /tb_ram/douta
add wave -noupdate /tb_ram/data_invert
add wave -noupdate /tb_ram/loop_count
add wave -noupdate /glbl/GSR
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5134197 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {5084170 ps} {5749398 ps}
