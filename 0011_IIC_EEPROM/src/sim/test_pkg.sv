
package test_pkg;

import rpt_pkg::*;
import drv_mon_pkg::*;


class base_test;
    eeprom_cntl_generator generator;
    eeprom_cntl_driver driver;
    eeprom_cntl_monitor monitor;
    eeprom_cntl_checker chker;

    function new();
        generator = new();
        driver = new();
        monitor = new();
        chker = new();
        generator.mb_cntl_trans_to_checker = chker.mb_cntl_trans_to_checker;
        monitor.mb_moniter_to_checker= chker.mb_moniter_to_checker;
        driver.mb_cntl_trans_req = generator.mb_cntl_trans_req;
        driver.mb_cntl_trans_rsp = generator.mb_cntl_trans_rsp;
    endfunction
    
    function void set_interface(virtual eeprom_cntl_interface cntl_inf);
        driver.set_interface(cntl_inf);
        monitor.set_interface(cntl_inf);
    endfunction

    task run();
        fork
            gen_cmd_data();
            driver.run();
            monitor.run();
            chker.do_compare();
        join
    endtask

    virtual task gen_cmd_data();
        generator.do_seq_write_read();
    endtask
    
endclass

endpackage