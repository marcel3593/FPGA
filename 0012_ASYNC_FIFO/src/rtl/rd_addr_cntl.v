module rd_addr_cntl #(
    parameter RD_ADDRW = 32'd5
)
(
    input                          rclk        ,
    input                          rst_n       ,
    input                          empty       ,
    input                          rd_en       ,
    output  reg  [RD_ADDRW : 0 ]   rptr        ,
    output       [RD_ADDRW - 1: 0] r_addr_ram   
);


assign r_addr_ram = rptr[RD_ADDRW - 1 : 0];

always @(posedge rclk or negedge rst_n) begin
    if (!rst_n) 
        rptr <= {1'b0, {RD_ADDRW{1'b0}} };
    else if (empty == 1'b0 && rd_en == 1'b1) begin
        rptr <= rptr + 1'b1;
    end
end

endmodule