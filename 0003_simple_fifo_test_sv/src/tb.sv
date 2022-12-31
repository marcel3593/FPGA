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




module tb();


logic clk = 0 ;
logic rst_n = 0;
logic wr_en;
logic [7:0] din;
logic rd_en;
logic [7:0] dout;

//inst dut

sp_fifo dut(
    .clk    (clk   )    ,               
    .rst_n  (rst_n )    ,                 
    .wr_en  (wr_en )    ,                 
    .din    (din   )    ,               
    .rd_en  (rd_en )    ,                 
    .dout   (dout)
);

logic [0:15][7:0] wr_data;
logic rd_en_next;
logic [3:0] rd_addr_c;
logic [3:0] wr_addr_c;

assign rd_addr_c = dut.rd_addr_count;
assign wr_addr_c = dut.wr_addr_count;

//gen wrdata
initial begin
    foreach(wr_data[j]) begin
        wr_data[j] = j;
    end
end

import rpt_pkg::*;

//clk
initial begin
    forever #5 clk <= ~clk;
end

//rst
initial begin
    #15 rst_n <=1;
end

//write then read
initial begin
    write_driver();
    read_drive();
end


//monitor
initial begin
    rpt_pkg::clean_log();
    fork
        read_monitor();
        gen_rd_en_next();
        mon_all_signal();
    join
end

task write_driver();
    @(posedge clk iff rst_n === 1'b1);
    wr_en <= 0;
    din <= 0;
    foreach(wr_data[j]) begin
        @(posedge clk);
        wr_en <=1;
        din <= wr_data[j];
        //print_write_data(wr_en, din);
    end
    @(posedge clk);
    wr_en <=0;
    din <= 8'hff;
    //print_write_data(wr_en, din);
endtask

task read_drive();
    @(posedge clk iff rst_n === 1'b1);
    forever begin
        @(posedge clk);
            rd_en <= 1;
    end
endtask

task read_monitor();
    automatic int i = 0;
    @(posedge clk iff rst_n === 1'b1);
    forever begin
        @(posedge clk iff rd_en_next === 1'b1);
            //print_read_data(rd_en_next, dout);
            i = i + 1;
            if (i==16) begin
                #1step;
                //$stop();
            end
    end
endtask

task gen_rd_en_next();
    forever begin
        @(posedge clk);
            rd_en_next <= rd_en;
    end
endtask

task mon_all_signal();
    string s;
    forever begin
        @(posedge clk);
        s = $sformatf("wr_en = %d, din = %d, rd_en = %d, rd_en_next = %d, dout = %d, rd_addr= %d, wr_addr= %d\n", 
                            wr_en,      din,       rd_en,      rd_en_next,      dout,  rd_addr_c, wr_addr_c);
        rpt_pkg::rpt_msg("[all data]",s, rpt_pkg::INFO, rpt_pkg::LOW);
    end
endtask

function void print_read_data(logic rd_en_next, logic [7:0] dout);
    string s;
    s = $sformatf("rd_en_next = %d, read_data = %d",rd_en_next, dout);
    rpt_pkg::rpt_msg("[read data]",s, rpt_pkg::INFO, rpt_pkg::MEDIUM);
endfunction


function void print_write_data(logic wr_en, logic [7:0] din);
    string s;
    s = $sformatf("wr_en = %d, din = %d",wr_en, din);
    rpt_pkg::rpt_msg("[write data]",s, rpt_pkg::INFO, rpt_pkg::MEDIUM);
endfunction

//##################
//useinterface
//##################

read_interface rd_if(clk, rst_n);
write_interface wr_if(clk, rst_n);

logic rd_en_next_1;
logic [3:0] rd_addr_c_1;
logic [3:0] wr_addr_c_1;

sp_fifo dut_1(
    .clk    (clk   )    ,               
    .rst_n  (rst_n )    ,                 
    .wr_en  (wr_if.wr_en )    ,                 
    .din    (wr_if.din   )    ,               
    .rd_en  (rd_if.rd_en )    ,                 
    .dout   (rd_if.dout)
);


assign rd_addr_c_1 = dut_1.rd_addr_count;
assign wr_addr_c_1= dut_1.wr_addr_count;

//inital driver
initial begin
    write_driver_1();
    read_drive_1();
end

//monitor
initial begin
    //rpt_pkg::clean_log();
    fork
        read_monitor_1();
        gen_rd_en_next_1();
        mon_all_signal_1();
    join
end

task write_driver_1();
    @(posedge clk iff rst_n === 1'b1);
    wr_if.drv_ck.wr_en <= 0;
    wr_if.drv_ck.din   <= 0;
    foreach(wr_data[j]) begin
        @(posedge clk);
        wr_if.drv_ck.wr_en <=1;
        wr_if.drv_ck.din   <= wr_data[j];
        //print_write_data_1(wr_en, din);
    end
    @(posedge clk);
    wr_if.drv_ck.wr_en <= 0;
    wr_if.drv_ck.din   <= 8'hff;
    //print_write_data_1(wr_en, din);
endtask

task read_drive_1();
    @(posedge clk iff rst_n === 1'b1);
    forever begin
        @(posedge clk);
            rd_if.drv_ck.rd_en <= 1;
    end
endtask

task read_monitor_1();
    automatic int i = 0;
    @(posedge clk iff rst_n === 1'b1);
    forever begin
        @(posedge clk iff rd_en_next_1 === 1'b1);
        //print_read_data_1(rd_en_next_1, rd_if.mon_ck.dout);
        i = i + 1;
        if (i==16) begin
            #1step;
            $stop();
        end
    end
endtask

task gen_rd_en_next_1();
    forever begin
        @(posedge clk);
        rd_en_next_1 <= rd_if.mon_ck.rd_en;
    end
endtask

task mon_all_signal_1();
    string s;
    forever begin
        @(posedge clk);
        //#1step;
        s = $sformatf("wr_en = %d,  din = %d, rd_en = %d, rd_en_next = %d, dout = %d, rd_addr= %d, wr_addr= %d\n", 
                       wr_if.mon_ck.wr_en, wr_if.mon_ck.din,rd_if.mon_ck.rd_en,rd_en_next_1,rd_if.mon_ck.dout, rd_addr_c_1, wr_addr_c_1);
        rpt_pkg::rpt_msg_1("[interface all data]",s, rpt_pkg::INFO, rpt_pkg::LOW);
    end
endtask

function void print_read_data_1(logic rd_en_next, logic [7:0] dout);
    string s;
    s = $sformatf("rd_en_next = %d, read_data = %d",rd_en_next, dout);
    rpt_pkg::rpt_msg_1("[interface read data]",s, rpt_pkg::INFO, rpt_pkg::MEDIUM);
endfunction


function void print_write_data_1(logic wr_en, logic [7:0] din);
    string s;
    s = $sformatf("wr_en = %d, din = %d",wr_en, din);
    rpt_pkg::rpt_msg_1("[interface write data]",s, rpt_pkg::INFO, rpt_pkg::MEDIUM);
endfunction




endmodule

