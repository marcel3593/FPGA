module serializer( 
    input               display_en  ,
    input       [9:0]   din         ,
    input               pixel_clk   ,
    input               ser_clk     ,
    input               rst_n       ,
    output              dout_p      ,
    output              dout_n      
);

reg ser_en; //sync the ser_clk and pixel_clk
reg [2:0]   counter;
reg         dout_odd;
reg         dout_even;
wire         dout;


//ser_en
always @(posedge pixel_clk or negedge rst_n) begin
    if (!rst_n  ||  display_en == 1'b0)
        ser_en <=0;
    else
        ser_en <=1;
end

//counter
always @(posedge ser_clk or negedge rst_n) begin
    if (!rst_n || display_en == 1'b0)
        counter <=0;
    else if (ser_en == 1'b0)
        counter <=0;
    else if (counter == 3'd4)
        counter <=0;
    else
        counter <= counter + 1;
end

//dout
always @(posedge ser_clk or negedge rst_n) begin
    if (!rst_n || display_en == 1'b0) begin
        dout_even <=0;
        dout_odd <=0;
    end
    else if (ser_en == 1'b0)begin
        dout_even <=0;
        dout_odd <=0;
    end
    else begin
        dout_even <=din[counter*2];
        dout_odd <=din[counter*2 + 1];
    end
end

   // ODDR: Output Double Data Rate Output Register with Set, Reset
   //       and Clock Enable.
   //       Artix-7
   // Xilinx HDL Language Template, version 2018.3

   ODDR #(
      .DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
      .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
      .SRTYPE("ASYNC") // Set/Reset type: "SYNC" or "ASYNC" 
   ) ODDR_inst (
      .Q(dout),   // 1-bit DDR output
      .C(ser_clk),   // 1-bit clock input
      .CE(1'b1), // 1-bit clock enable input
      .D1(dout_even), // 1-bit data input (positive edge)
      .D2(dout_odd), // 1-bit data input (negative edge)
      .R(~rst_n),   // 1-bit reset
      .S(0'bz)    // 1-bit set
   );

   // End of ODDR_inst instantiation

   // OBUFDS: Differential Output Buffer
   //         Kintex UltraScale
   // Xilinx HDL Language Template, version 2018.3

   OBUFDS OBUFDS_inst (
      .O(dout_p),   // 1-bit output: Diff_p output (connect directly to top-level port)
      .OB(dout_n), // 1-bit output: Diff_n output (connect directly to top-level port)
      .I(dout)    // 1-bit input: Buffer input
   );

   // End of OBUFDS_inst instantiation

endmodule