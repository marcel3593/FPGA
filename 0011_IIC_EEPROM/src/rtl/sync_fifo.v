module sync_fifo (
  input                sys_clk      ,  
  input                sys_rst_n    ,     
  input                reset        ,
  input                rd_en        ,
  input                wr_en        ,
  input         [7:0]  din          ,
  output        [7:0]  dout         ,
  output               empty        ,
  output               full         
);

parameter DEPTH  = 8'd32;
parameter ffft_en = 1'b1;

reg [7:0] mem [0:DEPTH-1];
reg [7:0] w_fifo_pointer ;
reg [7:0] r_fifo_pointer ;
reg w_fifo_pointer_cb;
reg r_fifo_pointer_cb;
reg [7:0] ffft_reg;  //first word fall through
reg [7:0] dout_reg;
integer  i;

assign full = ((w_fifo_pointer == r_fifo_pointer) && (w_fifo_pointer_cb == r_fifo_pointer_cb) ) ? 1:0;
assign empty = (w_fifo_pointer == r_fifo_pointer && w_fifo_pointer_cb != r_fifo_pointer_cb)? 1: 0;

//pointer control
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        w_fifo_pointer <=8'd0;
        w_fifo_pointer_cb <= 1'b1;
    end
    else if (reset == 1'b1) begin
        w_fifo_pointer <=8'd0;
        w_fifo_pointer_cb <= 1'b1;
    end
    else if (wr_en == 1'b1 && w_fifo_pointer == DEPTH-8'b1 && w_fifo_pointer_cb == 1'b1) begin
        w_fifo_pointer <=8'd0;
        w_fifo_pointer_cb <= 1'b0;
    end    
    else if (wr_en == 1'b1 && w_fifo_pointer == DEPTH-8'b1 && w_fifo_pointer_cb == 1'b0) begin
        w_fifo_pointer <=8'd0;
        w_fifo_pointer_cb <= 1'b1;
    end    
    else if (wr_en == 1'b1 && full == 1'b0)
        w_fifo_pointer <= w_fifo_pointer + 1'b1;
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        r_fifo_pointer <=8'd0;
        r_fifo_pointer_cb <= 1'b0;
    end
    else if (reset == 1'b1) begin
        r_fifo_pointer <=8'd0;
        r_fifo_pointer_cb <= 1'b0;
    end
    else if (rd_en == 1'b1 && r_fifo_pointer == DEPTH-8'b1 && r_fifo_pointer_cb == 1'b1) begin
        r_fifo_pointer <=8'd0;
        r_fifo_pointer_cb <= 1'b0;
    end    
    else if (rd_en == 1'b1 && r_fifo_pointer == DEPTH-8'b1 && r_fifo_pointer_cb == 1'b0) begin
        r_fifo_pointer <=8'd0;
        r_fifo_pointer_cb <= 1'b1;
    end    
    else if (rd_en == 1'b1 && empty == 1'b0)
        r_fifo_pointer <= r_fifo_pointer + 1'b1;
end

//write
always @(posedge sys_clk) begin
    //if (!sys_rst_n) begin
    //    for (i=0;i<DEPTH;i=i+1)
    //        mem[i] <=0;
    //end
    //else if (reset == 1'b1) begin
    //    for (i=0;i<DEPTH;i=i+1)
    //        mem[i] <=0;
    //end
    if (wr_en == 1'b1 && full == 1'b0 ) begin
        mem[w_fifo_pointer] <= din;
    end
end

//ffft logic
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) 
        ffft_reg <=0;
    else if (reset == 1'b1) 
        ffft_reg <=0;
    else if (wr_en == 1'b1 && empty == 1'b1) 
        ffft_reg <= din;
    else if (wr_en == 1'b1 && full == 1'b0)
        ffft_reg <= mem[r_fifo_pointer];
    else if (rd_en == 1'b1 && r_fifo_pointer == DEPTH-8'b1)
        ffft_reg <= mem[8'd0];
    else if (rd_en == 1'b1)
        ffft_reg <= mem[r_fifo_pointer + 8'b1];
end

//read 
assign dout = (ffft_en == 1'b1) ? ffft_reg : dout_reg;

always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) 
        dout_reg <=0;
    else if (reset == 1'b1) 
        dout_reg <=0;
    else if (rd_en == 1'b1 && empty == 1'b0) 
        dout_reg <= mem[r_fifo_pointer];
end  

endmodule