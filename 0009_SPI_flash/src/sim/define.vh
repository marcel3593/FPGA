//controller cmd table
`define C_NOP  4'b0000  //no action
`define C_SE   4'b0001  //sector erase 
`define C_PP   4'b0010  //page program
`define C_RD   4'b0100  //read
`define C_LD   4'b1000  //load_data  
// flash cmd table
`define WE  8'h06
`define SE  8'h20
`define PP  8'h02
`define RD  8'h03

`define ADDR_W  8'd3