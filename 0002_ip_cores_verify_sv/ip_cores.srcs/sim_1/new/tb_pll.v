`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/01 14:51:16
// Design Name: 
// Module Name: tb_pll
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_pll();

reg sys_clk;
reg sys_rst_n;

wire clk_300M     ;
wire clk_25M      ;
wire clk_shift_90 ;
wire clk_50M_20d  ;
wire clk_600M     ;
wire locked       ;

initial begin
    sys_clk = 0 ;
    sys_rst_n <= 0;
    #20 sys_rst_n <= 1;
end

always #10 sys_clk <= ~sys_clk;

pll pll_inst(
    .sys_clk         (sys_clk      )       ,
    .sys_rst_n       (sys_rst_n    )         ,
    .clk_300M        (clk_300M     )        ,
    .clk_25M         (clk_25M      )       ,
    .clk_shift_90    (clk_shift_90 )            ,
    .clk_50M_20d     (clk_50M_20d  )           ,
    .clk_600M        (clk_600M     )        ,
    .locked          (locked       )       
    );

endmodule
