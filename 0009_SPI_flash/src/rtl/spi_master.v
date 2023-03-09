`include "reg_def.vh"

module SPI_master(
  input                     sys_clk,
  input                     sys_rst_n,
  input         [1:0]       spi_reg_addr,
  inout         [7:0]       spi_reg_data,
  input         [1:0]       spi_reg_cmd,
  output        [1:0]       spi_status,
  input                     spi_en,
  output  reg               mosi,
  input                     miso,
  output  reg               sck,
  output  reg               cs_n 
);


//==================
//   spi registers
//==================

reg [3:0] sck_cnt;
wire [7:0] reg_data_out;
wire [7:0] reg_data_in;
reg [7:0] spi_regs [0:3];
wire  tx_en;
wire  rx_en;
//reg   tx_en_reg;
//wire  tx_en_pulse;
reg   [3:0] tx_byte_cnt;
reg   [7:0] tx_shift_reg;
reg   [3:0] rx_byte_cnt;

assign spi_reg_data = (spi_reg_cmd == 2'b10 ) ? reg_data_out : 'Z;
assign reg_data_in  =  spi_reg_data;
assign reg_data_out = spi_regs[spi_reg_addr];
assign spi_status[0] = spi_regs[`SPI_STATUS][`SPI_STATUS_SPIF__SHIFT];
assign spi_status[1] = spi_regs[`SPI_STATUS][`SPI_STATUS_SPTEF__SHIFT];
assign rx_en = (~spi_regs[`SPI_STATUS][`SPI_STATUS_SPIF__SHIFT] ) &  spi_regs[`SPI_CNTL][`SPI_CNTL_SPIE__SHIFT];


always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        spi_regs[`SPI_CNTL]       <=   `SPI_CNTL_INIT      ;
        spi_regs[`SPI_STATUS]     <=   `SPI_STATUS_INIT    ;
        spi_regs[`SPI_READ_DATA]  <=   `SPI_READ_DATA_INIT ;
        spi_regs[`SPI_WRITE_DATA] <=   `SPI_WRITE_DATA_INIT;
    end
    else if (spi_reg_cmd == 2'b01 && spi_reg_addr == `SPI_WRITE_DATA && spi_regs[`SPI_STATUS][`SPI_STATUS_SPTEF__SHIFT] == 1'b1) begin //write SPI_WRITE_DATA and unset the SPI_STATUS_SPTEF 
        spi_regs[`SPI_STATUS][`SPI_STATUS_SPTEF__SHIFT] <= 0;
        spi_regs[spi_reg_addr] <= reg_data_in;
    end
    else if (spi_reg_cmd == 2'b01 && spi_reg_addr != `SPI_STATUS)          //general write regs; SPI_STATUS read only
        spi_regs[spi_reg_addr] <= reg_data_in;
    else if (spi_reg_cmd == 2'b10 && spi_reg_addr == `SPI_READ_DATA) begin  //read SPI_READ_DATA and unset the SPI_STATUS_SPIF
        spi_regs[`SPI_STATUS][`SPI_STATUS_SPIF__SHIFT] <= 0;
    end
    else if (tx_byte_cnt == 4'd7 && sck_cnt == 4'd2)             //set SPI_STATUS_SPTEF
        spi_regs[`SPI_STATUS][`SPI_STATUS_SPTEF__SHIFT] <= 1;
    else if (rx_byte_cnt == 4'd7 && sck_cnt == 4'd0)
        spi_regs[`SPI_STATUS][`SPI_STATUS_SPIF__SHIFT] <= 1;   //set SPI_STATUS_SPIF
    else;
end

//==================
//   sck and cs_n
//==================

//cs_n
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)
        cs_n <=1;
    else if ( (spi_en == 1'b1) && ( rx_en == 1'b1 ||  tx_en == 1'b1) && (sck_cnt == 4'd2) ) //always poll low in negtive edge ot meet tSLCH
        cs_n <=0;
    else if (spi_en == 1'b0 && sck_cnt == 4'd2) ////always poll low in negtive edge to meet tCHSH
        cs_n <=1;
    else
        cs_n <= cs_n;
end

//sck


always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)
        sck_cnt <=0;
    else if ( sck_cnt == 4'd3 )
        sck_cnt <= 0;
    else
        sck_cnt <= sck_cnt + 1; 
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)
        sck <=0;
    else if ( (sck_cnt == 4'd2 || sck_cnt == 4'd0) && (cs_n == 1'b0 ))
        sck <= ~sck;
    else
        sck <= sck; 
end


//==================
//   tx
//==================



assign tx_en = (~spi_regs[`SPI_STATUS][`SPI_STATUS_SPTEF__SHIFT] ) &  spi_regs[`SPI_CNTL][`SPI_CNTL_SPTE__SHIFT];

//tx_byte_cnt
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        tx_byte_cnt  <= 0;
    end
    else if (spi_en == 1'b0)
        tx_byte_cnt  <= 0;
    else if (tx_en == 1'b1 && sck_cnt == 4'd2 && tx_byte_cnt == 8'd7) begin
        tx_byte_cnt <=0;
    end
    else if (tx_en == 1'b1 && sck_cnt == 4'd2) begin
        tx_byte_cnt <= tx_byte_cnt + 1;
    end
    else begin
        tx_byte_cnt <= tx_byte_cnt;
    end
end

//tx_shift_reg
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        tx_shift_reg <= 0;
    end
    else if (spi_reg_cmd == 2'b01 && spi_reg_addr == `SPI_WRITE_DATA && spi_regs[`SPI_STATUS][`SPI_STATUS_SPTEF__SHIFT] == 1'b1) 
        tx_shift_reg <= reg_data_in;
    else if (tx_en == 1'b1 && sck_cnt == 4'd2) begin
        tx_shift_reg <= (tx_shift_reg << 1 ); 
    end
    else begin
        tx_shift_reg <= tx_shift_reg;
    end
end

//mosi
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)
        mosi <=0;
    else if (tx_en == 1'b1 && sck_cnt == 4'd2)
        mosi <= tx_shift_reg[7];
    else
        mosi <= mosi;
end

//==================
//   rx
//==================


//rx_shift_reg
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        spi_regs[`SPI_READ_DATA] <= 0;
        rx_byte_cnt <=0;
    end
    else if (spi_en == 1'b0) begin
        spi_regs[`SPI_READ_DATA]  <= spi_regs[`SPI_READ_DATA];
        rx_byte_cnt <=0;
    end
    else if (rx_en == 1'b1 && sck_cnt == 4'd0 && rx_byte_cnt == 8'd7) begin //rise edge 
        spi_regs[`SPI_READ_DATA] <= {spi_regs[`SPI_READ_DATA][6:0], miso};
        rx_byte_cnt <= 0;
    end
    else if (rx_en == 1'b1 && sck_cnt == 4'd0) begin //rise edge 
        spi_regs[`SPI_READ_DATA] <= {spi_regs[`SPI_READ_DATA][6:0], miso};
        rx_byte_cnt <= rx_byte_cnt + 1;
    end
    else begin
        spi_regs[`SPI_READ_DATA]  <= spi_regs[`SPI_READ_DATA];
        rx_byte_cnt <= rx_byte_cnt;
    end
end


endmodule
