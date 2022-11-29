//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: yj
// 
// Create Date: 2022/11/27 14:37:53
// Design Name: 
// Module Name: keypress
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: keypress to generate pulse signals
// 
//////////////////////////////////////////////////////////////////////////////////


module key_press (
    input sys_clk,
    input sys_rst_n,
    input key,
    output reg key_pulse
);

parameter TIMEOUT = 32'd999_999;

reg [31:0] key_cnt; 


//key counter max
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)
        key_cnt <=0;
    else if (key)
        key_cnt <=0;
    else if (key_cnt == TIMEOUT)
        key_cnt <= key_cnt;
    else
        key_cnt <= key_cnt + 1;
end


// key pulse
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)
        key_pulse <=0;
    else if (key_cnt == TIMEOUT - 1)
        key_pulse <=1;
    else
        key_pulse <=0;
end


endmodule