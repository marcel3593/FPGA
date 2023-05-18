module full_logic #(
    parameter RD_ADDRW = 32'd5,
    parameter WR_ADDRW = 32'd5      
)
(
    input   [WR_ADDRW : 0]  r2wsync_rptr    ,
    input   [RD_ADDRW : 0]  wptr            ,
    output                  full      
);

wire [WR_ADDRW - 1 : 0] wr_addr_ram;
wire [RD_ADDRW - 1 : 0] rd_addr_ram;
wire wptr_cb;
wire rptr_cb;

assign wr_addr_ram = wptr[WR_ADDRW - 1 : 0];
assign rd_addr_ram = r2wsync_rptr[RD_ADDRW - 1 : 0];
assign wptr_cb = wptr[WR_ADDRW];
assign rptr_cb = r2wsync_rptr[RD_ADDRW];

assign full = ( wr_addr_ram == rd_addr_ram && wptr_cb == rptr_cb ) ? 1'b1 : 1'b0;

endmodule