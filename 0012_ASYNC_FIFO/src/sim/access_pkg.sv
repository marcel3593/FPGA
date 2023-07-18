package access_pkg;

    import rpt_pkg::*;

    typedef struct packed{
      logic[7:0] data;
      bit[31:0] id;
    } write_mon_data_t;

    typedef struct packed{
      logic[7:0] data;
      bit[31:0] id;
    } read_mon_data_t;

    class read_trans;
        rand bit rd_en[];
        bit rsp;
        rand int pkg_id;
        rand int rd_dist;

        constraint cstr_low_read{
            rd_en.size inside {[1:16]};
            foreach(rd_en[j]) rd_en[j] dist {0:=90, 1:=10}; 
        }
        constraint cstr_high_read{
            rd_en.size inside {[1:16]};
            foreach(rd_en[j]) rd_en[j] dist {0:=10, 1:=90}; 
        }

        constraint cstr_medium_read{
            rd_en.size inside {[1:16]};
            foreach(rd_en[j]) rd_en[j] dist {0:=100 - rd_dist, 1:=rd_dist};
            soft rd_dist inside {[60:80]};
        }

        function read_trans clone();
            read_trans rd_trans = new();
            rd_trans.rd_en = this.rd_en;
            rd_trans.rsp = this.rsp;
            rd_trans.pkg_id = this.pkg_id;
            return rd_trans;
        endfunction

        function string sprint();
            string s;
            s = {s, $sformatf("===================================\n")};
            s = {s, $sformatf("read_trans object info, pkg_id: %d\n", this.pkg_id)};
            foreach(this.rd_en[j])
                s = {s, $sformatf("rd_en[%d] = %d\n", j, this.rd_en[j])};
            s = {s, $sformatf("===================================\n")};
            return s;
        endfunction

    endclass:read_trans
    
    class write_trans;
        rand bit wr_en[];
        rand bit [7:0] din[];
        rand int pkg_id;
        bit rsp;
        rand int wr_dist;
        constraint cstr_low_write{
            foreach(wr_en[j]) 
                wr_en[j] == 0 -> soft din[j] == 8'hff;
            soft din.size inside {[1:8]};
            soft wr_en.size inside {[1:8]};
            soft wr_en.size == din.size;
            foreach(wr_en[j]) wr_en[j] dist {0:=90, 1:=10}; 
        }

        constraint cstr_high_write{
            foreach(wr_en[j]) 
                wr_en[j] == 0 -> soft din[j] == 8'hff;
            soft din.size inside {[1:8]};
            soft wr_en.size inside {[1:8]};
            soft wr_en.size == din.size;
            foreach(wr_en[j]) wr_en[j] dist {0:=10, 1:=90}; 
        }

        constraint cstr_medium_write{
            foreach(wr_en[j]) 
                wr_en[j] == 0 -> soft din[j] == 8'hff;
            soft din.size inside {[1:8]};
            soft wr_en.size inside {[1:8]};
            soft wr_en.size == din.size;
            foreach(wr_en[j]) wr_en[j] dist {0:=100 - wr_dist, 1:=wr_dist};
            soft wr_dist inside {[60:100]};
        }

        function write_trans clone();
            write_trans wr_trans = new();
            wr_trans.wr_en = this.wr_en;
            wr_trans.rsp = this.rsp;
            wr_trans.din = this.din;
            wr_trans.pkg_id = this.pkg_id;
            return wr_trans;
        endfunction

        function string sprint();
            string s;
            s = {s, $sformatf("===================================\n")};
            s = {s, $sformatf("write_trans object info, pkg_id: %d\n", this.pkg_id)};
            foreach(this.din[j])
                s = {s, $sformatf("wr_en[%d] = %d, din[%d] = %2x \n", j, this.wr_en[j], j, this.din[j])};
            s = {s, $sformatf("===================================\n")};
            return s;
        endfunction
 
    endclass: write_trans

    class cmd_data_gen;
        int rd_pkg_id = 0;
        int wr_pkg_id = 0;
        rand int wr_trans_loops = 2000;
        int rd_mode = 0;
        int wr_mode =0;
        read_trans read_req;
        read_trans read_rsp;
        write_trans write_req;
        write_trans write_rsp;
        write_mon_data_t write_mon_data;

        mailbox #(read_trans) mb_read_req;
        mailbox #(read_trans) mb_read_rsp;
        mailbox #(write_trans) mb_write_req;
        mailbox #(write_trans) mb_write_rsp;
        mailbox #(write_mon_data_t) mb_write_mon_data;

        function new();
            mb_read_req = new();
            mb_read_rsp = new();
            mb_write_req = new();
            mb_write_rsp = new();
            mb_write_mon_data = new();
        endfunction

        function void do_config(int rd_mode, int wr_mode);
            this.rd_mode = rd_mode;
            this.wr_mode = wr_mode;
        endfunction

        function void read_randomize_config(read_trans read_req);
            read_req.constraint_mode(0);
            case (this.rd_mode) 
                0: read_req.cstr_medium_read.constraint_mode(1);
                1: read_req.cstr_low_read.constraint_mode(1);
                2: read_req.cstr_high_read.constraint_mode(1);
            endcase
        endfunction

        function void write_randomize_config(write_trans write_req);
            write_req.constraint_mode(0);
            case (this.wr_mode) 
                0: write_req.cstr_medium_write.constraint_mode(1);
                1: write_req.cstr_low_write.constraint_mode(1);
                2: write_req.cstr_high_write.constraint_mode(1);
            endcase
        endfunction

        task send_read_transaction();
            read_req = new();
            this.read_randomize_config(read_req);
            assert (read_req.randomize() with {local::rd_pkg_id == pkg_id;}) 
            else $fatal("[RNDFAIL] read trans randomization failure!");
            rpt_pkg::rpt_msg("[read_trans]", read_req.sprint(), rpt_pkg::INFO, rpt_pkg::LOW);
            this.mb_read_req.put(read_req);
            this.mb_read_rsp.get(read_rsp);
            rpt_pkg::rpt_msg("[read_trans]", read_req.sprint(), rpt_pkg::INFO, rpt_pkg::LOW);
            assert (read_rsp.rsp)
            else   $fatal("[TRANSFAIL] read trans failure!");
            this.rd_pkg_id ++;
        endtask

        task send_write_transaction();
            write_req = new();
            this.write_randomize_config(write_req);
            assert (write_req.randomize() with {local::wr_pkg_id == pkg_id;}) 
            else $fatal("[RNDFAIL] write trans randomization failure!");
            rpt_pkg::rpt_msg("[write_trans]", write_req.sprint(), rpt_pkg::INFO, rpt_pkg::LOW);
            this.mon_write_data(write_req);
            this.mb_write_req.put(write_req);
            this.mb_write_rsp.get(write_rsp);
            rpt_pkg::rpt_msg("[write_trans]", write_req.sprint(), rpt_pkg::INFO, rpt_pkg::LOW);
            assert (write_rsp.rsp)
            else   $fatal("[TRANSFAIL] write trans failure!");
            this.wr_pkg_id++;
        endtask

        task mon_write_data(write_trans write_req);
            foreach(write_req.wr_en[j])
                if (write_req.wr_en[j]) begin
                    this.write_mon_data.data = write_req.din[j];
                    this.mb_write_mon_data.put(this.write_mon_data);
                    this.write_mon_data.id ++;
                end
        endtask 

        task wrap_rdtrans();
            forever begin
                this.send_read_transaction();
            end 
        endtask

        task wrap_wrtrans();
            repeat(20000) begin
                this.send_write_transaction();
            end 
        endtask  

        task run();
            fork
                wrap_rdtrans();
                wrap_wrtrans();
            join_any
            #200us;
            rpt_pkg::do_report();
            $stop();
        endtask
    endclass: cmd_data_gen

    class read_driver;
        local virtual read_intf rd_if;

        mailbox #(read_trans) mb_read_req;
        mailbox #(read_trans) mb_read_rsp;
        
        function void set_interface(virtual read_intf rd_if);
            this.rd_if = rd_if;
        endfunction

        task run();
            wait_rst();
            this.do_drive();
        endtask

        task do_drive();
            read_trans read_req;
            read_trans read_rsp;
            forever begin
                this.mb_read_req.get(read_req);
                this.do_read(read_req);
                read_rsp = read_req.clone();
                read_rsp.rsp = 1;
                mb_read_rsp.put(read_rsp);
            end
        endtask

        task do_read(read_trans read_req);
            foreach (read_req.rd_en[j]) begin
                //@(posedge this.rd_if.rd_clk iff (this.rd_if.drv_ck.empt === 1'b0));
                @(posedge this.rd_if.rd_clk);
                this.rd_if.drv_ck.rd_en <= read_req.rd_en[j];
            end
            this.do_idle();
        endtask

        task do_idle();
            @(posedge this.rd_if.rd_clk);
            this.rd_if.drv_ck.rd_en <= 0;
        endtask

        task wait_rst();
            @(posedge this.rd_if.rd_clk iff this.rd_if.rst_n === 1'b1);
        endtask

    endclass: read_driver

    class read_monitor;
        local virtual read_intf rd_if;
        static read_mon_data_t read_mon_data;
        mailbox #(read_mon_data_t) mb_read_mon_data;
        static logic rd_en_next;
    
        function new();
            mb_read_mon_data = new();
        endfunction
        
        function void set_interface(virtual read_intf rd_if);
            this.rd_if = rd_if;
        endfunction

        task run();
            wait_rst();
            fork
                this.gen_rd_en();
                this.mon_trans();
            join
        endtask

        task gen_rd_en();
            forever begin
                @(posedge this.rd_if.rd_clk);
                this.rd_en_next <= this.rd_if.mon_ck.rd_en & ~this.rd_if.mon_ck.empt; //read is valid or not depending on when read happened, empty is low or not                 
            end
        endtask

        task mon_trans();
            forever begin
                string s;
                @(posedge this.rd_if.rd_clk iff (this.rd_if.mon_ck.rd_en === 1'b1  && this.rd_if.mon_ck.empt === 1'b0));
                this.read_mon_data.data = this.rd_if.mon_ck.dout;
                mb_read_mon_data.put(this.read_mon_data);
                this.read_mon_data.id ++;
            end
        endtask
    
        task wait_rst();
            @(posedge this.rd_if.rd_clk iff this.rd_if.rst_n === 1'b1);
        endtask
        
    endclass: read_monitor

    class write_driver;
        local virtual write_intf wr_if;
        write_trans write_req;
        write_trans write_rsp;

        mailbox #(write_trans) mb_write_req;
        mailbox #(write_trans) mb_write_rsp;

        function void set_interface(virtual write_intf wr_if);
            this.wr_if = wr_if;
        endfunction

        task run();
            wait_rst();
            do_drive();
        endtask

        task do_drive();
            forever begin
                mb_write_req.get(this.write_req);
                this.do_write(this.write_req);
                this.write_rsp= this.write_req.clone();
                this.write_rsp.rsp = 1;
                mb_write_rsp.put(this.write_rsp);
            end
        endtask

        task do_write(write_trans write_req);
            foreach(write_req.din[j]) begin
                string s;
                s = $sformatf("wr_en = %d, wr_data=%x", write_req.wr_en[j], write_req.din[j]);
                rpt_pkg::rpt_msg("[write_action]", s, rpt_pkg::INFO, rpt_pkg::LOW);
                if (write_req.wr_en[j] == 1'b1) begin
                    @(posedge this.wr_if.wr_clk iff this.wr_if.full === 1'b0);
                    this.wr_if.drv_ck.wr_en <= write_req.wr_en[j];
                    this.wr_if.drv_ck.din <= write_req.din[j];
                end
                else
                    this.do_idle();
            end
            this.do_idle();
        endtask

        task do_idle();
            @(posedge this.wr_if.wr_clk);
            //this.wr_if.drv_ck.din <= 8'hff;
            this.wr_if.drv_ck.wr_en <=0;
        endtask

        task wait_rst();
            @(posedge this.wr_if.wr_clk iff this.wr_if.rst_n === 1'b1);
        endtask

    endclass: write_driver

    class write_monitor;
        local virtual write_intf wr_if;
        write_mon_data_t wr_mon_data;
        mailbox #(write_mon_data_t) mb_wr_mon_data;
        static logic [7:0] wr_valid_data; 
        static logic [7:0] wr_valid_data_next; 

        function new();
            mb_wr_mon_data = new();
        endfunction
        
        function void set_interface(virtual write_intf wr_if);
            this.wr_if = wr_if;
        endfunction

        task gen_write_valid_data();
            forever begin
                @(posedge this.wr_if.wr_clk);
                this.wr_valid_data <= this.wr_if.mon_ck.din;                     
            end
        endtask

        task gen_write_valid_data_next();
            forever begin
                @(posedge this.wr_if.wr_clk);
                this.wr_valid_data_next <= this.wr_valid_data;         
            end
        endtask
                   
        task run();
            wait_rst();
            fork
                this.mon_trans();
                //this.gen_write_valid_data();
                //this.gen_write_valid_data_next();
            join
        endtask

        task mon_trans();
            forever begin
                @(posedge this.wr_if.wr_clk iff (this.wr_if.mon_ck.full === 1'b0 && this.wr_if.mon_ck.wr_en === 1'b1));
                this.wr_mon_data.data = this.wr_if.mon_ck.din;
                mb_wr_mon_data.put(this.wr_mon_data);
                this.wr_mon_data.id ++;               
            end
        endtask 

        task wait_rst();
            @(posedge this.wr_if.wr_clk iff this.wr_if.rst_n === 1'b1);
        endtask

    endclass: write_monitor

endpackage