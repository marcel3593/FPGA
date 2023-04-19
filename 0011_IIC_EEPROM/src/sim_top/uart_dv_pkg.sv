package  uart_dv_pkg;

`timescale  1ns/10ps
`include "../rtl/uart_parameters.vh"

import rpt_pkg::*;

class write_trans;
    rand bit [`BYTE_SIZE-1:0] data;
    rand int pkg_id;
    rand bit parity;
    bit done;

    constraint csrt_sequence {
        soft data == pkg_id;
        parity == `PARITY_TYPE ? ~(^data) : ^data;
    };

    function write_trans clone();
        write_trans t;
        t = new();
        t.data = this.data;
        t.pkg_id = this.pkg_id;
        t.parity = this.parity;
        t.done = this.done;
        return t;
    endfunction

    function void msg_display();
        string s;
        s = $sformatf("\n -----------------------------\n");
        s = {s, $sformatf("pkg_id = %d, data = %2x, parity = %1b, done = %1b\n",this.pkg_id, this.data, this.parity, this.done)};
        s = {s, $sformatf(" -----------------------------\n")};
        rpt_pkg::rpt_msg("write_trans", s, rpt_pkg::INFO, rpt_pkg::HIGH);
    endfunction

endclass: write_trans

class generator;
    rand int pkg_id = 0; 
    rand int pkg_amount = 10000;
    write_trans wr_req_t;
    write_trans wr_rsp_t;
    mailbox #(write_trans) mb_wr_req;
    mailbox #(write_trans) mb_wr_rsp;
    mailbox #(write_trans) mb_wr_raw_data;  //instance in checker

    function new();
        this.mb_wr_req = new();
        this.mb_wr_rsp = new();
    endfunction

    task run();
        while(this.pkg_id < this.pkg_amount) begin
            this.send_write_trans();
            this.pkg_id++;
        end
    endtask

    task send_write_trans();
        this.wr_req_t = new();
        assert(this.wr_req_t.randomize() with {pkg_id == local::pkg_id;} )
        else $fatal("[write trans random] pkg_id = %d randomized failed", this.pkg_id);
        this.wr_req_t.msg_display();
        this.mb_wr_req.put(this.wr_req_t);
        this.mb_wr_raw_data.put(this.wr_req_t);
        this.mb_wr_rsp.get(this.wr_rsp_t);
        this.wr_rsp_t.msg_display();
        assert(this.wr_rsp_t.done) 
        else $fatal("[write trans handshake] pkg_id = %d not complete", this.pkg_id);
    endtask
endclass: generator

class wr_driver;
    write_trans wr_req_t;
    write_trans wr_rsp_t;    
    mailbox #(write_trans) mb_wr_req;
    mailbox #(write_trans) mb_wr_rsp;
    local virtual tx_interface tx_if;
    local virtual debug_interface debug_if;

    function void set_interface(virtual tx_interface tx_if, virtual debug_interface debug_if);
        this.tx_if = tx_if;
        this.debug_if = debug_if;
    endfunction

    task run();
        this.do_reset();
        forever begin
            this.mb_wr_req.get(this.wr_req_t);
            this.do_write();
            this.wr_rsp_t = this.wr_req_t.clone();
            this.wr_rsp_t.done = 1;
            this.mb_wr_rsp.put(this.wr_rsp_t);
        end
    endtask

    task do_reset();
        @(negedge this.tx_if.rst_n);
        this.tx_if.tx <= 1;
        @(posedge this.tx_if.clk iff this.tx_if.rst_n == 1'b1);
        this.tx_if.tx <= 1;
    endtask
    
    task do_write();
        int baud_cnt;
        bit [`BIT_CNT_MAX  : 0] wr_data;
        int j;
        wr_data = '{default:1};
        wr_data[0] = 0; //start bit
        wr_data[`BYTE_SIZE : 1] = this.wr_req_t.data; //data
        wait (debug_if.mon_ck.fsm_status == 2'b00);
        if (`PARITY) wr_data[`BYTE_SIZE + 1] = this.wr_req_t.parity; //parity
        for(j=0;j<$size(wr_data);j++) begin
            $display("j: %d = %d",j, wr_data[j]);
            baud_cnt = 0;
            while (baud_cnt <= `BAUD_CNT_MAX) begin
                @(posedge this.tx_if.clk);
                this.tx_if.tx <= wr_data[j];
                baud_cnt ++;
            end
        end
    endtask
endclass


typedef struct packed {
    int pkg_id;
    bit [`BYTE_SIZE-1:0] data;
    bit parity;   
} s_read_trans;

class read_monitor;
    int pkg_id = 0;
    local virtual rx_interface rx_if;
    mailbox #(s_read_trans) mb_rd_t;  //instance in checker
    
    function void set_interface(virtual rx_interface rx_if);
        this.rx_if = rx_if;
    endfunction 

    task run();
        this.do_reset();
        this.do_read();
    endtask

    task do_reset();
    @(posedge this.rx_if.clk iff this.rx_if.rst_n == 1'b1);
    endtask
    
    task do_read();
        s_read_trans rd_t;
        bit [`BIT_CNT_MAX : 0] rd_data;
        bit rd_en;
        int baud_cnt;
        int j;
        bit error = 0;
        forever begin
            rd_en = 0;
            @(negedge this.rx_if.rx);
            rd_en = 1;
            for(j=0;j<$size(rd_data);j++) begin
                baud_cnt = 0;
                while (baud_cnt <= `BAUD_CNT_MAX) begin
                    @(posedge this.rx_if.clk);
                    if (baud_cnt == `BAUD_CNT_CENTER) rd_data[j] = this.rx_if.mon_ck.rx;
                    baud_cnt ++;
                end
            end
            rd_t.data = rd_data[`BYTE_SIZE : 1];
            rd_t.parity = `PARITY ? rd_data[`BYTE_SIZE + 1] : 0;
            error = `PARITY ? (`PARITY_TYPE ? ~(^rd_data[`BYTE_SIZE+1:1]) : ^rd_data[`BYTE_SIZE+1:1] ) : 0;
            assert (~error) 
            else   rpt_pkg::rpt_msg("CMP", $sformatf("find parity error of pkg = %d",rd_t.pkg_id), rpt_pkg::ERROR, rpt_pkg::HIGH);
            mb_rd_t.put(rd_t);
            rd_t.pkg_id ++;
        end 
    endtask
endclass

class uart_checker;
    mailbox #(s_read_trans) mb_rd_t;
    mailbox #(write_trans) mb_wr_raw_data;

    function new();
        mb_rd_t = new();
        mb_wr_raw_data =new();
    endfunction

    task run();
        forever begin
            this.compare();
        end
    endtask
    task compare();
        write_trans wr_req_t;
        s_read_trans rd_t;
        bit cmp = 1;
        string s;
        mb_wr_raw_data.get(wr_req_t);
        mb_rd_t.get(rd_t);
        if (rd_t.pkg_id == wr_req_t.pkg_id && rd_t.data == wr_req_t.data) begin
            if (`PARITY && rd_t.parity != wr_req_t.parity)
                cmp = 0;
            else
                cmp = 1;
        end
        else
            cmp = 0;
        s = $sformatf("wr_pkg = %d, wr_data = %2x, wr_parity = %1b,", wr_req_t.pkg_id, wr_req_t.data, wr_req_t.parity);
        s = {s, $sformatf("rd_pkg = %d, rd_data = %2x, rd_parity = %1b", rd_t.pkg_id, rd_t.data, rd_t.parity)};
        if (cmp == 1) begin
            s = {"compare=1,",s};
            rpt_pkg::rpt_msg("CMP", s, rpt_pkg::WARNING, rpt_pkg::MEDIUM);
        end
        else begin
            s = {"compare=0,",s};
            rpt_pkg::rpt_msg("CMP", s, rpt_pkg::ERROR, rpt_pkg::HIGH);
        end
    endtask

endclass


class basic_test;
    generator gen;
    wr_driver wr_drv;
    read_monitor rd_mon;
    uart_checker chk;

    function new();
        rpt_pkg::clean_log();
        this.gen = new();
        this.wr_drv = new();
        this.rd_mon = new();
        this.chk = new();
        this.connect_mailbox();
    endfunction

    virtual function void set_interface(virtual rx_interface rx_if, virtual tx_interface tx_if, virtual debug_interface debug_if);
        this.rd_mon.set_interface(rx_if);
        this.wr_drv.set_interface(tx_if, debug_if);
    endfunction

    virtual function void connect_mailbox();
        this.wr_drv.mb_wr_req = this.gen.mb_wr_req;
        this.wr_drv.mb_wr_rsp = this.gen.mb_wr_rsp;
        this.gen.mb_wr_raw_data = this.chk.mb_wr_raw_data;
        this.rd_mon.mb_rd_t = this.chk.mb_rd_t;
    endfunction

    task run();
        fork
            gen.run();
            wr_drv.run();
            rd_mon.run();
            chk.run();
        join
    endtask

endclass: basic_test


endpackage