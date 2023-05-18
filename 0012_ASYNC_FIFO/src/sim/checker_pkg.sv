package checker_pkg;

    import access_pkg::*;
    import rpt_pkg::*;


    class fifo_checker;
        read_mon_data_t read_mon_data;
        mailbox #(read_mon_data_t) mb_read_mon_data;
        write_mon_data_t wr_mon_data;
        mailbox #(write_mon_data_t) mb_wr_mon_data;
        write_mon_data_t wr_mon_data_raw;
        mailbox #(write_mon_data_t) mb_wr_mon_data_raw;

        read_mon_data_t write_packed_data_lower;
        read_mon_data_t write_packed_data_upper;
        read_mon_data_t write_packed_data_raw_lower;
        read_mon_data_t write_packed_data_raw_upper;

        task pack_write_data();
            this.mb_wr_mon_data.get(this.wr_mon_data);
            this.write_packed_data_lower.data[3:0] = this.wr_mon_data.data[7:4];
            this.write_packed_data_upper.data[3:0] = this.wr_mon_data.data[3:0];
            this.write_packed_data_lower.id = this.wr_mon_data.id*2;
            this.write_packed_data_upper.id = this.wr_mon_data.id*2 + 1;
            this.mb_wr_mon_data_raw.get(this.wr_mon_data_raw);
            this.write_packed_data_raw_lower.data[3:0] = this.wr_mon_data_raw.data[7:4];
            this.write_packed_data_raw_upper.data[3:0] = this.wr_mon_data_raw.data[3:0];
            this.write_packed_data_raw_lower.id = this.wr_mon_data_raw.id*2;
            this.write_packed_data_raw_upper.id = this.wr_mon_data_raw.id*2 + 1;            
        endtask

        task compare();
            bit cmp;
            string s;
            report_t rpt;
            severity_t svrt;
            this.pack_write_data();
            this.mb_read_mon_data.get(this.read_mon_data);
            if (this.read_mon_data.data == this.wr_mon_data.data && this.read_mon_data.id == this.wr_mon_data.id  
            && this.read_mon_data.data == this.wr_mon_data_raw.data && this.read_mon_data.id == this.wr_mon_data_raw.id) begin
                cmp = 1;
                rpt = rpt_pkg::INFO;
                svrt = rpt_pkg::MEDIUM;
            end
            else begin
                cmp = 0;
                rpt = rpt_pkg::ERROR;
                svrt = rpt_pkg::HIGH;
            end
            s = $sformatf("cmp = %d, rd_id = %d, rd_data = %8b, wr_id = %d, wr_data = %8b, wr_raw_id = %d, wr_raw_data = %8b\n", cmp, this.read_mon_data.id, this.read_mon_data.data, this.wr_mon_data.id, this.wr_mon_data.data
            , this.wr_mon_data_raw.id, this.wr_mon_data_raw.data);
            rpt_pkg::rpt_msg("[CMPOBJ]", s, rpt, svrt);
            //this.mb_read_mon_data.get(this.read_mon_data);
            //if (this.read_mon_data.data == this.write_packed_data_upper.data && this.read_mon_data.id == this.write_packed_data_upper.id 
            //&& this.read_mon_data.data == this.write_packed_data_raw_upper.data && this.read_mon_data.id == this.write_packed_data_raw_upper.id) begin
            //    cmp = 1;
            //    rpt = rpt_pkg::INFO;
            //    svrt = rpt_pkg::MEDIUM;
            //end
            //else begin
            //    cmp = 0;
            //    rpt = rpt_pkg::ERROR;
            //    svrt = rpt_pkg::HIGH;
            //end
            //s = $sformatf("cmp = %d, rd_id = %d, rd_data = %4b, wr_id = %d, wr_data = %4b, wr_raw_id = %d, wr_raw_data = %4b\n", cmp, this.read_mon_data.id, this.read_mon_data.data, this.write_packed_data_upper.id, this.write_packed_data_upper.data
            //, this.write_packed_data_raw_upper.id, this.write_packed_data_raw_upper.data);
            //rpt_pkg::rpt_msg("[CMPOBJ]", s, rpt, svrt);  
        endtask

        task run();
            forever begin
                this.compare();
            end
        endtask
    endclass: fifo_checker

endpackage