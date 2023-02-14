`include "parameters_def.v"

module uart_top (
  input                                 clk     ,
  input                                 rst_n   ,
  input                                 rx      ,
  output                                tx      
);

wire  [`BYTE_SIZE - 1 : 0] rx_data;
wire  [`BYTE_SIZE - 1 : 0] tx_data;
wire valid;
wire parity_error;
wire rx_busy;
wire wr_en;
wire tx_busy;
wire [3:0] rd_addr;
wire [3:0] wr_addr;

`ifndef SIM
ila_0 u4_ila (
	.clk(clk), // input wire clk
	.probe0(clk), // input wire [3:0]  probe0  
	.probe1(rd_addr), // input wire [3:0]  probe0  
	.probe2(wr_addr), // input wire [3:0]  probe1
    .probe3(rx_busy),
    .probe4(tx_busy),
    .probe5(rx),
    .probe6(tx)
);
`endif

uart_tx u1_uart_tx(
  .clk     (clk    ),
  .rst_n   (rst_n  ),
  .din     (tx_data),
  .wr_en   (wr_en  ),
  .tx      (tx     ),
  .tx_busy (tx_busy)    
);

uart_rx u2_uart_rx(
  .clk          (clk         ) ,
  .rst_n        (rst_n       ) ,
  .rx           (rx          ) ,
  .dout         (rx_data     ) ,
  .valid        (valid       ) ,
  .parity_error (parity_error) ,                          
  .rx_busy      (rx_busy     )               
);

uart_control u3_uart_control(
  .clk          (clk         ) ,
  .rst_n        (rst_n       ) ,
  .rx_data      (rx_data     ) ,
  .valid        (valid       ) ,
  .parity_error (parity_error) ,                          
  .rx_busy      (rx_busy     ) , 
  .tx_busy      (tx_busy     ) ,
  .tx_data      (tx_data     ) ,
  .wr_en        (wr_en       ) , 
  .rd_addr      (rd_addr     ) ,
  .wr_addr      (wr_addr     ) 
);
endmodule

module uart_tx(
  input                                 clk     ,
  input                                 rst_n   ,
  input           [`BYTE_SIZE - 1 : 0]  din     ,
  input                                 wr_en   ,
  output   reg                          tx      ,
  output   wire                         tx_busy     
);

reg [`BYTE_SIZE : 0] data;  //include parity
reg tx_en;
reg [15:0] baud_cnt;
reg [4:0] bit_cnt;
wire parity_flag;  //0: cnt of 1s is even, 1: cnt of 1s is odd
wire parity_bit;

assign parity_flag = ^din;  //0: even, 1: odd
assign parity_bit = `PARITY_TYPE ? ( ~ parity_flag) : (parity_flag);

assign tx_busy = tx_en;

//data
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        data <= 0;
    else if (wr_en == 1'b1)
        data <= {parity_bit, din};
    else
        data <= data;    
end

//tx_en
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        tx_en <=0;
    else if (wr_en == 1'b1)
        tx_en <=1;
    else if (baud_cnt == `BAUD_CNT_MAX && bit_cnt == `BIT_CNT_MAX_PLUS_ONE)
        tx_en <=0;
    else
        tx_en <= tx_en;
end

//baud cnt
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        baud_cnt <=0;
    else if (baud_cnt == `BAUD_CNT_MAX)
        baud_cnt <= 0;
    else if (tx_en == 1'b1)
        baud_cnt <= baud_cnt + 1;
    else
        baud_cnt <= 0;
end

//bit_cnt
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        bit_cnt <=0;
    else if ( tx_en == 1'b0)
        bit_cnt <= 0;
    else if (tx_en == 1'b1 &&  baud_cnt == 0)
        bit_cnt <= bit_cnt + 1;
    else
        bit_cnt <= bit_cnt;        
end

//tx
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        tx <=1'b1;
    else if (tx_en == 1'b1 &&  baud_cnt == 0)
        case (bit_cnt)
            0: tx <=0; //start
            `BIT_CNT_MAX : tx<=1; //stop
            default: tx <= data[bit_cnt - 1]; //data and parity
        endcase
    else
        tx <= tx;
end
endmodule 


module  uart_rx (
  input                                 clk          ,
  input                                 rst_n        ,
  input                                 rx           ,
  output        [`BYTE_SIZE-1: 0]       dout         ,
  output   reg                          valid        ,
  output                                parity_error ,                          
  output                                rx_busy                                
);

reg rx_reg;
reg rx_reg1;
reg rx_reg2;
reg rx_reg3;
reg rx_reg4;

reg rx_en;
reg [15:0] baud_cnt;
wire sample_en;
reg [4:0] bit_cnt;
reg [`BYTE_SIZE: 0] data; //including parity
wire parity;

assign dout[`BYTE_SIZE-1: 0] = `PARITY ? data[`BYTE_SIZE-1: 0] : data[`BYTE_SIZE: 1];
assign parity = ^data;
assign parity_error = `PARITY ? (`PARITY_TYPE ?  ~parity : parity) : 0;
assign rx_busy = rx_en;
assign sample_en = (baud_cnt == `BAUD_CNT_CENTER) && rx_en;

//repeaters
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rx_reg  <=  1;
        rx_reg1 <=  1;
        rx_reg2 <=  1;
        rx_reg3 <=  1;
        rx_reg4 <=  1;
    end
    else begin
        rx_reg  <= rx;
        rx_reg1 <= rx_reg;
        rx_reg2 <= rx_reg1;
        rx_reg3 <= rx_reg2;
        rx_reg4 <= rx_reg3;        
    end
end

//rx_en
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        rx_en <= 0 ;
    else if (rx_reg3 == 1'b0 && rx_reg4 == 1'b1 && rx_en == 1'b0) //falling edge when rx_en not enabled
        rx_en <=1 ;
    else if (baud_cnt == `BAUD_CNT_MAX && bit_cnt == `BIT_CNT_MAX)
        rx_en <=0 ;
    else
        rx_en <= rx_en;
end

//baud_cnt
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        baud_cnt <=0;
    else if (baud_cnt == `BAUD_CNT_MAX)
        baud_cnt <=0;
    else if (rx_en == 1'b1)
        baud_cnt <= baud_cnt + 1;
    else
        baud_cnt <= baud_cnt;
end

//bit
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        bit_cnt <= 0;
    else if (rx_en == 1'b0 )
        bit_cnt <= 0;
    else if (sample_en == 1'b1)
        bit_cnt <= bit_cnt + 1;
    else
        bit_cnt <= bit_cnt;
end


//data
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        data <= 0;
    else if (sample_en == 1'b1 && bit_cnt > 0 && bit_cnt <= `RX_BIT_CNT_MAX)
        data <= {rx_reg4, data[`BYTE_SIZE:1]};
    else
        data <= data;
end

//valid
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        valid <= 0;
    else if (bit_cnt == `RX_BIT_CNT_MAX && sample_en == 1'b1)
        valid <= 1;
    else
        valid <= 0;
end

endmodule


module uart_control(
  input                                 clk          ,
  input                                 rst_n        ,
  input        [`BYTE_SIZE-1: 0]        rx_data      ,
  input                                 valid        ,
  input                                 parity_error ,                          
  input                                 rx_busy      , 
  input                                 tx_busy      ,
  output  reg  [`BYTE_SIZE-1 : 0]       tx_data      ,
  output  reg                           wr_en        ,
  output  reg  [3:0]                    rd_addr      ,  
  output  reg  [3:0]                    wr_addr        
);

reg [`BYTE_SIZE:0] mem [0:15] ;
//reg [3:0] rd_addr;
//reg [3:0] wr_addr;
reg eo_cnt;


//mem
integer i;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        for (i=0;i<16;i=i+1)
            mem[i] <= 0;
    else if (valid == 1'b1)
            mem[rd_addr] <= {parity_error, rx_data};
    else;
end

//rd addr
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        rd_addr <= 0;
    else if (valid == 1'b1)
        rd_addr <= rd_addr + 1;
    else
        rd_addr <= rd_addr;
end


//even_odd_cnt
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        eo_cnt <= 0;
    else
        eo_cnt <= ~eo_cnt;
end

//write
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        wr_en <=0;
        tx_data <=0;
        wr_addr <= 0;
    end
    else if (tx_busy == 1'b0 && wr_addr != rd_addr && eo_cnt == 1'b1) begin
        wr_en <= 1;
        tx_data <= mem[wr_addr];
        wr_addr <= wr_addr + 1;
    end
    else begin
        wr_en <= 0;
        tx_data <= tx_data;
        wr_addr <= wr_addr;
    end
end

endmodule