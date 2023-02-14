`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/03 13:52:05
// Design Name: 
// Module Name: tb_rom
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_rom();


reg             clka         ;
reg             ena          ;
reg             sys_rst_n    ;
reg     [7:0]   addra        ;
wire    [7:0]   douta        ;

initial begin
    clka = 1'b1;
    sys_rst_n <= 1'b0;
    #20
    sys_rst_n <=1'b1;
end

always #10 clka = ~clka;

always @(posedge clka or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        addra <= 8'd0;
        ena <= 1'b0;
    end
    else if (addra == 8'd255) begin
        addra <= 8'd0;
        ena <= 1'b1;
    end
    else begin
        addra <= addra + 1'b1;
        ena <= 1'b1;
    end
end


rom rom_inst(
    .clka   (clka )      ,
    .ena    (ena  )      , 
    .addra  (addra)      ,
    .douta  (douta)       
    );


endmodule