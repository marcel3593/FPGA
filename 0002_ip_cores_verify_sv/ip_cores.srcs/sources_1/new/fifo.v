module fifo(
input                   wr_clk          ,                 
input                   rd_clk          ,                 
input       [7:0]       din             ,              
input                   wr_en           ,                
input                   rd_en           ,                
output      [3:0]       dout            ,               
output                  full            ,               
output                  empty           ,
output                  wr_ack          ,
output                  overflow          
);




dfifo_1 dfifo_inst_0 (
  .wr_clk(wr_clk),  // input wire wr_clk
  .rd_clk(rd_clk),  // input wire rd_clk
  .din(din),        // input wire [7 : 0] din
  .wr_en(wr_en),    // input wire wr_en
  .rd_en(rd_en),    // input wire rd_en
  .dout(dout),      // output wire [3 : 0] dout
  .full(full),      // output wire full
  .empty(empty),    // output wire empty
  .wr_ack(wr_ack),      // output wire wr_ack
  .overflow(overflow)  // output wire overflow
);




endmodule