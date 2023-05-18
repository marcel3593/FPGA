package test_pkg;
    import access_pkg::*;
    import rpt_pkg::*;
    import checker_pkg::*;


    class base_test;
        cmd_data_gen gen;
        read_driver rd_drv;
        read_monitor rd_mon;
        write_driver wr_drv;
        write_monitor wr_mon;
        fifo_checker chk;

        function new();
            rpt_pkg::clean_log();
            this.gen = new();
            this.rd_drv = new();
            this.rd_mon = new();
            this.wr_drv = new();
            this.wr_mon = new();
            this.chk = new();
        endfunction

        virtual function void set_interface(virtual read_intf rd_if, virtual write_intf wr_if);
            this.rd_drv.set_interface(rd_if);
            this.rd_mon.set_interface(rd_if);
            this.wr_drv.set_interface(wr_if);
            this.wr_mon.set_interface(wr_if);
        endfunction
    
        virtual function void connect_mailbox();
            this.rd_drv.mb_read_req = this.gen.mb_read_req;
            this.rd_drv.mb_read_rsp = this.gen.mb_read_rsp;
            this.wr_drv.mb_write_req = this.gen.mb_write_req;
            this.wr_drv.mb_write_rsp = this.gen.mb_write_rsp;
            this.chk.mb_read_mon_data = this.rd_mon.mb_read_mon_data;
            this.chk.mb_wr_mon_data = this.wr_mon.mb_wr_mon_data;
            this.chk.mb_wr_mon_data_raw = this.gen.mb_write_mon_data;
        endfunction

        virtual function void do_config();
            int rd_mode = 0;
            int wr_mode = 0;
            this.gen.do_config(rd_mode, wr_mode);
        endfunction
        
        virtual task gen_data();
            this.gen.run();
        endtask

        virtual task run();
            fork
                this.gen_data();
            join_none
            fork
                this.rd_drv.run();
                this.rd_mon.run();
                this.wr_drv.run();
                this.wr_mon.run();
                this.chk.run();
             join
        endtask

    endclass

    class read_write_test extends base_test;
        
        function void do_config();
            int rd_mode = 0;
            int wr_mode = 0;
            this.gen.do_config(rd_mode, wr_mode);
        endfunction
        
    endclass: read_write_test

    class read_busy_test extends base_test;
        
        function void do_config();
            int rd_mode = 2;
            int wr_mode = 1;
            this.gen.do_config(rd_mode, wr_mode);
        endfunction

    endclass: read_busy_test

    class write_busy_test extends base_test;
        
        function void do_config();
            int rd_mode = 1;
            int wr_mode = 2;
            this.gen.do_config(rd_mode, wr_mode);
        endfunction

    endclass: write_busy_test


endpackage
