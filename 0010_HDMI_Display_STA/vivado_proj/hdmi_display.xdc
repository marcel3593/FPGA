set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports sys_clk]
set_property -dict {PACKAGE_PIN N16 IOSTANDARD LVCMOS33} [get_ports sys_rst_n]
set_property -dict {PACKAGE_PIN G19 IOSTANDARD TMDS_33} [get_ports tmds_data_0_p]
set_property -dict {PACKAGE_PIN K19 IOSTANDARD TMDS_33} [get_ports tmds_data_1_p]
set_property -dict {PACKAGE_PIN J20 IOSTANDARD TMDS_33} [get_ports tmds_data_2_p]
set_property -dict {PACKAGE_PIN J18 IOSTANDARD TMDS_33} [get_ports tmds_clk_p]


create_clock -period 20.000 -name sys_clk -waveform {0.000 10.000} [get_ports sys_clk]
create_generated_clock -name ser_clk -source [get_pins  PLLE2_BASE_inst/CLKIN1] [get_pins  PLLE2_BASE_inst/CLKOUT1]
create_generated_clock -name pixel_clk -source [get_pins  PLLE2_BASE_inst/CLKIN1] [get_pins  PLLE2_BASE_inst/CLKOUT0]

set_clock_uncertainty -setup 0.1 [get_clocks ser_clk]
set_clock_uncertainty -hold 0.05 [get_clocks ser_clk]

create_clock -name virtual_sys_clk -period 20.000 -waveform {0.000 10.000} 
create_clock -name virtual_ser_clk -period 2.667 -waveform  {0.000 1.333}

set_output_delay -clock virtual_ser_clk -max 1 [get_ports tmds_data_0_p]
set_output_delay -clock virtual_ser_clk -max 1 [get_ports tmds_data_1_p]
set_output_delay -clock virtual_ser_clk -max 1 [get_ports tmds_data_2_p]
set_output_delay -clock virtual_ser_clk -max 1 [get_ports tmds_clk_p]

set_output_delay -clock virtual_ser_clk -min 0.5 [get_ports tmds_data_0_p]
set_output_delay -clock virtual_ser_clk -min 0.5 [get_ports tmds_data_1_p]
set_output_delay -clock virtual_ser_clk -min 0.5 [get_ports tmds_data_2_p]
set_output_delay -clock virtual_ser_clk -min 0.5 [get_ports tmds_clk_p]