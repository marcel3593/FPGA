set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports clk]
set_property -dict {PACKAGE_PIN N16 IOSTANDARD LVCMOS33} [get_ports rst_n]
set_property -dict {PACKAGE_PIN T19 IOSTANDARD LVCMOS33} [get_ports rx]
set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33} [get_ports tx]


create_clock -period 20.000 -name sys_clk -waveform {0.000 10.000} [get_ports clk]