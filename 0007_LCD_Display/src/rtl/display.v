
module display_hvscan (
    input           pixel_clk,
    input           rst_n,
    input           display_en,
    output  [23:0]  rgb,
    output          hs,
    output          vs,
    output          de
);
    //default 800*480 @60 config
    parameter HSYNC_T = 128 ;
    parameter HBPH_T = 88;
    parameter HLBD_T =  0;
    parameter HDATA_T = 800;
    parameter HRBD_T = 0;
    parameter HFPH_T = 40;
    parameter VSYNC_T = 2;
    parameter VBPH_T = 33;
    parameter VTBD_T = 0;
    parameter VDATA_T = 480;
    parameter VBBD_T = 0;
    parameter VFPH_T = 10;
    
    wire        rd_en;
    wire [15:0] px;
    wire [23:0] rgb_data;

    display_control #(
        .HSYNC_T(HSYNC_T),   
        .HBPH_T (HBPH_T ),   
        .HLBD_T (HLBD_T ),   
        .HDATA_T(HDATA_T),   
        .HRBD_T (HRBD_T ),   
        .HFPH_T (HFPH_T ),   
        .VSYNC_T(VSYNC_T),   
        .VBPH_T (VBPH_T ),   
        .VTBD_T (VTBD_T ),   
        .VDATA_T(VDATA_T),   
        .VBBD_T (VBBD_T ),   
        .VFPH_T (VFPH_T )         
    ) u1_display_control(
        .pixel_clk  (pixel_clk ),                 
        .rst_n      (rst_n     ),             
        .display_en (display_en),                  
        .rgb_data   (rgb_data  ),                
        .px         (px        ),          
        .rd_en      (rd_en     ),             
        .rgb        (rgb       ),           
        .hs         (hs        ),          
        .vs         (vs        ),          
        .de         (de        )                 
    );

    display_buffer #(
        .HDATA_T(HDATA_T)
    ) u2_display_buffer (
        .pixel_clk(pixel_clk),                  
        .rst_n    (rst_n    ),              
        .rd_en    (rd_en    ),              
        .px       (px       ),           
        .rgb_data (rgb_data )                        
    );
endmodule


module display_control(
    input                pixel_clk,
    input                rst_n,
    input                display_en,
    input       [23:0]   rgb_data,
    output reg  [15:0]   px,
    output               rd_en,
    output      [23:0]   rgb,
    output               hs,
    output               vs,
    output reg           de
);
    //default 800*480 @60 config
    parameter HSYNC_T = 128 ;
    parameter HBPH_T = 88;
    parameter HLBD_T =  0;
    parameter HDATA_T = 800;
    parameter HRBD_T = 0;
    parameter HFPH_T = 40;
    parameter VSYNC_T = 2;
    parameter VBPH_T = 33;
    parameter VTBD_T = 0;
    parameter VDATA_T = 480;
    parameter VBBD_T = 0;
    parameter VFPH_T = 10;
     
    //local param for count and flags
    localparam HSYNC_END_CNT   = HSYNC_T - 1;
    localparam HDATA_START_CNT = HSYNC_T + HBPH_T + HLBD_T - 1;
    localparam HDATA_END_CNT   = HSYNC_T + HBPH_T + HLBD_T + HDATA_T - 1;
    localparam H_CNT_MAX       = HSYNC_T + HBPH_T + HLBD_T + HDATA_T + HRBD_T + HFPH_T - 1;
    localparam VSYNC_END_CNT   = VSYNC_T - 1;
    localparam VDATA_START_CNT = VSYNC_T + VBPH_T + VTBD_T - 1;
    localparam VDATA_END_CNT   = VSYNC_T + VBPH_T + VTBD_T + VDATA_T - 1;
    localparam V_CNT_MAX       = VSYNC_T + VBPH_T + VTBD_T + VDATA_T + VBBD_T + VFPH_T - 1;

    reg [15:0] hs_cnt;
    reg [15:0] vs_cnt;

    //hs_cnt
    always @(posedge pixel_clk or negedge rst_n) begin
        if (!rst_n)
            hs_cnt <=0;
        else if (display_en == 1'b0)
            hs_cnt <=0;
        else if (hs_cnt == H_CNT_MAX)
            hs_cnt <=0;
        else
            hs_cnt <= hs_cnt + 1;

    end 

    //hs
    assign hs = ( (hs_cnt>=0) && (hs_cnt<=HSYNC_END_CNT) && (display_en == 1'b1) ) ? 1 : 0;

    //vs_cnt
    always @(posedge pixel_clk or negedge rst_n) begin
        if (!rst_n)
            vs_cnt <=0;
        else if (display_en == 1'b0)
            vs_cnt <=0;
        else if (vs_cnt == V_CNT_MAX && hs_cnt == H_CNT_MAX) //finish scan last H
            vs_cnt <=0;
        else if (hs_cnt == H_CNT_MAX)
            vs_cnt <= vs_cnt + 1;
        else
            vs_cnt <=vs_cnt;
    end

    //vs
    assign vs = ( (vs_cnt>=0) && (vs_cnt<=VSYNC_END_CNT) && (display_en == 1'b1) ) ? 1 : 0;    

    //rd_en and de
    assign rd_en = ( ( vs_cnt >= VDATA_START_CNT + 1 && vs_cnt <= VDATA_END_CNT ) && (hs_cnt>=HDATA_START_CNT) && (hs_cnt<=HDATA_END_CNT-1) && (display_en == 1'b1) ) ? 1 : 0;
    always @(posedge pixel_clk or negedge rst_n) begin
        if (!rst_n)
            de <=0;
        else
            de <=rd_en; 
    end    

    //px
    always @(posedge pixel_clk or negedge rst_n) begin
        if (!rst_n)
            px <=0;
        else if (display_en == 1'b0)
            px <=0;
        else if (rd_en == 1'b0)
            px <=0;
        else
            px <= px + 1;   
    end

    //rgb_data and rgb
    assign rgb = rgb_data;

endmodule


module display_buffer(
    input               pixel_clk,
    input               rst_n,
    input               rd_en,
    input       [15:0]  px,
    output  reg [23:0]  rgb_data
);
    parameter HDATA_T = 800;
    localparam section_0 = HDATA_T/4;
    localparam section_1 = 2*HDATA_T/4;
    localparam section_2 = 3*HDATA_T/4;
    localparam section_3 = 4*HDATA_T/4;
    
    //initial ram
    reg [23:0] mem [0:HDATA_T-1];

    integer i;
    always @(posedge pixel_clk or negedge rst_n) begin
        if (!rst_n) begin
            for(i=0;i<section_0;i=i+1)
                mem[i] <= 24'hFF0000; //red
            for(i=section_0;i<section_1;i=i+1)
                mem[i] <= 24'h00FF00; //green
            for(i=section_1;i<section_2;i=i+1)
                mem[i] <= 24'h0000FF; //blue
            for(i=section_2;i<section_3;i=i+1)
                mem[i] <= 24'hE6B800; //yellow
       end
    end

    //ram read
    always @(posedge pixel_clk or negedge rst_n) begin
        if (!rst_n)
            rgb_data <=0;
        else if (rd_en == 1'b1)
            rgb_data <=mem[px];
        else
            rgb_data <=rgb_data;
    end

endmodule