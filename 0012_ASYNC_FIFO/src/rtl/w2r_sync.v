module w2r_sync # (
    parameter WR_ADDRW = 32'd5
)
(
    input   [WR_ADDRW : 0]  wptr         ,
    input                   wclk         ,
    input                   rclk         ,
    output  [WR_ADDRW : 0]  w2rsync_wptr 
);


assign w2rsync_wptr = wptr;

endmodule