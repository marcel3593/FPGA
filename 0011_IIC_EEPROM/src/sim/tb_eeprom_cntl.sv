`timescale  1ns/10ps

interface eeprom_cntl_interface(input sys_clk, input sys_rst_n);
    logic [1:0] cmd    ;      
    wire  [7:0] data   ;
    logic buffer_rd_en ;
    logic buffer_reset ;
    logic buffer_wr_en ;
    logic buffer_empty ;
    logic buffer_full  ;
    logic error        ;
    logic busy         ;
    clocking drv_ck @(posedge sys_clk);
        default input #1ns output #1ns;
        input buffer_empty, buffer_full, error ,busy;
        output cmd, data, buffer_rd_en, buffer_wr_en,buffer_reset;
    endclocking
    
    clocking mon_ck @(posedge sys_clk);
        default input #1ns output #1ns;
        input buffer_empty, buffer_full, error ,busy,cmd, data, buffer_rd_en, buffer_wr_en,buffer_reset;
    endclocking
endinterface

interface iic_bus_interface();
    logic scl          ;
    wire sda           ;
    clocking mon_ck @(posedge scl);
        default input #1 output #1;
        input sda;
    endclocking
    assign (weak0, weak1) sda = 1'b1;
endinterface

module tb_eeprom_cntl ();

logic sys_clk      ;
logic sys_rst_n    ;

eeprom_cntl_interface cntl_if(sys_clk, sys_rst_n);
iic_bus_interface iic_bus_if();

initial begin
    sys_clk =0;
    sys_rst_n =0;
    #25 sys_rst_n <=1;
end

initial begin
    forever begin
        #10 sys_clk <= ~ sys_clk;
    end
end

//import rpt_pkg::*;
//import test_pkg::*;
//
//initial begin
//    base_test b_test;
//    b_test = new();
//    b_test.set_interface(cntl_if);
//    rpt_pkg::clean_log();
//    b_test.run();
//end

run_test rt(cntl_if);

eeprom_cntl dut(
  .sys_clk      (sys_clk      ),  
  .sys_rst_n    (sys_rst_n    ),  
  .cmd          (cntl_if.cmd          ),
  .data         (cntl_if.data         ),
  .buffer_reset (cntl_if.buffer_reset ),
  .buffer_rd_en (cntl_if.buffer_rd_en ),  
  .buffer_wr_en (cntl_if.buffer_wr_en ),  
  .buffer_empty (cntl_if.buffer_empty ),
  .buffer_full  (cntl_if.buffer_full  ),
  .error        (cntl_if.error        ),
  .busy         (cntl_if.busy         ),
  .scl          (iic_bus_if.scl       ),
  .sda          (iic_bus_if.sda       )    
);

AT24C64D model_eeprom(
    .SCL(iic_bus_if.scl),
    .SDA(iic_bus_if.sda),
    .WP ('Z)
);


endmodule

program run_test(eeprom_cntl_interface cntl_if);


import rpt_pkg::*;
import test_pkg::*;

initial begin
    base_test b_test;
    b_test = new();
    b_test.set_interface(cntl_if);
    rpt_pkg::clean_log();
    b_test.run();
end

endprogram