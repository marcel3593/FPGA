module empty_logic #(
    parameter RD_ADDRW = 32'd5,
    parameter WR_ADDRW = 32'd5      
)
(
    input   [WR_ADDRW : 0]  w2rsync_wptr    ,
    input   [RD_ADDRW : 0]  rptr            ,
    output                  empty      
);

wire [WR_ADDRW - 1 : 0] wr_addr_ram;
wire [RD_ADDRW - 1 : 0] rd_addr_ram;
wire wptr_cb;
wire rptr_cb;

assign wr_addr_ram = w2rsync_wptr[WR_ADDRW - 1 : 0];
assign rd_addr_ram = rptr[RD_ADDRW - 1 : 0];
assign wptr_cb = w2rsync_wptr[WR_ADDRW];
assign rptr_cb = rptr[RD_ADDRW];

assign empty = ( wr_addr_ram == rd_addr_ram && wptr_cb != rptr_cb ) ? 1'b1 : 1'b0;

endmodule
