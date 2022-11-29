
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: yj
// 
// Create Date: 2022/11/27 14:37:53
// Design Name: 
// Module Name: pwm
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: user dynamic configurable pwm module
// 
//////////////////////////////////////////////////////////////////////////////////


module pwm_gen (
    input sys_clk,
    input sys_rst_n,
    input rst_n,
    input [7:0] duty_cycle,
    input [7:0] freq_div,
    output reg signal_pwm
);

    wire [7:0] cnt_max;
    wire [7:0] cnt_high_max;

    reg [7:0] pwm_cnt;

    assign cnt_max = freq_div-1;
    assign cnt_high_max = (freq_div*duty_cycle/100);
      
    
    //pwm_cnt
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            pwm_cnt <=0;
        else if (!rst_n)
            pwm_cnt <=0;
        else if (pwm_cnt == cnt_max)
            pwm_cnt <=0;
        else
            pwm_cnt <= pwm_cnt + 1;
    end

    //signal_pwm output
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            signal_pwm <=0;
        else if (!rst_n)
            signal_pwm <=signal_pwm;
        else if (pwm_cnt < cnt_high_max)
            signal_pwm <=1;
        else
            signal_pwm <=0;
    end


endmodule