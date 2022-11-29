onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_beep/u_beep/TIMEOUT
add wave -noupdate /tb_beep/u_beep/sys_clk
add wave -noupdate /tb_beep/u_beep/sys_rst_n
add wave -noupdate /tb_beep/u_beep/pl_key_0
add wave -noupdate /tb_beep/u_beep/pl_key_1
add wave -noupdate /tb_beep/u_beep/beep
add wave -noupdate /tb_beep/u_beep/pl_led_0
add wave -noupdate /tb_beep/u_beep/pl_led_1
add wave -noupdate /tb_beep/u_beep/key_pulse
add wave -noupdate /tb_beep/u_beep/key_pulse_1
add wave -noupdate /tb_beep/u_beep/signal_pwm
add wave -noupdate /tb_beep/u_beep/beep_flag
add wave -noupdate /tb_beep/u_beep/pwm_rst_n
add wave -noupdate /tb_beep/u_beep/duty_cycle
add wave -noupdate /tb_beep/u_beep/freq_div
add wave -noupdate /tb_beep/u_beep/pwm_state_cnt
add wave -noupdate /tb_beep/u_beep/pwm_mode
add wave -noupdate /tb_beep/u_beep/u_pwm_gen_1/cnt_max
add wave -noupdate /tb_beep/u_beep/u_pwm_gen_1/cnt_high_max
add wave -noupdate /tb_beep/u_beep/u_pwm_gen_1/pwm_cnt
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {118390000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 290
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
WaveRestoreZoom {0 ps} {525 us}
