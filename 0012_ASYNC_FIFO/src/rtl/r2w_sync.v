module r2w_sync # (
    parameter RD_ADDRW = 32'd5
)
(
    input   [RD_ADDRW : 0]  rptr            ,
    input                   wclk            ,
    input                   rclk            ,
    output  [RD_ADDRW : 0]  r2wsync_rptr     
);


assign r2wsync_rptr = rptr;


endmodule