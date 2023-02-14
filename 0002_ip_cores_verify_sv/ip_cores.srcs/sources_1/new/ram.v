module ram(
    input           clka           , 
    input           ena            , 
    input           wea            , 
    input  [7:0]    addra          ,     
    input  [7:0]    dina           ,     
    output [7:0]    douta          
    );


s_ram_8x256 s_ram_8x256_inst_0 (
  .clka(clka),    // input wire clka
  .ena(ena),      // input wire ena
  .wea(wea),      // input wire [0 : 0] wea
  .addra(addra),  // input wire [7 : 0] addra
  .dina(dina),    // input wire [7 : 0] dina
  .douta(douta)  // output wire [7 : 0] douta
);


endmodule