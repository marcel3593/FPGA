`timescale  1ns/1ns

`include "define.vh"

interface cntl_inf (input sys_clk, input sys_rst_n);
  logic   [3:0]     cmd        ;
  logic   [31:0]    addr       ;
  wire    [7:0]     data       ; 
  logic             valid      ; 
  logic             busy       ;
  
  clocking drv_ck @(posedge sys_clk);
    default input #1ns output #1ns; 
    output cmd,addr,data;
    input  valid,busy;
  endclocking

  clocking mon_ck @(posedge sys_clk);
    default input #1ns output #1ns; 
    input  valid,busy,cmd, addr, data;
  endclocking

endinterface

interface spi_inf (input sys_clk, input sys_rst_n);
  wire             mosi       ;
  wire             miso       ;
  wire             wp_n       ;
  wire             hold_n     ;
  logic            sck        ;
  logic            cs_n       ;
  
  clocking mon_ck @(posedge sys_clk);
    default input #1ns output #1ns;
    input mosi, miso, sck, cs_n;
  endclocking

  clocking drv_ck @(posedge sys_clk);
    default input #1ns output #1ns;
    input mosi, miso, sck, cs_n;
    output wp_n,hold_n;
  endclocking

endinterface

module tb_spi_flash_controller();

  logic sys_clk;
  logic sys_rst_n;

  //logic dout;
  //logic din;
//
  //assign data = (valid == 1'b0) ? dout : 'Z;
  //assign din = data;

  initial begin
      sys_rst_n <=0;
      #1010 sys_rst_n <=1;
  end

  initial begin
      sys_clk <=1;
      forever begin
          #10 sys_clk = ~sys_clk;
      end
  end



  cntl_inf c_inf(sys_clk, sys_rst_n);
  spi_inf s_inf(sys_clk, sys_rst_n);


  initial begin
    @(posedge sys_rst_n);
    s_inf.drv_ck.wp_n <=1;
    s_inf.drv_ck.hold_n <=1;
  end

  SPI_flash_controller dut(
    .sys_clk   (sys_clk  )  ,
    .sys_rst_n (sys_rst_n)  ,
    .mosi      (s_inf.mosi     )  ,
    .miso      (s_inf.miso     )  ,
    .sck       (s_inf.sck      )  ,
    .cs_n      (s_inf.cs_n     )  ,
    .cmd       (c_inf.cmd      )  ,
    .addr      (c_inf.addr     )  ,
    .data      (c_inf.data     )  , 
    .valid     (c_inf.valid    )  , 
    .busy      (c_inf.busy     ) 
  );

  W25Q128JVxIM u_spi_flash(
  .CSn    (s_inf.cs_n  )     ,          
  .CLK    (s_inf.sck   )     ,
  .DIO    (s_inf.mosi  )     ,
  .WPn    (s_inf.wp_n  )     ,
  .HOLDn  (s_inf.hold_n)     ,
  .DO     (s_inf.miso  )    
  );

  initial begin
    import rpt_pkg::*; 
    import test_pkg::*;
    base_test b_test;
    b_test = new();
    b_test.set_interface(c_inf, s_inf);
    rpt_pkg::clean_log();
    b_test.run();
  end


endmodule