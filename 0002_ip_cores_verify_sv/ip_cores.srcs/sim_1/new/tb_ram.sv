`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/03 15:15:05
// Design Name: 
// Module Name: tb_ram
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


module tb_ram();


logic         clka         ;
logic         ena          ;
logic         sys_rst_n    ;
logic         wea          ;
logic [7:0]   addra        ;
logic [7:0]   dina_t       ;
logic [7:0]   dina         ;
logic [7:0]   douta        ;
logic         data_invert  ;
logic [2:0]   loop_count   ;
 
initial begin
    clka = 1'b1;
    sys_rst_n <= 1'b0;
    #20
    sys_rst_n <=1'b1;
end

always #10 clka = ~clka;


//enable always enable it 
always @(posedge clka or negedge sys_rst_n) begin
    if (!sys_rst_n) 
        ena <= 1'b1;
    else
        ena <= 1'b1;
end


//loop count
always @(posedge clka or negedge sys_rst_n) begin
    if (!sys_rst_n)
        loop_count <=0;
    else if (addra == 8'd255)
        loop_count <= loop_count + 1;
    else
        loop_count <= loop_count;
end


//addr
always @(posedge clka or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        addra <= 8'd0;
        wea   <= 1'd1;
        dina_t <=0;
    end
    else if (addra == 8'd255) begin
        addra <= 8'd0;
        wea <= ~wea;
        dina_t <=0;
    end
    else begin
        addra <= addra + 1'b1;
        wea <= wea;
        dina_t <= dina_t + 1;
    end
end

assign data_invert = loop_count/2;  
assign dina = data_invert ? 255 - dina_t : dina_t;

//

ram ram_inst(
    .clka    (clka  )       , 
    .ena     (ena   )       , 
    .wea     (wea   )       , 
    .addra   (addra )       ,     
    .dina    (dina  )       ,     
    .douta   (douta )       
    );


endmodule