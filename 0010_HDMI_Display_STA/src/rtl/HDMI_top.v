module HDMI_top (
  input                 display_en         ,
  input       [23:0]    rgb                ,
  input                 hs                 ,
  input                 vs                 ,
  input                 de                 ,
  input                 pixel_clk          ,
  input                 rst_n              ,
  input                 ser_clk            ,
  output                tmds_data_0_p      ,
  output                tmds_data_0_n      ,
  output                tmds_data_1_p      ,
  output                tmds_data_1_n      ,
  output                tmds_data_2_p      ,
  output                tmds_data_2_n      ,
  output                tmds_clk_p         ,
  output                tmds_clk_n      
);

wire [9:0] blu_out;
wire [9:0] grn_out;
wire [9:0] red_out;
wire [9:0] clk_out;

assign clk_out = 10'b0000011111;

//#####################
//#instance encoder
//##################

//channel0 blue
tmds_encoder #(
  .INSTANCE_ID(2'd0)
)u_encoder_0(
  .display_en   (display_en),
  .d            (rgb[7:0]) ,
  .c0           (hs) ,
  .c1           (vs) ,
  .de           (de) ,
  .pixel_clk    (pixel_clk) ,
  .rst_n        (rst_n) ,
  .q            (blu_out)
);

//channel1 green
tmds_encoder #(
  .INSTANCE_ID(2'd1)
)
u_encoder_1(
  .display_en   (display_en),
  .d            (rgb[15:8]) ,
  .c0           (1'b0) ,
  .c1           (1'b0) ,
  .de           (de) ,
  .pixel_clk    (pixel_clk) ,
  .rst_n        (rst_n) ,
  .q            (grn_out)
);

//channel2 red
tmds_encoder #(
  .INSTANCE_ID(2'd2)
)
u_encoder_2(
  .display_en   (display_en),
  .d            (rgb[23:16]) ,
  .c0           (1'b0) ,
  .c1           (1'b0) ,
  .de           (de) ,
  .pixel_clk    (pixel_clk) ,
  .rst_n        (rst_n) ,
  .q            (red_out)
);

//#####################
//#serializer
//##################

//#channel 0
serializer u_serializer_0( 
    .display_en  (display_en)     ,
    .din         (blu_out)        ,
    .pixel_clk   (pixel_clk)      ,
    .ser_clk     (ser_clk)        ,
    .rst_n       (rst_n)          ,
    .dout_p      (tmds_data_0_p)  ,
    .dout_n      (tmds_data_0_n) 
);

//#channel 1
serializer u_serializer_1( 
    .display_en  (display_en)     ,
    .din         (grn_out)        ,
    .pixel_clk   (pixel_clk)      ,
    .ser_clk     (ser_clk)        ,
    .rst_n       (rst_n)          ,
    .dout_p      (tmds_data_1_p)  ,
    .dout_n      (tmds_data_1_n) 
);

//#channel 2
serializer u_serializer_2( 
    .display_en  (display_en)    ,
    .din         (red_out)        ,
    .pixel_clk   (pixel_clk)      ,
    .ser_clk     (ser_clk)        ,
    .rst_n       (rst_n)          ,
    .dout_p      (tmds_data_2_p)  ,
    .dout_n      (tmds_data_2_n) 
);

//#channel clk
serializer u_serializer_3( 
    .display_en  (display_en)     ,
    .din         (clk_out)        ,
    .pixel_clk   (pixel_clk)      ,
    .ser_clk     (ser_clk)        ,
    .rst_n       (rst_n)          ,
    .dout_p      (tmds_clk_p)     ,
    .dout_n      (tmds_clk_n) 
);


endmodule