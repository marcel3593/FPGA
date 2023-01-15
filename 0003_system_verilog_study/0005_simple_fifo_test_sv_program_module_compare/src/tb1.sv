`timescale 1ns/1ps

interface read_interface(input clk, input rst_n);
    logic rd_en;
    logic [7:0] dout;
    clocking drv_ck @(posedge clk);
        default input #1ns output #1ns;
        input dout;
        output rd_en;
    endclocking

    clocking mon_ck @(posedge clk);
        default input #1ns output #1ns;
        input dout, rd_en;
    endclocking

endinterface //read_interface

interface write_interface(input clk, input rst_n);
    logic wr_en;
    logic [7:0] din;
    clocking drv_ck @(posedge clk);
        default input #1ns output #1ns;
        output wr_en, din;
    endclocking

    clocking mon_ck @(posedge clk);
        default input #1ns output #1ns;
        input wr_en, din;
    endclocking
endinterface //read_interface


module tb1();

logic clk = 0 ;
logic rst_n = 0;
logic wr_en;
logic [7:0] din_data;
logic rd_en_next;
logic rd_en_next_next;
logic [7:0] dout_data;

import rpt_pkg::*;
import simple_pkg::*;

//##################
//useinterface
//##################

//clk
initial begin
    forever #5 clk <= !clk;
end

//rst
initial begin
    #15 rst_n <=1;
end

read_interface rd_if(clk, rst_n);
write_interface wr_if(clk, rst_n);

    sp_fifo dut_1(
        .clk    (clk   )    ,               
        .rst_n  (rst_n )    ,                 
        .wr_en  (wr_if.wr_en )    ,                 
        .din    (wr_if.din   )    ,               
        .rd_en  (rd_if.rd_en )    ,                 
        .dout   (rd_if.dout)
    );

assign  rd_en_next = sample::rd_en_next_1; 
assign  rd_en_next_next = sample::rd_en_next_2; 
assign  dout_data = sample::dout_data; 
assign  din_data = sample::din_data; 

dsample sp1(rd_if,wr_if);

endmodule

program dsample(read_interface rd_if, write_interface wr_if);

  //read_interface rd_if(clk, rst_n);
  //write_interface wr_if(clk, rst_n);
  import simple_pkg::*;
  initial begin
    sample sp;
    sp=new();
    sp.set_interface(rd_if, wr_if);
    sp.run();
  end

endprogram
