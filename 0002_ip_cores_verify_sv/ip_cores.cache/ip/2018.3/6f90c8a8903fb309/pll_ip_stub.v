// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Thu Dec  1 14:46:54 2022
// Host        : marcel_002 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ pll_ip_stub.v
// Design      : pll_ip
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix(clk_300M, clk_25M, clk_shift_90, clk_50M_20d, 
  clk_600M, resetn, locked, clk_in1)
/* synthesis syn_black_box black_box_pad_pin="clk_300M,clk_25M,clk_shift_90,clk_50M_20d,clk_600M,resetn,locked,clk_in1" */;
  output clk_300M;
  output clk_25M;
  output clk_shift_90;
  output clk_50M_20d;
  output clk_600M;
  input resetn;
  output locked;
  input clk_in1;
endmodule
