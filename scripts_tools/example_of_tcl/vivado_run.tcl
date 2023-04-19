open_project D:/FPGA_study/projects/0011_IIC_EEPROM/vivado_proj/uart_eeprom_iic/uart_eeprom_iic.xpr

reset_run synth_1
launch_runs synth_1 -jobs 8
launch_runs impl_1 -jobs 8
refresh_design
launch_runs impl_1 -to_step write_bitstream -jobs 8

report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose -max_paths 10 -input_pins -routable_nets -name timing_1 -file D:/FPGA_study/projects/0011_IIC_EEPROM/vivado_proj/uart_eeprom_iic/timing_report.txt -rpx D:/FPGA_study/projects/0011_IIC_EEPROM/vivado_proj/uart_eeprom_iic/uart_eeprom_iic.runs/impl_1/timing_report.rpx
report_utilization -file D:/FPGA_study/projects/0011_IIC_EEPROM/vivado_proj/uart_eeprom_iic/utilization_report.txt -name utilization_1
report_power -file {D:/FPGA_study/projects/0011_IIC_EEPROM/vivado_proj/uart_eeprom_iic/power_power_1.txt} -name {power_1}
report_clock_interaction -delay_type min_max -significant_digits 3 -name timing_2 -file D:/FPGA_study/projects/0011_IIC_EEPROM/vivado_proj/uart_eeprom_iic/timing_report_CLOCK.txt
report_drc -name drc_1 -file D:/FPGA_study/projects/0011_IIC_EEPROM/vivado_proj/uart_eeprom_iic/DRC_drc_1.txt -ruledecks {default}
report_ssn -name ssn_1 -file D:/FPGA_study/projects/0011_IIC_EEPROM/vivado_proj/uart_eeprom_iic/ssn_report.csv