onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_rom/clka
add wave -noupdate /tb_rom/ena
add wave -noupdate /tb_rom/sys_rst_n
add wave -noupdate -radix unsigned /tb_rom/addra
add wave -noupdate -radix unsigned /tb_rom/douta
add wave -noupdate /glbl/GSR
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {20979879 ps} 0}
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
WaveRestoreZoom {20672695 ps} {21017227 ps}
