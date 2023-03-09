
vlog -novopt -lint -l comp.txt -timescale 1ns/1ps  ../src/rtl/*.vh  ../src/rtl/spi_master.v ../src/rtl/spi_flash_controller.v ../src/sim/*.vh  ../src/sim/rpt_pkg.sv ../src/sim/drv_mon_pkg.sv ../src/sim/test_pkg.sv ../src/sim/tb_spi_flash.sv 

vsim -i -wlf spi.wlf -default_radix hexadecimal -title spi  -novopt work.tb_spi_flash_controller

log -r /*


add wave /tb_spi_flash_controller/dut/*
add wave /tb_spi_flash_controller/dut/u_spi/*
add wave /drv_mon_pkg::generator::data_bytes_t