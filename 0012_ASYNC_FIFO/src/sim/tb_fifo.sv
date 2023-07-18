`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: shao, yingjie
// 
// Create Date: 2023/05/08 13:18:35
// Design Name: async_fifo
// Module Name: tb_fifo
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


interface read_intf(input rd_clk, input rst_n);
    logic [7:0] dout;
    logic       rd_en;
    logic       empt;
    
    clocking drv_ck @(posedge rd_clk);
        default input #1ns output #1ns;
        output rd_en;
        input dout, empt;
    endclocking

    clocking mon_ck @(posedge rd_clk);
        default input #1ns output #1ns;
        input  rd_en, dout, empt; 
    endclocking

endinterface //interfacename

interface write_intf(input wr_clk, input rst_n);
    logic [7:0] din;
    logic       wr_en;
    logic       full;
    
    clocking drv_ck @(posedge wr_clk);
        default input #1ns output #1ns;
        output wr_en, din;
        input full;
    endclocking

    clocking mon_ck @(posedge wr_clk);
        default input #1ns output #1ns;
        input  wr_en, din, full;
    endclocking
    
endinterface //interfacename


module tb_fifo();    


    logic wr_clk;
    logic rd_clk;
    logic rst_n;

    read_intf rd_if(rd_clk, rst_n);
    write_intf wr_if(wr_clk, rst_n);

    top_asfifo #(
        .DEPTH (32'd32),
        .WR_DW (32'd8 ), 
        .RD_DW (32'd8 )
    )
    dut
    (
        .wclk   (wr_clk)      ,
        .rclk   (rd_clk)      ,
        .rst_n  (rst_n)       ,
        .wr_en  (wr_if.wr_en) ,
        .rd_en  (rd_if.rd_en) ,
        .din    (wr_if.din)   ,
        .dout   (rd_if.dout)  ,
        .empty  (rd_if.empt)  ,
        .full   (wr_if.full)    
    );

    initial begin
        wr_clk =0;
        forever begin
            #10 wr_clk <= ~wr_clk;
        end
    end

    initial begin
        rst_n = 0;
        #25 rst_n <=1;
    end

    assign rd_clk = wr_clk;  //sync fifo to start with

    run_test rt(rd_if, wr_if);

endmodule



program run_test(read_intf rd_if, write_intf wr_if);
   
    import access_pkg::*;
    import rpt_pkg::*;
    import checker_pkg::*;
    import test_pkg::*;
   
    base_test tests[string];
    read_write_test rd_wr_test;
    read_busy_test rd_busy_test;
    write_busy_test wr_busy_test;
    base_test b_test;
    string name;
    string s;

    initial begin
        rd_wr_test = new();
        rd_busy_test = new();
        wr_busy_test = new();
        tests["read_write_test"] = rd_wr_test;
        tests["read_busy_test"] = rd_busy_test;
        tests["write_busy_test"] = wr_busy_test;
        if($value$plusargs("TESTNAME=%s", name)) begin
            if(tests.exists(name))begin
                s = $sformatf("run test TESTNAME=%s",name);
                $display(s);
                rpt_pkg::rpt_msg("[msg]", s, rpt_pkg::INFO, rpt_pkg::MEDIUM);
                tests[name].set_interface(rd_if, wr_if);
                tests[name].connect_mailbox();
                tests[name].do_config();
                tests[name].run();                
            end
            else 
                $fatal("[ERRTEST], test name %s is invalid, please specify a valid name!", name);
        end
        else begin
            $display("NO runtime optiont +TESTNAME=xxx is configured, and run default test base test");
            b_test=new();
            b_test.set_interface(rd_if, wr_if);
            b_test.connect_mailbox();
            b_test.do_config();
            b_test.run();
        end
    end

endprogram