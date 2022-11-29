`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/11/27 13:33:20
// Design Name: 
// Module Name: tb_beep
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


module tb_beep(

    );

    reg sys_clk;
    reg sys_rst_n;
    reg pl_key_0;
    reg pl_key_1;
    wire beep;
    wire pl_led_0;
    wire pl_led_1;
    reg i;

    initial begin
        sys_clk = 0;
        sys_rst_n <=0;
        pl_key_0 <=1;
        pl_key_1<=1;
        #15 sys_rst_n <=1;
        #25 pl_key_0 <=0;
        #20000 pl_key_0 <=1;
        for(i=0;i<12;i=i+1) begin
            #25 pl_key_1 <=0;
            #30125 pl_key_1 <=1;
        end
    end

    always #10 sys_clk <= ~sys_clk;

    beep
    #(
        .TIMEOUT(32'd999)
    )
    u_beep
    (
        .sys_clk         (sys_clk),    
        .sys_rst_n       (sys_rst_n),  
        .pl_key_0        (pl_key_0),   
        .pl_key_1        (pl_key_1),   
        .beep            (beep),    
        .pl_led_0        (pl_led_0),  
        .pl_led_1        (pl_led_1)
    );

endmodule
