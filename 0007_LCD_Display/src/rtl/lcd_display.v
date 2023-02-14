module lcd_display(
    input               sys_clk     ,
    input               sys_rst_n   ,
    output              lcd_clk     ,
    output  reg         lcd_rst     ,
    output              lcd_bl      ,
    output      [23:0]  lcd_rgb     ,
    output              lcd_hs      ,
    output              lcd_vs      ,
    output              lcd_de      
);
    wire pll_clk_in;
    wire pll_clk_out;
    wire pixel_clk;
    wire unconnected_clk1;
    wire unconnected_clk2;
    wire unconnected_clk3;
    wire unconnected_clk4;
    wire unconnected_clk5;
    reg  display_en;
    wire pll_clkfb_out;
    wire pll_clkfb_in;
    wire pll_locked;
    

    //display_en after pll locked
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            lcd_rst<=0;
        else if (pll_locked == 1'b0)
            lcd_rst<=0;
        else
            lcd_rst<=1;
    end

    always @(posedge pixel_clk or negedge lcd_rst) begin
        if (!lcd_rst)
            display_en <=0;
        else
            display_en <=1;
    end

    //lcd bl
    assign lcd_clk = pixel_clk;
    assign lcd_bl = display_en;


    display_hvscan u1_display_hvscan(
    .pixel_clk  (pixel_clk ),                      
    .rst_n      (sys_rst_n ),                  
    .display_en (display_en),                      
    .rgb        (lcd_rgb   ),              
    .hs         (lcd_hs    ),              
    .vs         (lcd_vs    ),              
    .de         (lcd_de    )             
    );
    
    assign pll_clk_in =  sys_clk;

    // xilinx pll primitive
    // Xilinx HDL Language Template, version 2018.3
    //?? do i need the IBUF or it already has one since sys_clk is input port
    //IBUF #(
    //.IOSTANDARD("DEFAULT")) 
    //clkin1_ibufg
    //   (.I(sys_clk),
    //    .O(pll_clk_in));

    BUFG clkout1_buf
       (.I(pll_clk_out),
        .O(pixel_clk));

    BUFG clkout2_buf
       (.I(pll_clkfb_out),
        .O(pll_clkfb_in));

    PLLE2_BASE #(
       .BANDWIDTH("OPTIMIZED"),  // OPTIMIZED, HIGH, LOW
       .CLKFBOUT_MULT(32),        // Multiply value for all CLKOUT, (2-64)
       .CLKFBOUT_PHASE(0.0),     // Phase offset in degrees of CLKFB, (-360.000-360.000).
       .CLKIN1_PERIOD(20),      // Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
       // CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for each CLKOUT (1-128)
       .CLKOUT0_DIVIDE(48),
       .CLKOUT1_DIVIDE(1),
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
       .CLKOUT0(pll_clk_out),   // 1-bit output: CLKOUT0
       .CLKOUT1(unconnected_clk1),   // 1-bit output: CLKOUT1
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