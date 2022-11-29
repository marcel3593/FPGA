set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports sys_clk]
set_property -dict {PACKAGE_PIN N16 IOSTANDARD LVCMOS33} [get_ports sys_rst_n]
set_property -dict {PACKAGE_PIN L14 IOSTANDARD LVCMOS33} [get_ports pl_key_0]
set_property -dict {PACKAGE_PIN K16 IOSTANDARD LVCMOS33} [get_ports pl_key_1]
set_property -dict {PACKAGE_PIN H15 IOSTANDARD LVCMOS33} [get_ports pl_led_0]
set_property -dict {PACKAGE_PIN L15 IOSTANDARD LVCMOS33} [get_ports pl_led_1]
set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33} [get_ports beep]

create_clock -period 20.000 -name sys_clk -waveform {0.000 10.000} [get_ports sys_clk]