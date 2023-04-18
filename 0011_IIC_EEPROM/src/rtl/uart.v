`include "uart_parameters.vh"


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