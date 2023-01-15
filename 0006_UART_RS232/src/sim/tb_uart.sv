`timescale  1ns/1ps
`include "../rtl/parameters_def.v"



interface tx_interface(input clk, input rst_n);
    logic tx;
    clocking drv_ck @(posedge clk or negedge rst_n);
        default input #1ns output #1ns;
        output tx; 
    endclocking 

endinterface //interfacename


interface rx_interface(input clk, input rst_n);
    logic rx;
    clocking mon_ck @(posedge clk or negedge rst_n);
        default input #1ns output #1ns;
        input rx;
    endclocking
endinterface



module tb_uart();
    logic clk;
    logic rst_n;
    logic parity_error;

    assign parity_error = dut.parity_error && dut.valid;

    //initail clk and rst

    import uart_dv_pkg::*;

    initial begin
        clk = 0;
        forever #10 clk <=~clk;
    end

    initial begin
        rst_n = 0;
        #25 rst_n <=1;
    end
    

    always @(posedge clk) begin
        assert ( ~(rst_n && parity_error))
        else   rpt_pkg::rpt_msg("parity_error", $sformatf("find parity error !!"), rpt_pkg::ERROR, rpt_pkg::HIGH);
    end

    tx_interface tx_if(clk,rst_n);
    rx_interface rx_if(clk,rst_n);
   
    uart_top dut(
      .clk    (clk) ,
      .rst_n  (rst_n) ,
      .rx     (tx_if.tx) ,
      .tx     (rx_if.rx)         
    );


    initial begin
        basic_test b_test;
        b_test = new();
        $display("BAUD_RATE_BPS         %d",`BAUD_RATE_BPS       );           
        $display("CLK_MHZ               %d",`CLK_MHZ             );           
        $display("PARITY                %d",`PARITY              );           
        $display("PARITY_TYPE           %d",`PARITY_TYPE         );                 
        $display("STOP_SIZE             %d",`STOP_SIZE           );                  
        $display("BYTE_SIZE             %d",`BYTE_SIZE           );      
        $display("BAUD_CNT_MAX          %d",`BAUD_CNT_MAX        );                             
        $display("BAUD_CNT_CENTER       %d",`BAUD_CNT_CENTER     );                   
        $display("BIT_CNT_MAX           %d",`BIT_CNT_MAX         );               
        $display("BIT_CNT_MAX_PLUS_ONE  %d",`BIT_CNT_MAX_PLUS_ONE);                   
        $display("RX_BIT_CNT_MAX        %d",`RX_BIT_CNT_MAX      );               
        b_test.set_interface(rx_if, tx_if);
        b_test.run();
    end

endmodule