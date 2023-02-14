`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/06 13:18:35
// Design Name: 
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


interface read_intf(input rd_clk);
    logic [3:0] dout;
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

interface write_intf(input wr_clk);
    logic [7:0] din;
    logic       wr_en;
    logic       full;
    logic       wr_ack;
    logic       overflow;
    
    clocking drv_ck @(posedge wr_clk);
        default input #1ns output #1ns;
        output wr_en, din;
        input full, wr_ack, overflow;
    endclocking

    clocking mon_ck @(posedge wr_clk);
        default input #1ns output #1ns;
        input  wr_en, din, full, wr_ack, overflow;
    endclocking
    
endinterface //interfacename


module tb_fifo();

    import access_pkg::*;
    import rpt_pkg::*;
    import checker_pkg::*;
    import test_pkg::*;

    logic wr_clk;
    logic rd_clk;

    logic rd_en_internal;
    logic [3:0] dout; 

    assign rd_en_internal = read_monitor::rd_en_next;
    assign dout = read_monitor::read_mon_data.data;

    read_intf rd_if(rd_clk);
    write_intf wr_if(wr_clk);


    fifo u_fifo_inst_0(
        .wr_clk       (wr_clk)          ,                 
        .rd_clk       (rd_clk)          ,                 
        .din          (wr_if.din)          ,              
        .wr_en        (wr_if.wr_en )          ,                
        .rd_en        (rd_if.rd_en )          ,                
        .dout         (rd_if.dout  )          ,               
        .full         (wr_if.full  )          ,               
        .empty         (rd_if.empt  )         ,
        .wr_ack        (wr_if.wr_ack  )       ,
        .overflow       (wr_if.overflow  )                          
    );

    initial begin
        wr_clk <=0;
        forever begin
            #10 wr_clk <= ~wr_clk;
        end
    end

    initial begin
        rd_clk <=0;
        //#3 rd_clk <=0;
        forever begin
            #5 rd_clk <= ~rd_clk;
        end
    end

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

endmodule
