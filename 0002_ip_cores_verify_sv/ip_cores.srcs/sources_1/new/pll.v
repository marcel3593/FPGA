module pll(
    input sys_clk,
    input sys_rst_n,
    output clk_300M,
    output clk_25M,
    output clk_shift_90,
    output clk_50M_20d,
    output clk_600M,
    output locked
    );


  pll_ip pll_ip_inst_0
   (
    // Clock out ports
    .clk_300M(clk_300M),     // output clk_300M
    .clk_25M(clk_25M),     // output clk_25M
    .clk_shift_90(clk_shift_90),     // output clk_shift_90
    .clk_50M_20d(clk_50M_20d),     // output clk_50M_20d
    .clk_600M(clk_600M),     // output clk_600M
    // Status and control signals
    .resetn(sys_rst_n), // input resetn
    .locked(locked),       // output locked
   // Clock in ports
    .clk_in1(sys_clk));      // input clk_in1
// INST_TAG_END ------ End INSTANTIATION Template

endmodule
