module rom(
    input           clka          ,
    input           ena           , 
    input  [7:0]    addra         ,
    output [7:0]    douta
    );


rom_8x256 rom_8_256_inst_0 (
  .clka(clka),    // input wire clka
  .ena(ena),      // input wire ena
  .addra(addra),  // input wire [7 : 0] addra
  .douta(douta)  // output wire [7 : 0] douta
);

endmodule
