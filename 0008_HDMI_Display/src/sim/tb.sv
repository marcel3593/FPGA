`timescale 1ns/1ps


module tb();
    logic           sys_clk         ;
    logic           sys_rst_n       ;
    logic           tmds_data_0_p   ;
    logic           tmds_data_0_n   ;
    logic           tmds_data_1_p   ;
    logic           tmds_data_1_n   ;
    logic           tmds_data_2_p   ;
    logic           tmds_data_2_n   ;
    logic           tmds_clk_p      ;
    logic           tmds_clk_n      ;
    initial begin    
        sys_rst_n <=0;
        #30 sys_rst_n <=1;
    end
    
    initial begin
        sys_clk <= 1;
        forever #10 sys_clk<=~sys_clk;
    end

    top  dut(
      .sys_clk         (sys_clk      )     ,
      .sys_rst_n       (sys_rst_n    )     ,  
      .tmds_data_0_p   (tmds_data_0_p)     ,
      .tmds_data_0_n   (tmds_data_0_n)     ,
      .tmds_data_1_p   (tmds_data_1_p)     ,
      .tmds_data_1_n   (tmds_data_1_n)     ,
      .tmds_data_2_p   (tmds_data_2_p)     ,
      .tmds_data_2_n   (tmds_data_2_n)     ,
      .tmds_clk_p      (tmds_clk_p   )     ,
      .tmds_clk_n      (tmds_clk_n   )
    );

endmodule 