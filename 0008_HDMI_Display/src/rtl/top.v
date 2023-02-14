module top(
  input             sys_clk            ,
  input             sys_rst_n          ,  
  output            tmds_data_0_p      ,
  output            tmds_data_0_n      ,
  output            tmds_data_1_p      ,
  output            tmds_data_1_n      ,
  output            tmds_data_2_p      ,
  output            tmds_data_2_n      ,
  output            tmds_clk_p         ,
  output            tmds_clk_n    
);

    //display
    reg display_en;
    wire [23:0] rgb;
    wire hs;
    wire vs;
    wire de;

    //pll and clock
    wire pixel_clk;
    wire ser_clk;
    wire pll_clk_in;
    wire pll_locked;
    wire pll_clk_out_0;
    wire pll_clk_out_1;
    wire pll_clkfb_in;
    wire pll_clkfb_out;
    //unused
    wire unconnected_clk2;
    wire unconnected_clk3;
    wire unconnected_clk4;
    wire unconnected_clk5;

    //display_en after pll locked
    always @(posedge pixel_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            display_en <=0;
        else if (pll_locked == 1'b0)
            display_en <=0;
        else
            display_en <=1;
    end
    
    //instance dispaly
    display_hvscan u_display_hvscan(
        .pixel_clk    (pixel_clk)        ,                                       
        .rst_n        (sys_rst_n)        ,                                   
        .display_en   (display_en)       ,                                       
        .rgb          (rgb)              ,                               
        .hs           (hs)               ,                               
        .vs           (vs)               ,                               
        .de           (de)                                      
    );

    //instance HDMI_top
    HDMI_top u_HDMI (
        .display_en     (display_en   )    ,
        .rgb            (rgb          )    ,
        .hs             (hs           )    ,
        .vs             (vs           )    ,
        .de             (de           )    ,
        .pixel_clk      (pixel_clk    )    ,
        .rst_n          (sys_rst_n    )    ,
        .ser_clk        (ser_clk      )    ,
        .tmds_data_0_p  (tmds_data_0_p)    ,
        .tmds_data_0_n  (tmds_data_0_n)    ,
        .tmds_data_1_p  (tmds_data_1_p)    ,
        .tmds_data_1_n  (tmds_data_1_n)    ,
        .tmds_data_2_p  (tmds_data_2_p)    ,
        .tmds_data_2_n  (tmds_data_2_n)    ,
        .tmds_clk_p     (tmds_clk_p   )    ,
        .tmds_clk_n     (tmds_clk_n   ) 
    );



    // xilinx pll primitive
    // Xilinx HDL Language Template, version 2018.3
    //?? do i need the IBUF or it already has one since sys_clk is input port
    //IBUF #(
    //.IOSTANDARD("DEFAULT")) 
    //clkin1_ibufg
    //   (.I(sys_clk),
    //    .O(pll_clk_in));
    
    assign pll_clk_in =  sys_clk;

    BUFG clkout1_buf
       (.I(pll_clk_out_0),
        .O(pixel_clk));

    BUFG clkout2_buf
       (.I(pll_clk_out_1),
        .O(ser_clk));

    BUFG clkout_fb_buf
       (.I(pll_clkfb_out),
        .O(pll_clkfb_in));

    PLLE2_BASE #(
       .BANDWIDTH("OPTIMIZED"),  // OPTIMIZED, HIGH, LOW
       .CLKFBOUT_MULT(30),        // Multiply value for all CLKOUT, (2-64)
       .CLKFBOUT_PHASE(0.0),     // Phase offset in degrees of CLKFB, (-360.000-360.000).
       .CLKIN1_PERIOD(20),      // Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
       // CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for each CLKOUT (1-128)
       .CLKOUT0_DIVIDE(20),
       .CLKOUT1_DIVIDE(4),
       .CLKOUT2_DIVIDE(1),
       .CLKOUT3_DIVIDE(1),
       .CLKOUT4_DIVIDE(1),
       .CLKOUT5_DIVIDE(1),
       // CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for each CLKOUT (0.001-0.999).
       .CLKOUT0_DUTY_CYCLE(0.5),
       .CLKOUT1_DUTY_CYCLE(0.5),
       .CLKOUT2_DUTY_CYCLE(0.5),
       .CLKOUT3_DUTY_CYCLE(0.5),
       .CLKOUT4_DUTY_CYCLE(0.5),
       .CLKOUT5_DUTY_CYCLE(0.5),
       // CLKOUT0_PHASE - CLKOUT5_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
       .CLKOUT0_PHASE(0.0),
       .CLKOUT1_PHASE(0.0),
       .CLKOUT2_PHASE(0.0),
       .CLKOUT3_PHASE(0.0),
       .CLKOUT4_PHASE(0.0),
       .CLKOUT5_PHASE(0.0),
       .DIVCLK_DIVIDE(1),        // Master division value, (1-56)
       .REF_JITTER1(0.0),        // Reference input jitter in UI, (0.000-0.999).
       .STARTUP_WAIT("FALSE")    // Delay DONE until PLL Locks, ("TRUE"/"FALSE")
    )
    PLLE2_BASE_inst (
       // Clock Outputs: 1-bit (each) output: User configurable clock outputs
       .CLKOUT0(pll_clk_out_0),   // 1-bit output: CLKOUT0
       .CLKOUT1(pll_clk_out_1),   // 1-bit output: CLKOUT1
       .CLKOUT2(unconnected_clk2),   // 1-bit output: CLKOUT2
       .CLKOUT3(unconnected_clk3),   // 1-bit output: CLKOUT3
       .CLKOUT4(unconnected_clk4),   // 1-bit output: CLKOUT4
       .CLKOUT5(unconnected_clk5),   // 1-bit output: CLKOUT5
       // Feedback Clocks: 1-bit (each) output: Clock feedback ports
       .CLKFBOUT(pll_clkfb_out), // 1-bit output: Feedback clock
       .LOCKED(pll_locked),     // 1-bit output: LOCK
       .CLKIN1(pll_clk_in),     // 1-bit input: Input clock
       // Control Ports: 1-bit (each) input: PLL control ports
       .PWRDWN(1'b0),     // 1-bit input: Power-down
       .RST(~sys_rst_n),           // 1-bit input: Reset
       // Feedback Clocks: 1-bit (each) input: Clock feedback ports
       .CLKFBIN(pll_clkfb_in)    // 1-bit input: Feedback clock
    );

endmodule
