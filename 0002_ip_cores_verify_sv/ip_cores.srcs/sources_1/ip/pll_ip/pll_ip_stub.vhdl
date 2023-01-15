-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
-- Date        : Thu Dec  1 14:46:54 2022
-- Host        : marcel_002 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               d:/FPGA_study/projects/ip_cores/ip_cores.srcs/sources_1/ip/pll_ip/pll_ip_stub.vhdl
-- Design      : pll_ip
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z020clg400-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pll_ip is
  Port ( 
    clk_300M : out STD_LOGIC;
    clk_25M : out STD_LOGIC;
    clk_shift_90 : out STD_LOGIC;
    clk_50M_20d : out STD_LOGIC;
    clk_600M : out STD_LOGIC;
    resetn : in STD_LOGIC;
    locked : out STD_LOGIC;
    clk_in1 : in STD_LOGIC
  );

end pll_ip;

architecture stub of pll_ip is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk_300M,clk_25M,clk_shift_90,clk_50M_20d,clk_600M,resetn,locked,clk_in1";
begin
end;
