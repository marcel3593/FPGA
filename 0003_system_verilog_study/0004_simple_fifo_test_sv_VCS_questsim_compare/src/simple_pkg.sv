package simple_pkg;

class sample;

    static  logic rd_en_next_1;
    static  logic rd_en_next_2;
    static  logic [3:0] rd_addr_c_1;
    static  logic [3:0] wr_addr_c_1;
    static  logic [7:0] dout_data;
    static  logic [7:0] din_data;
    local virtual read_interface rd_if;
    local virtual write_interface wr_if;
    logic [0:15][7:0] wr_data;

    function void set_interface(virtual read_interface rd_if, virtual write_interface wr_if);
        this.rd_if = rd_if;
        this.wr_if = wr_if;
    endfunction

    //monitor
    task run();
        rpt_pkg::clean_log();
        gen();
        fork
          read_monitor_1();
          write_monitor_1();
          gen_rd_en_next_1();
          mon_all_signal_1();
        join_none
        write_driver_1();
        read_drive_1();
    endtask

    task gen();
        foreach(wr_data[j]) begin
            wr_data[j] = j;
        end
    endtask

    task write_driver_1();
        @(posedge wr_if.clk iff wr_if.rst_n === 1'b1);
        wr_if.drv_ck.wr_en <= 0;
        wr_if.drv_ck.din   <= 0;
        foreach(wr_data[j]) begin
            @(posedge wr_if.clk);
            wr_if.drv_ck.wr_en <=1;
            wr_if.drv_ck.din   <= wr_data[j];
            //print_write_data_1(wr_en, din);
        end
        @(posedge wr_if.clk);
        wr_if.drv_ck.wr_en <= 0;
        wr_if.drv_ck.din   <= 8'hff;
        //print_write_data_1(wr_en, din);
    endtask

    task write_monitor_1();  
        @(posedge wr_if.clk iff wr_if.rst_n === 1'b1);
        forever begin
          @(posedge wr_if.clk iff (wr_if.mon_ck.wr_en === 'b1));
          din_data = wr_if.mon_ck.din;
          print_write_data_1(wr_if.mon_ck.wr_en, din_data);
        end

    endtask

    task read_drive_1();
        @(posedge rd_if.clk iff rd_if.rst_n === 1'b1);
        forever begin
            @(posedge rd_if.clk);
                rd_if.drv_ck.rd_en <= 1;
        end
    endtask

    task read_monitor_1();
        automatic int i = 0;
        @(posedge rd_if.clk iff rd_if.rst_n === 1'b1);
        forever begin
            @(posedge rd_if.clk iff rd_en_next_1 === 'b1);
            dout_data = rd_if.mon_ck.dout;
            print_read_data_1(rd_if.mon_ck.rd_en, dout_data);
            i = i + 1;
            if (i==16) begin
                #1step;
                $stop();
            end
        end
    endtask

    task gen_rd_en_next_1();
        forever begin
            @(posedge rd_if.clk);
            rd_en_next_1 <= rd_if.mon_ck.rd_en;
            rd_en_next_2 <= rd_en_next_1;
        end
    endtask

    task mon_all_signal_1();
        string s;
        forever begin
            @(posedge rd_if.clk);
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


endclass //className

endpackage
