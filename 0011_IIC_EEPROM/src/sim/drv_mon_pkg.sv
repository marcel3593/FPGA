package drv_mon_pkg;

`include "define.vh"

import rpt_pkg::*;

class eeprom_cntl_trans;
    bit [3:0] cmd;
    rand bit [7:0] wr_data_array[];
    rand bit [7:0] wr_data_length;
    bit [7:0] rd_data_length;
    rand bit [15:0] eeprom_word_addr;
    int wr_pkg_id;
    int rd_pkg_id;
    int cmd_pkg_id;
    bit done;

    constraint csr_seq_write_read {
        cmd == `EEPROM_WR -> foreach (wr_data_array[j])
            if (j%2 == 0)
                wr_data_array[j] == eeprom_word_addr[7:0] + j/2;
            else
                wr_data_array[j] == eeprom_word_addr[15:8] ;
        cmd == `EEPROM_WR -> eeprom_word_addr == {wr_pkg_id,5'b00000};
        cmd == `EEPROM_WR -> wr_data_array.size() == 32;
        wr_data_length == wr_data_array.size();
        cmd != `EEPROM_WR -> wr_data_array.size() == 0;
        cmd == `EEPROM_RD -> eeprom_word_addr == {rd_pkg_id,5'b00000};
    }

    function eeprom_cntl_trans clone();
        eeprom_cntl_trans trans_t;
        trans_t = new();
        trans_t.cmd           = this.cmd                ;
        trans_t.wr_data_array = this.wr_data_array      ;
        trans_t.wr_data_length= this.wr_data_length     ;
        trans_t.rd_data_length= this.rd_data_length     ;
        trans_t.eeprom_word_addr   = this.eeprom_word_addr        ;
        trans_t.wr_pkg_id     = this.wr_pkg_id          ;
        trans_t.rd_pkg_id     = this.rd_pkg_id          ;
        trans_t.cmd_pkg_id    = this.cmd_pkg_id         ;
        trans_t.done          = this.done               ;
        return trans_t;
    endfunction 

    function void printf();
        string s;
        s =               "\n===================================\n";
        s = {s, $sformatf("-----cmd------- = %d------\n", this.cmd)};
        s = {s, $sformatf("-----cmd_pkg_id = %d------\n", this.cmd_pkg_id)};
        s = {s, $sformatf("-----wr_pkg_id  = %d------\n", this.wr_pkg_id)};
        s = {s, $sformatf("-----rd_pkg_id  = %d------\n", this.rd_pkg_id)};
        s = {s, $sformatf("-----eeprom_word_addr = %d------\n", this.eeprom_word_addr)};
        s = {s, $sformatf("-----wr_data_length = %d------\n", this.wr_data_length)};
        s = {s, $sformatf("-----done = %d------\n", this.done)};
        s = {s,           "===================================\n\n"};
        rpt_pkg::rpt_msg("[eeprom_cntl_trans]",s,rpt_pkg::INFO);
    endfunction
endclass: eeprom_cntl_trans


class eeprom_cntl_generator;

    int wr_pkg_id;
    int rd_pkg_id;
    int cmd_pkg_id;
    
    eeprom_cntl_trans cntl_trans_req_t;
    eeprom_cntl_trans cntl_trans_rsp_t;
    mailbox #(eeprom_cntl_trans) mb_cntl_trans_req;
    mailbox #(eeprom_cntl_trans) mb_cntl_trans_rsp;

    mailbox #(eeprom_cntl_trans) mb_cntl_trans_to_checker;

    function new();
        mb_cntl_trans_req = new();
        mb_cntl_trans_rsp = new();
    endfunction

    function void do_config();
        this.cntl_trans_req_t.constraint_mode(0);
        this.cntl_trans_req_t.csr_seq_write_read.constraint_mode(1);
    endfunction
    
    task do_seq_write_read();
        forever begin
            do_gen_cmd_data(`EEPROM_WR);
            do_gen_cmd_data(`EEPROM_RD);
        end
    endtask

    task do_gen_cmd_data(bit [1:0] cmd);
        this.cntl_trans_req_t = new();
        this.cntl_trans_req_t.cmd = cmd;
        this.cntl_trans_req_t.wr_pkg_id = this.wr_pkg_id;
        this.cntl_trans_req_t.rd_pkg_id = this.rd_pkg_id;
        this.cntl_trans_req_t.cmd_pkg_id = this.cmd_pkg_id;
        do_config();
        assert(this.cntl_trans_req_t.randomize()) 
        else $error("eeprom_cntl_trans rand failed, cmd_pkg_id = %d", this.cntl_trans_req_t.cmd_pkg_id);
        mb_cntl_trans_req.put(this.cntl_trans_req_t);
        this.cntl_trans_req_t.printf();
        mb_cntl_trans_rsp.get(this.cntl_trans_rsp_t);
        this.cntl_trans_rsp_t.printf();
        assert (this.cntl_trans_rsp_t.done == 'b1) 
        else   $error("eeprom_cntl_trans trans failed, cmd_pkg_id = %d", this.cntl_trans_rsp_t.cmd_pkg_id);
        if (cmd == `EEPROM_RD)
            this.rd_pkg_id = this.rd_pkg_id + 1;
        else if (cmd == `EEPROM_WR) begin
            mb_cntl_trans_to_checker.put(this.cntl_trans_rsp_t);
            this.wr_pkg_id = this.wr_pkg_id + 1;            
        end
        this.cmd_pkg_id = this.cmd_pkg_id + 1;
    endtask


endclass: eeprom_cntl_generator

class eeprom_cntl_driver;

    mailbox #(eeprom_cntl_trans) mb_cntl_trans_req;
    mailbox #(eeprom_cntl_trans) mb_cntl_trans_rsp;
    virtual eeprom_cntl_interface cntl_inf;
    
    function void set_interface(virtual eeprom_cntl_interface cntl_inf);
        this.cntl_inf = cntl_inf;
    endfunction
    
    task run();
        this.wait_sys_reset();
        forever begin
            eeprom_cntl_trans cntl_trans_req_t;
            eeprom_cntl_trans cntl_trans_rsp_t;
            mb_cntl_trans_req.get(cntl_trans_req_t);
            this.do_driver(cntl_trans_req_t);
            cntl_trans_rsp_t = cntl_trans_req_t.clone();
            cntl_trans_rsp_t.done = 1;
            mb_cntl_trans_rsp.put(cntl_trans_rsp_t);
        end
    endtask

    task do_driver(eeprom_cntl_trans cntl_trans_req_t);
        case (cntl_trans_req_t.cmd)
            `EEPROM_WR: this.do_write(cntl_trans_req_t);
            `EEPROM_RD: this.do_read(cntl_trans_req_t);
            default: ;
        endcase
    endtask

    task do_write(eeprom_cntl_trans cntl_trans_req_t);
        this.wait_busy();
        this.do_buffer_reset();
        foreach (cntl_trans_req_t.wr_data_array[j]) begin
            @(posedge cntl_inf.sys_clk iff cntl_inf.drv_ck.buffer_full == 1'b0);
            cntl_inf.drv_ck.buffer_wr_en <=1;
            cntl_inf.drv_ck.data <= cntl_trans_req_t.wr_data_array[j];
            @(posedge cntl_inf.sys_clk);
            cntl_inf.drv_ck.buffer_wr_en <=0;
            cntl_inf.drv_ck.data <= 'Z;
        end
        @(posedge cntl_inf.sys_clk);
        cntl_inf.drv_ck.cmd <= `EEPROM_WR;
        cntl_inf.drv_ck.data <= cntl_trans_req_t.eeprom_word_addr[7:0];
        @(posedge cntl_inf.sys_clk);
        cntl_inf.drv_ck.cmd <= `EEPROM_WR;
        cntl_inf.drv_ck.data <= cntl_trans_req_t.eeprom_word_addr[15:8];
        @(posedge cntl_inf.sys_clk);
        cntl_inf.drv_ck.cmd <= `EEPROM_NOP;
        cntl_inf.drv_ck.data <= 'Z;          
    endtask

    task do_read(eeprom_cntl_trans cntl_trans_req_t);
        this.wait_busy();
        this.do_buffer_reset();
        @(posedge cntl_inf.sys_clk);
        cntl_inf.drv_ck.cmd <= `EEPROM_RD;
        cntl_inf.drv_ck.data <= cntl_trans_req_t.eeprom_word_addr[7:0];
        @(posedge cntl_inf.sys_clk);
        cntl_inf.drv_ck.cmd <= `EEPROM_RD;
        cntl_inf.drv_ck.data <= cntl_trans_req_t.eeprom_word_addr[15:8];
        @(posedge cntl_inf.sys_clk);
        cntl_inf.drv_ck.cmd <= `EEPROM_NOP;
        cntl_inf.drv_ck.data <= 'Z;
        this.wait_busy();
        forever begin
            @(posedge cntl_inf.sys_clk);
            if (cntl_inf.drv_ck.buffer_empty == 1'b0) //!!!
                cntl_inf.drv_ck.buffer_rd_en <=1;
            else begin
                cntl_inf.drv_ck.buffer_rd_en <=0;
                break;
            end
            @(posedge cntl_inf.sys_clk);
            cntl_inf.drv_ck.buffer_rd_en <=0;
        end    
    endtask

    task do_buffer_reset();
        @(posedge cntl_inf.sys_clk);
         cntl_inf.drv_ck.buffer_reset <=1;
        @(posedge cntl_inf.sys_clk);
         cntl_inf.drv_ck.buffer_reset <=0;         
    endtask

    task wait_sys_reset();
        @(posedge cntl_inf.sys_clk iff cntl_inf.sys_rst_n == 1'b1);
        cntl_inf.drv_ck.buffer_rd_en <=0;
        cntl_inf.drv_ck.buffer_wr_en <=0;
    endtask

    task wait_busy();
        @(posedge cntl_inf.sys_clk iff cntl_inf.drv_ck.busy == 1'b0);
    endtask

endclass: eeprom_cntl_driver

typedef struct {
    bit [7:0] rd_data_array[$];
    int rd_pkg_id;
} mon_data;

class eeprom_cntl_monitor;

    int rd_pkg_id;
    
    mailbox #(mon_data) mb_moniter_to_checker;
    virtual eeprom_cntl_interface cntl_inf;
    
    function void set_interface(virtual eeprom_cntl_interface cntl_inf);
        this.cntl_inf = cntl_inf;
    endfunction

    task run();
        wait_sys_reset();
        forever begin
            do_moniter_rd_data();
        end
    endtask

    task do_moniter_rd_data();
        mon_data mon_data_t;
        bit [7:0] rd_data;
        @(posedge cntl_inf.sys_clk iff cntl_inf.mon_ck.cmd == `EEPROM_RD);
        @(posedge cntl_inf.sys_clk iff cntl_inf.mon_ck.buffer_rd_en == 1'b1);
        forever begin
            rd_data = cntl_inf.mon_ck.data;
            mon_data_t.rd_data_array.push_front(rd_data);
            @(posedge cntl_inf.sys_clk);
            @(posedge cntl_inf.sys_clk);
            if (cntl_inf.mon_ck.buffer_rd_en == 1'b0)
                break;
        end
        mon_data_t.rd_pkg_id = this.rd_pkg_id;
        mb_moniter_to_checker.put(mon_data_t);
        this.rd_pkg_id = this.rd_pkg_id  + 1;
    endtask

    task wait_sys_reset();
        @(posedge cntl_inf.sys_clk iff cntl_inf.sys_rst_n == 1'b1);
    endtask

endclass:  eeprom_cntl_monitor

class eeprom_cntl_checker;

    mailbox #(eeprom_cntl_trans) mb_cntl_trans_to_checker;
    mailbox #(mon_data) mb_moniter_to_checker;

    function new();
        mb_cntl_trans_to_checker = new();
        mb_moniter_to_checker = new();
    endfunction

    task do_compare();
        forever begin
            eeprom_cntl_trans cntl_trans_t;
            mon_data mon_data_t;
            mb_cntl_trans_to_checker.get(cntl_trans_t);
            mb_moniter_to_checker.get(mon_data_t);
            ref_model_cmp(cntl_trans_t, mon_data_t);            
        end
    endtask

    function void ref_model_cmp(eeprom_cntl_trans cntl_trans_t, mon_data mon_data_t);
        bit cmp = 1;
        bit s_cmp = 1;
        int size_of_write;
        int size_of_read;
        string title;
        string s;
        bit [7:0] rd_data_array [];
        bit [7:0] wr_data_array [];
        int i;
        size_of_write = cntl_trans_t.wr_data_array.size();
        size_of_read = mon_data_t.rd_data_array.size();
        rd_data_array = new[size_of_read];
        wr_data_array = new[size_of_write];
        foreach(rd_data_array[j])
            rd_data_array[j] = mon_data_t.rd_data_array.pop_back();
        wr_data_array = cntl_trans_t.wr_data_array;
        if (cntl_trans_t.wr_pkg_id != mon_data_t.rd_pkg_id)
            cmp = 0;
        else if (size_of_write != size_of_read) begin
            cmp = 0;
            if (size_of_write > size_of_read)
                for(i=0;i < (size_of_write - size_of_read);i++)
                    rd_data_array = {rd_data_array, 8'hff};
            else
                for(i=0;i < (size_of_read - size_of_write);i++)
                    wr_data_array = {wr_data_array, 8'hff};
        end
        else
            foreach (wr_data_array[j]) begin
                if (wr_data_array[j] != rd_data_array[j])
                    cmp = 0;
            end
        title = $sformatf("cmp = %d; cmd_pkg_id = %d, wr_pkg_id = %d, rd_pkg_id = %d, word_address= %5d",
                cmp, cntl_trans_t.cmd_pkg_id, cntl_trans_t.wr_pkg_id, mon_data_t.rd_pkg_id, cntl_trans_t.eeprom_word_addr
            );
        s = "\n";
        foreach (wr_data_array[j]) begin
            if (wr_data_array[j] != rd_data_array[j])
                s_cmp = 0;
            else
                s_cmp = 1;
            s = {s, $sformatf("index = %d, s_cmp = %d, wr_data = %08b, rd_data = %08b \n",
                                    j,           s_cmp,wr_data_array[j],rd_data_array[j])};
        end
        s = {s,"\n"};      
        if (cmp == 0)
            rpt_pkg::rpt_msg(title, s, rpt_pkg::ERROR);
        else
            rpt_pkg::rpt_msg(title, s, rpt_pkg::WARNING);
    endfunction
endclass: eeprom_cntl_checker


endpackage