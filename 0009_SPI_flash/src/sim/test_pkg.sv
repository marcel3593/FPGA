package test_pkg;

import rpt_pkg::*;
import drv_mon_pkg::*;

`include "define.vh"


class base_test;
    generator gen_ct;
    driver    drv_ct;
    monitor   mon_ct;
    spi_checker chker_ct;
    int data_pkg_max;

    function new();
        gen_ct    =  new();   
        drv_ct    =  new();   
        mon_ct    =  new();   
        chker_ct  =  new();
        connect_mailbox(); 
    endfunction

    virtual function void set_interface(virtual cntl_inf c_inf, virtual spi_inf s_inf);
        drv_ct.set_interface(c_inf);
        mon_ct.set_interface(c_inf, s_inf);
    endfunction

    function void connect_mailbox();
        gen_ct.mb_cmd_checker_t = chker_ct.mb_cmd_checker_t;
        gen_ct.mb_data_checker_t = chker_ct.mb_data_checker_t;
        mon_ct.mb_mon_data_t = chker_ct.mb_mon_data_t;
        drv_ct.mb_cmd_req_t = gen_ct.mb_cmd_req_t;
        drv_ct.mb_cmd_rsp_t = gen_ct.mb_cmd_rsp_t;
    endfunction

    task run();
        fork
            drv_ct.run();
            mon_ct.run();
            chker_ct.do_compare();
        join_none
        do_seq();
    endtask

    virtual task do_seq();
        int i;
        int data_pkg_max = 256;
        int addr=32'h100;
        gen_ct.do_config("SE",addr);
        gen_ct.do_cmd_req();
        gen_ct.do_config("NOP",addr);
        gen_ct.do_cmd_req();
        gen_ct.gen_tx_data_bytes(data_pkg_max);
        gen_ct.do_config("PP",addr);
        gen_ct.do_cmd_req();
        gen_ct.do_config("LD",addr);
        for(i=0;i<data_pkg_max;i++)
            gen_ct.do_cmd_req();
        gen_ct.do_config("NOP",addr);
        gen_ct.do_cmd_req();
        gen_ct.do_config("RD",addr);
        gen_ct.do_cmd_req();
        gen_ct.do_config("NOP",addr);
        gen_ct.do_cmd_req();
        gen_ct.do_config("RD",addr);
        gen_ct.do_cmd_req();
        gen_ct.do_config("NOP",addr);
        gen_ct.do_cmd_req();
        gen_ct.do_config("RD",addr);
        gen_ct.do_cmd_req();
        gen_ct.do_config("NOP",addr);
        gen_ct.do_cmd_req();
        gen_ct.do_config("PP",addr);
        gen_ct.do_cmd_req();
        gen_ct.do_config("LD",addr);
        for(i=0;i<data_pkg_max;i++)
            gen_ct.do_cmd_req();
        gen_ct.do_config("NOP",addr);
        gen_ct.do_cmd_req();
        gen_ct.do_config("RD",addr);
        gen_ct.do_cmd_req();
        gen_ct.do_config("NOP",addr);
        gen_ct.do_cmd_req();
    endtask

endclass: base_test

endpackage