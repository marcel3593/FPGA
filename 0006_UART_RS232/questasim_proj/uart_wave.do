onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group control /tb_uart/dut/u3_uart_control/clk
add wave -noupdate -expand -group control /tb_uart/dut/u3_uart_control/rst_n
add wave -noupdate -expand -group control /tb_uart/dut/u3_uart_control/rx_data
add wave -noupdate -expand -group control /tb_uart/dut/u3_uart_control/valid
add wave -noupdate -expand -group control /tb_uart/dut/u3_uart_control/parity_error
add wave -noupdate -expand -group control /tb_uart/dut/u3_uart_control/rx_busy
add wave -noupdate -expand -group control /tb_uart/dut/u3_uart_control/tx_busy
add wave -noupdate -expand -group control /tb_uart/dut/u3_uart_control/tx_data
add wave -noupdate -expand -group control /tb_uart/dut/u3_uart_control/wr_en
add wave -noupdate -expand -group control /tb_uart/dut/u3_uart_control/rd_addr
add wave -noupdate -expand -group control /tb_uart/dut/u3_uart_control/wr_addr
add wave -noupdate -expand -group control /tb_uart/dut/u3_uart_control/eo_cnt
add wave -noupdate -expand -group control /tb_uart/dut/u3_uart_control/i
add wave -noupdate -expand -group rx /tb_uart/dut/u2_uart_rx/clk
add wave -noupdate -expand -group rx /tb_uart/dut/u2_uart_rx/rst_n
add wave -noupdate -expand -group rx /tb_uart/dut/u2_uart_rx/rx
add wave -noupdate -expand -group rx /tb_uart/dut/u2_uart_rx/dout
add wave -noupdate -expand -group rx /tb_uart/dut/u2_uart_rx/valid
add wave -noupdate -expand -group rx /tb_uart/dut/u2_uart_rx/parity_error
add wave -noupdate -expand -group rx /tb_uart/dut/u2_uart_rx/rx_busy
add wave -noupdate -expand -group rx /tb_uart/dut/u2_uart_rx/rx_reg
add wave -noupdate -expand -group rx /tb_uart/dut/u2_uart_rx/rx_reg1
add wave -noupdate -expand -group rx /tb_uart/dut/u2_uart_rx/rx_reg2
add wave -noupdate -expand -group rx /tb_uart/dut/u2_uart_rx/rx_reg3
add wave -noupdate -expand -group rx /tb_uart/dut/u2_uart_rx/rx_reg4
add wave -noupdate -expand -group rx /tb_uart/dut/u2_uart_rx/rx_en
add wave -noupdate -expand -group rx /tb_uart/dut/u2_uart_rx/baud_cnt
add wave -noupdate -expand -group rx /tb_uart/dut/u2_uart_rx/sample_en
add wave -noupdate -expand -group rx /tb_uart/dut/u2_uart_rx/bit_cnt
add wave -noupdate -expand -group rx /tb_uart/dut/u2_uart_rx/data
add wave -noupdate -expand -group rx /tb_uart/dut/u2_uart_rx/parity
add wave -noupdate -expand -group tx /tb_uart/dut/u1_uart_tx/clk
add wave -noupdate -expand -group tx /tb_uart/dut/u1_uart_tx/rst_n
add wave -noupdate -expand -group tx /tb_uart/dut/u1_uart_tx/din
add wave -noupdate -expand -group tx /tb_uart/dut/u1_uart_tx/wr_en
add wave -noupdate -expand -group tx /tb_uart/dut/u1_uart_tx/tx
add wave -noupdate -expand -group tx /tb_uart/dut/u1_uart_tx/tx_busy
add wave -noupdate -expand -group tx /tb_uart/dut/u1_uart_tx/data
add wave -noupdate -expand -group tx /tb_uart/dut/u1_uart_tx/tx_en
add wave -noupdate -expand -group tx /tb_uart/dut/u1_uart_tx/baud_cnt
add wave -noupdate -expand -group tx /tb_uart/dut/u1_uart_tx/bit_cnt
add wave -noupdate -expand -group tx /tb_uart/dut/u1_uart_tx/parity_flag
add wave -noupdate -expand -group tx /tb_uart/dut/u1_uart_tx/parity_bit
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {11456299637143 ps} 0} {{Cursor 3} {11456700396230 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 262
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
configure wave -timelineunits us
update
WaveRestoreZoom {11454535786639 ps} {11460764144424 ps}
