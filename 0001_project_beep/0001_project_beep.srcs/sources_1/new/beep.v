
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: yj
// 
// Create Date: 2022/11/26 14:37:53
// Design Name: 
// Module Name: beep
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


module beep(
    input sys_clk,
    input sys_rst_n,
    input pl_key_0,
    input pl_key_1,
    output wire beep,
    output reg pl_led_0,
    output wire pl_led_1
    );

    parameter TIMEOUT = 32'd999_999;

    wire key_pulse;
    wire key_pulse_1;
    wire signal_pwm;
    reg beep_flag;
    reg pwm_rst_n;
    reg [7:0] duty_cycle;
    reg [7:0] freq_div;
    reg [2:0] pwm_state_cnt;
    reg pwm_mode;

    assign beep = signal_pwm & beep_flag;
    assign pl_led_1 = signal_pwm;

    //beep flag and led flag
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            beep_flag <= 0;
            pl_led_0 <=0;
        end
        else if (key_pulse) begin
            beep_flag <= ~beep_flag;
            pl_led_0 <= ~pl_led_0;
        end
        else begin
            beep_flag <= beep_flag;
            pl_led_0 <= pl_led_0;        
        end    
    end


    //pwm state counter
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            pwm_state_cnt <=0;
            pwm_mode <=0;
        end
        else if (key_pulse_1 && (pwm_state_cnt == 4)) begin
            pwm_state_cnt <=0;
            pwm_mode <= ~pwm_mode;
        end
        else if (key_pulse_1) begin
            pwm_state_cnt <= pwm_state_cnt + 1;
            pwm_mode <= pwm_mode;
        end
        else begin
            pwm_state_cnt <= pwm_state_cnt;
            pwm_mode <= pwm_mode;
        end
    end

    //pwm configuration
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            duty_cycle <=100;
            freq_div <=100;
            pwm_rst_n <=1;
        end
        else if ( key_pulse_1 ) begin
            duty_cycle <= pwm_mode ? 20*pwm_state_cnt : 100 - 20*pwm_state_cnt;
            freq_div <=100;
            pwm_rst_n <=0;                
        end
        else begin
            duty_cycle <=pwm_mode ? 20*pwm_state_cnt : 100 - 20*pwm_state_cnt;
            freq_div <=100;
            pwm_rst_n <=1;            
        end
        end
        
    key_press
    #
    (
        .TIMEOUT(TIMEOUT)
    )
    u_key_press_0
    (
    .sys_clk      (sys_clk),        
    .sys_rst_n    (sys_rst_n),          
    .key          (pl_key_0),    
    .key_pulse    (key_pulse)         
    );


    key_press
    #
    (
        .TIMEOUT(TIMEOUT)
    )
    u_key_press_1
    (
    .sys_clk      (sys_clk),        
    .sys_rst_n    (sys_rst_n),          
    .key          (pl_key_1),    
    .key_pulse    (key_pulse_1)         
    );

    pwm_gen u_pwm_gen_1(
    .sys_clk        (sys_clk   )            ,
    .sys_rst_n      (sys_rst_n )            ,
    .rst_n          (pwm_rst_n)             ,
    .duty_cycle     (duty_cycle)            ,
    .freq_div       (freq_div  )            ,
    .signal_pwm     (signal_pwm)                 
    );


endmodule
