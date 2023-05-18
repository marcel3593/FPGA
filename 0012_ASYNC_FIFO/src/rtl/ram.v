module dualport_ram 
#(
    parameter DEPTH = 32'd32,
    parameter WR_DW = 32'd8 , 
    parameter RD_DW = 32'd8 ,
    parameter WR_ADDRW = 32'd5,
    parameter RD_ADDRW = 32'd5 )
(
    input                        wclk            ,
    input                        rst_n           ,
    input                        we              ,
    input   [WR_ADDRW - 1 : 0 ]  w_addr_ram      ,
    input   [RD_ADDRW - 1 : 0 ]  r_addr_ram      ,
    input   [WR_DW - 1 : 0 ]     din             ,
    output  [RD_DW - 1 : 0 ]     dout             
);

reg [WR_DW - 1 : 0] mem [0:DEPTH-1];
integer i;

always @(posedge wclk or negedge rst_n) begin
    if (!rst_n)
        for(i=0;i<DEPTH;i=i+1)
            mem[i] <= 0;
    else if (we == 1'b1)
        mem[w_addr_ram] <= din;
end

assign dout = mem[r_addr_ram];

endmodule