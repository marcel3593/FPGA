module wr_addr_cntl #(
    parameter WR_ADDRW = 32'd5
)
(
    input                          wclk        ,
    input                          rst_n       ,
    input                          full        ,
    input                          wr_en       ,
    output  reg  [WR_ADDRW : 0 ]   wptr        ,
    output                         we          ,
    output       [WR_ADDRW - 1: 0] w_addr_ram   
);


assign we = (full == 1'b0 && wr_en == 1'b1) ? 1'b1 : 1'b0;
assign w_addr_ram = wptr[WR_ADDRW - 1 : 0];

always @(posedge wclk or negedge rst_n) begin
    if (!rst_n) 
        wptr <= {1'b1, {WR_ADDRW{1'b0}} };
    else if (we == 1'b1) begin
        wptr <= wptr + 1'b1;
    end
end


endmodule