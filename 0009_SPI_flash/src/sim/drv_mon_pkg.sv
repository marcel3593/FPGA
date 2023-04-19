package drv_mon_pkg;
import rpt_pkg::*;

`include "define.vh"

class cmd_trans;
    rand bit [3:0]  cmd; 
    rand bit [31:0] addr;
    rand bit [7:0]  data;
    rand int        pkg_id;
    rand int        data_pkg_id;
    rand int        data_pkg_max;
    bit             done;

    function cmd_trans clone();
        cmd_trans nt;
        nt = new();
        nt.cmd = this.cmd;
        nt.addr = this.addr;
        nt.data = this.data;
        nt.done = this.done;
        nt.pkg_id = this.pkg_id;
        nt.data_pkg_id = this.data_pkg_id;
        nt.data_pkg_max = this.data_pkg_max;
        return nt; 
    endfunction

    function void pinfo();
        string s;
        s = "======================\n";
        s = {s, $sformatf("pkg_id = %d\n", this.pkg_id)};
        s = {s, $sformatf("cmd = %d\n", this.cmd)};
        s = {s, $sformatf("addr = %d\n", this.addr)};
        s = {s, $sformatf("data = %d\n", this.data)};
        s = {s, $sformatf("done = %d\n", this.done)};
        s = {s, $sformatf("data_pkg_id = %d\n", this.data_pkg_id)};
        s = {s, $sformatf("data_pkg_max = %d\n", this.data_pkg_max)};
        rpt_pkg::rpt_msg("[info]",s, rpt_pkg::INFO, rpt_pkg::LOW);
    endfunction

endclass: cmd_trans

typedef bit [7:0] data_bytes [0:255];

class generator;
    local bit [3:0]  cmd; 
    local bit [31:0] addr;
    local bit [7:0]  data;
    local int        pkg_id;
    local int        data_pkg_id;
    local int        data_pkg_max;
    static data_bytes data_bytes_t; 

    mailbox #(cmd_trans)  mb_cmd_req_t;
    mailbox #(cmd_trans)  mb_cmd_rsp_t;
    mailbox #(cmd_trans)  mb_cmd_checker_t;
    mailbox #(data_bytes) mb_data_checker_t;
    
    function new();
        mb_cmd_req_t = new();
        mb_cmd_rsp_t = new();
    endfunction
    
    function void do_config(string cmd_type, int addr);
        if (cmd_type == "RD") begin
            this.cmd = `C_RD;
            this.addr = addr; //first page
            this.data = 8'd255; //read one page            
        end
        else if (cmd_type == "PP") begin
            this.data_pkg_id = 0; //reset id
            this.cmd = `C_PP;
            this.addr = addr; //first page
        end
        else if (cmd_type == "SE") begin
            this.cmd = `C_SE;
            this.addr = addr; //first page
        end
        else if (cmd_type == "LD") begin
            this.cmd = `C_LD;
        end
        else if (cmd_type == "NOP") begin
            this.cmd = `C_NOP;
        end
    endfunction
    
    function void gen_tx_data_bytes(int data_pkg_max);
        int i;
        this.data_pkg_max = data_pkg_max;
        for (i=0;i<this.data_pkg_max;i++)
            data_bytes_t[i] = i;
    endfunction

    task do_cmd_req();
        cmd_trans cmd_req;
        cmd_trans cmd_rsp;
        cmd_req = new();
        if (cmd == `C_LD)
            data = data_bytes_t[data_pkg_id];
        assert (cmd_req.randomize() with {
            cmd == local::cmd;
            addr == local::addr;
            data == local::data;
            pkg_id == local::pkg_id;
            data_pkg_id == local::data_pkg_id;
            data_pkg_max == local::data_pkg_max;})
        else $fatal("[cmd_req tran ] randomize failed with pkg_id =%d",pkg_id);
        cmd_req.pinfo();
        mb_cmd_req_t.put(cmd_req);
        mb_cmd_rsp_t.get(cmd_rsp);
        cmd_rsp.pinfo();
        assert (cmd_rsp.done == 'b1) 
        else   $error("pkg_id  [%d] not send sucessfully",pkg_id);
        if (cmd_rsp.cmd != `C_NOP && cmd_rsp.cmd != `C_LD)
            mb_cmd_checker_t.put(cmd_rsp); // send this to checker for reference
        if (cmd == `C_LD)
            data_pkg_id ++;
        else if (cmd != `C_NOP) 
            pkg_id ++;
        if (cmd == `C_LD && data_pkg_id == data_pkg_max)
            mb_data_checker_t.put(data_bytes_t);
    endtask

endclass: generator


class driver;
    local virtual cntl_inf c_inf;
    mailbox #(cmd_trans) mb_cmd_req_t;
    mailbox #(cmd_trans) mb_cmd_rsp_t;

    function void set_interface(virtual cntl_inf c_inf);
        this.c_inf = c_inf;
    endfunction

    task run();
        cmd_trans cmd_req;
        cmd_trans cmd_rsp;
        @(posedge c_inf.sys_rst_n);   
        forever begin
            mb_cmd_req_t.get(cmd_req);
            if (cmd_req.cmd == `C_RD) begin
                @(posedge c_inf.sys_clk iff c_inf.drv_ck.busy === 1'b0);
                c_inf.drv_ck.cmd <= cmd_req.cmd;
                c_inf.drv_ck.addr <= cmd_req.addr;
                c_inf.drv_ck.data <= cmd_req.data;
            end
            else if (cmd_req.cmd == `C_SE || cmd_req.cmd == `C_PP) begin
                @(posedge c_inf.sys_clk iff c_inf.drv_ck.busy === 1'b0);
                c_inf.drv_ck.cmd <= cmd_req.cmd;
                c_inf.drv_ck.addr <= cmd_req.addr;
                c_inf.drv_ck.data <='z;
            end
            else if (cmd_req.cmd == `C_LD)begin
                @(posedge c_inf.sys_clk);
                c_inf.drv_ck.cmd <= cmd_req.cmd;
                c_inf.drv_ck.data <= cmd_req.data;
            end
            else if (cmd_req.cmd == `C_NOP)begin 
                @(posedge c_inf.sys_clk);
                c_inf.drv_ck.cmd <= cmd_req.cmd;
                c_inf.drv_ck.data <='z;
            end
            cmd_rsp = cmd_req.clone();
            cmd_rsp.done = 1;
            mb_cmd_rsp_t.put(cmd_rsp);
        end
    endtask

endclass: driver

typedef struct {
    bit [3:0]  cmd; 
    bit [31:0] addr;
    bit [7:0]  data;
    bit [0:255][7:0] data_buffer;
    bit [0:255][7:0] rd_data_buffer;
    byte spi_data_mosi [0:269] ; //270bytes max
    byte spi_data_miso [0:269] ;
    int spi_pkg_bytes_nu [0:3];
    int pkg_id;
    int rd_data_pkg_id;
} mon_data;

class monitor;
    local virtual cntl_inf c_inf;
    local virtual spi_inf  s_inf;
    static int pkg_id;
    static int data_pkg_id;
    static int rd_data_pkg_id;
    mon_data mon_data_t;
    byte spi_pkg_id;
    int spi_byte_id;

    mailbox #(mon_data) mb_mon_data_t;

    function void set_interface(virtual cntl_inf c_inf, virtual spi_inf s_inf);
        this.c_inf = c_inf;
        this.s_inf = s_inf;
    endfunction
    
    task run();
        @(posedge c_inf.sys_rst_n);
        fork
            mon_cntl();
            sample_cmd();
            sample_load_data();
            sample_spi();
            sample_csn();
            sample_valid_rd_data();
        join
    endtask

    task mon_cntl();
        forever begin
            @(negedge c_inf.mon_ck.busy);
            mon_data_t.pkg_id = pkg_id;
            mon_data_t.rd_data_pkg_id = rd_data_pkg_id;
            mb_mon_data_t.put(mon_data_t);
            data_pkg_id = 0;
            spi_pkg_id = 0;
            spi_byte_id = 0;
            rd_data_pkg_id =0;
            mon_data_t.spi_pkg_bytes_nu = '{0,0,0,0};
            pkg_id ++;
        end
    endtask

    task sample_cmd();
        forever begin
            @(posedge c_inf.sys_clk iff (c_inf.mon_ck.cmd != `C_NOP && c_inf.mon_ck.cmd != `C_LD));
            mon_data_t.cmd = c_inf.mon_ck.cmd;
            mon_data_t.addr = c_inf.mon_ck.addr;
            mon_data_t.data = c_inf.mon_ck.data;
        end    
    endtask

    task sample_load_data();
        forever begin
            @(posedge c_inf.sys_clk iff c_inf.mon_ck.cmd == `C_LD);
            mon_data_t.data_buffer[data_pkg_id] = c_inf.mon_ck.data;
            data_pkg_id ++;
        end    
    endtask

    task sample_spi();
        bit [2:0] spi_bit_id;
        forever begin
            @(posedge s_inf.mon_ck.sck iff s_inf.mon_ck.cs_n == 1'b0);
            mon_data_t.spi_data_mosi[spi_byte_id][spi_bit_id] = s_inf.mon_ck.mosi;
            mon_data_t.spi_data_miso[spi_byte_id][spi_bit_id] = s_inf.mon_ck.miso;
            spi_bit_id ++;
            if (spi_bit_id == 0 ) begin
                spi_byte_id ++;
                mon_data_t.spi_pkg_bytes_nu[spi_pkg_id] ++;
            end
        end
    endtask

    task sample_csn();
        forever begin
            @(posedge s_inf.mon_ck.cs_n);
            spi_pkg_id ++;
        end
    endtask

    task sample_valid_rd_data();
        forever begin
            @(posedge c_inf.sys_clk iff c_inf.mon_ck.valid == 1'b1);
            mon_data_t.rd_data_buffer[rd_data_pkg_id] = c_inf.mon_ck.data;
            rd_data_pkg_id ++;
        end
    endtask

endclass

typedef byte spi_data_bytes[$];

class spi_checker;
    spi_data_bytes spi_mosi_data_act;
    spi_data_bytes spi_miso_data_act;
    spi_data_bytes spi_mosi_data_exp;
    spi_data_bytes spi_miso_data_exp;
    spi_data_bytes sys_rd_data_act;
    
    mailbox #(mon_data) mb_mon_data_t;
    mailbox #(cmd_trans) mb_cmd_checker_t;
    mailbox #(data_bytes) mb_data_checker_t;


    function new();
        mb_mon_data_t = new();
        mb_cmd_checker_t = new();
        mb_data_checker_t = new();
    endfunction

    function void ref_model(cmd_trans cmd_t, data_bytes data_bytes_t);
        bit [31:0] addr;
        shortint i;
        addr = cmd_t.addr;
        if (cmd_t.cmd == `C_SE) begin
            spi_mosi_data_exp.push_back(`WE);
            spi_mosi_data_exp.push_back(`SE);
            for(i=0;i<`ADDR_W;i++) begin
                spi_mosi_data_exp.push_back(addr[ 8*`ADDR_W : 8*`ADDR_W-8 ]);
                addr = addr << 8;
            end
        end
        else if (cmd_t.cmd == `C_PP) begin
            spi_mosi_data_exp.push_back(`WE);
            spi_mosi_data_exp.push_back(`PP);
            for(i=0;i<`ADDR_W;i++) begin
                spi_mosi_data_exp.push_back(addr[ 8*`ADDR_W : 8*`ADDR_W-8 ]);
                addr = addr << 8;
            end
            for(i=0;i<cmd_t.data_pkg_max;i++) begin
                spi_mosi_data_exp.push_back(data_bytes_t[i]);
                spi_miso_data_exp.push_back(data_bytes_t[i]);
            end
        end
        else if (cmd_t.cmd == `C_RD) begin
            spi_mosi_data_exp.push_back(`RD);
            spi_miso_data_exp.push_back(8'h00);
            for(i=0;i<`ADDR_W;i++) begin
                spi_mosi_data_exp.push_back(addr[ 8*`ADDR_W : 8*`ADDR_W-8 ]);
                addr = addr << 8;
                spi_miso_data_exp.push_back(8'h00);
            end
            for(i=0;i<256;i++) begin
                spi_mosi_data_exp.push_back(8'h00);
                spi_miso_data_exp.push_back(data_bytes_t[i]);
            end               
        end
    endfunction

    function void format_spi_data_in_bytes(mon_data mon_data_t);
        int i;
        if (mon_data_t.cmd == `C_SE || mon_data_t.cmd == `C_PP) begin
            spi_mosi_data_act.push_back(bit_order_reverse(mon_data_t.spi_data_mosi[0]));
            for(i=0;i<mon_data_t.spi_pkg_bytes_nu[1];i++)
                spi_mosi_data_act.push_back(bit_order_reverse(mon_data_t.spi_data_mosi[i+1]));
            end
        else if (mon_data_t.cmd == `C_RD) begin
            for(i=0;i<mon_data_t.spi_pkg_bytes_nu[0];i++) begin
                spi_mosi_data_act.push_back(bit_order_reverse(mon_data_t.spi_data_mosi[i]));
                spi_miso_data_act.push_back(bit_order_reverse(mon_data_t.spi_data_miso[i]));
            end
        end
    endfunction

    function byte bit_order_reverse(byte din);
        byte dout;
        byte i;
        for (i=0;i<8;i++)
            dout[i] = din[7-i];
        return dout;
    endfunction

    task do_compare();
        cmd_trans cmd_t;
        mon_data mon_data_t;
        data_bytes data_bytes_t;
        bit cmp = 1;
        int i;
        string s;
        rpt_pkg::report_t r;
        int size_spi_mosi_data_act;
        int size_spi_miso_data_act;
        int size_spi_mosi_data_exp;
        int size_spi_miso_data_exp;
        int size_sys_rd_data_act;
        forever begin
            spi_mosi_data_act = {};
            spi_miso_data_act = {};
            spi_mosi_data_exp = {};
            spi_miso_data_exp = {};
            sys_rd_data_act = {};
            mb_cmd_checker_t.get(cmd_t);
            mb_mon_data_t.get(mon_data_t);
            if (cmd_t.cmd == `C_PP)
                mb_data_checker_t.get(data_bytes_t);
            format_spi_data_in_bytes(mon_data_t);
            ref_model(cmd_t, data_bytes_t);
            size_spi_mosi_data_act = $size(spi_mosi_data_act);
            size_spi_miso_data_act = $size(spi_miso_data_act);
            size_spi_mosi_data_exp = $size(spi_mosi_data_exp);
            size_spi_miso_data_exp = $size(spi_miso_data_exp);
            if (cmd_t.pkg_id != mon_data_t.pkg_id || cmd_t.cmd != mon_data_t.cmd || cmd_t.addr != mon_data_t.addr)
                cmp = 0;
            if (size_spi_mosi_data_act == size_spi_mosi_data_exp) begin
                foreach (spi_mosi_data_act[j])
                    if (spi_mosi_data_act[j] != spi_mosi_data_exp[j])
                        cmp = 0;
            end
            else begin
                cmp = 0;
                if (size_spi_mosi_data_act > size_spi_mosi_data_exp)
                    for (i=0; i< (size_spi_mosi_data_act - size_spi_mosi_data_exp);i++)
                        spi_mosi_data_exp.push_back(8'hff);
                else
                    for (i=0; i< (size_spi_mosi_data_exp - size_spi_mosi_data_act);i++)
                        spi_mosi_data_act.push_back(8'hff);                    
            end
            if (cmd_t.cmd == `C_RD) begin//only compare MISO in read mode 
                if (size_spi_miso_data_act == size_spi_miso_data_exp) begin
                    foreach (spi_miso_data_act[j])
                        if (spi_miso_data_act[j] != spi_miso_data_exp[j])
                            cmp = 0;
                end
                else begin
                    cmp = 0;
                    if (size_spi_miso_data_act > size_spi_miso_data_exp)
                        for (i=0; i< (size_spi_miso_data_act - size_spi_miso_data_exp);i++)
                            spi_miso_data_exp.push_back(8'hff);
                    else
                        for (i=0; i< (size_spi_miso_data_exp - size_spi_miso_data_act);i++)
                            spi_miso_data_act.push_back(8'hff);               
                end
                //act rd data compare
                sys_rd_data_act.push_back(8'h00);
                sys_rd_data_act.push_back(8'h00);
                sys_rd_data_act.push_back(8'h00);
                sys_rd_data_act.push_back(8'h00);
                foreach (mon_data_t.rd_data_buffer[j])
                    sys_rd_data_act.push_back(mon_data_t.rd_data_buffer[j]);
                size_sys_rd_data_act = $size(sys_rd_data_act);
                if (size_sys_rd_data_act == size_spi_miso_data_exp) begin
                    foreach (spi_miso_data_act[j])
                        if (spi_miso_data_act[j] != sys_rd_data_act[j])
                            cmp = 0;                    
                end
                else 
                    cmp = 0;                 
            end
            //print
            r = (cmp == 0) ? rpt_pkg::ERROR : rpt_pkg::WARNING;
            s = $sformatf( "cmp = %d;pkg_id = %d(exp), %d(act);", cmp ,cmd_t.pkg_id, mon_data_t.pkg_id);
            s = {s, $sformatf ("cmd = %d(exp), %d(act);", cmd_t.cmd, mon_data_t.cmd)};
            s = {s, $sformatf ("addr = %d(exp), %d(act) --> \n", cmd_t.addr, mon_data_t.addr)};
            rpt_pkg::rpt_msg("[PACKAGE]",s,r,rpt_pkg::MEDIUM);
            s = "";
            foreach (spi_mosi_data_act[j])
                s = {s, $sformatf("\nbyte_nu = %d, exp = %2h, act = %2h ", j,spi_mosi_data_exp[j], spi_mosi_data_act[j])};
            rpt_pkg::rpt_msg("[MOSI]",s,r,rpt_pkg::MEDIUM);
            s = "";
            foreach (spi_miso_data_act[j])
                s = {s, $sformatf("\nbyte_nu = %d, exp = %2h, act = %2h ,sys_rd_data = %2h", j,spi_miso_data_exp[j], spi_miso_data_act[j], sys_rd_data_act[j])};
            rpt_pkg::rpt_msg("[MIS0]",s,r,rpt_pkg::MEDIUM);
        end
    endtask

endclass: spi_checker

endpackage