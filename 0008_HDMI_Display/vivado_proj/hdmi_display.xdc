set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports sys_clk]
set_property -dict {PACKAGE_PIN N16 IOSTANDARD LVCMOS33} [get_ports sys_rst_n]

create_clock -period 20.000 -name sys_clk -waveform {0.000 10.000} [get_ports sys_clk]

set_property -dict {PACKAGE_PIN G19 IOSTANDARD TMDS_33} [get_ports tmds_data_0_p]
set_property -dict {PACKAGE_PIN K19 IOSTANDARD TMDS_33} [get_ports tmds_data_1_p]
set_property -dict {PACKAGE_PIN J20 IOSTANDARD TMDS_33} [get_ports tmds_data_2_p]
set_property -dict {PACKAGE_PIN J18 IOSTANDARD TMDS_33} [get_ports tmds_clk_p]


