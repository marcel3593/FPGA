package lcd_pkg;

import rpt_pkg::*;

static int HSYNC_T = 128 ;
static int HBPH_T = 88;
static int HLBD_T =  0;
static int HDATA_T = 800;
static int HRBD_T = 0;
static int HFPH_T = 40;
static int VSYNC_T = 2;
static int VBPH_T = 33;
static int VTBD_T = 0;
static int VDATA_T = 480;
static int VBBD_T = 0;
static int VFPH_T = 10;
 
static int H_T = HSYNC_T + HBPH_T + HLBD_T + HDATA_T + HRBD_T + HFPH_T;
static int V_T = VSYNC_T + VBPH_T + VTBD_T + VDATA_T + VBBD_T + VFPH_T;

class monitor;
    int h_index;  //row index
    int v_index;  //frame index

    virtual lcd_interface inf;

    function void set_interface(virtual lcd_interface inf);
        this.inf = inf;
    endfunction 

    task run();
        fork
            this.get_hsync_timing();
            this.get_vsync_timing();
            this.get_valid_data();      
        join
    endtask

    task get_hsync_timing();
            int loop = 0;
            int h_c = 0;
            int hsync_c = 0;
            int hsync_pre_data_c = 0;
            int hsync_data_c = 0;
            int hsync_after_data_c = 0;
            int v_data_valid = 0;
            @(posedge this.inf.lcd_rst);
            forever begin: hsync
                @(posedge this.inf.mon_ck.lcd_hs);
                if (loop != 'b0 ) begin
                    disable h_c_task;
                    if (v_data_valid == 'b1 )
                        disable hsync_after_data_c_task;
                    else
                        disable hsync_pre_data_c_task;
                    // check timing
                    this.h_timing_check(
                        h_c ,
                        hsync_c ,
                        hsync_pre_data_c ,
                        hsync_data_c ,
                        hsync_after_data_c ,
                        v_data_valid
                    );
                end
                //reset all counts
                h_c = 0;
                hsync_c = 0;
                hsync_pre_data_c = 0;
                hsync_data_c = 0;
                hsync_after_data_c = 0;
                v_data_valid = 0;
                if (this.h_index <= VDATA_T ) begin
                    this.h_index = this.h_index + 1;   //means hsync started
                    v_data_valid = ( this.h_index > (VSYNC_T + VBPH_T + VTBD_T) &&  this.h_index <= (VSYNC_T + VBPH_T + VTBD_T + VDATA_T) ) ? 1 : 0;
                end
                else
                    this.h_index = 0;
                fork: h_c_task
                    this.count_ck(h_c);
                join_none
                fork: hsync_c_task
                    this.count_ck(hsync_c);
                join_none
                @(negedge this.inf.mon_ck.lcd_hs);
                disable hsync_c_task;
                fork: hsync_pre_data_c_task
                    this.count_ck(hsync_pre_data_c);
                join_none
                if (v_data_valid == 'b1 ) begin
                    @(posedge this.inf.mon_ck.lcd_de);
                    disable hsync_pre_data_c_task;
                    fork: hsync_data_c_task
                        this.count_ck(hsync_data_c);
                    join_none
                    @(negedge this.inf.mon_ck.lcd_de);
                    disable hsync_data_c_task;
                    fork: hsync_after_data_c_task
                        this.count_ck(hsync_after_data_c);
                    join_none
                end
                loop = loop + 1;
            end
    endtask

    task get_vsync_timing();
        int loop = 0;
        int v_c = 0;
        int vsync_c = 0;
        @(posedge this.inf.lcd_rst);
        forever begin
            @(posedge this.inf.lcd_vs);
            this.v_index = this.v_index + 1;
                if (loop != 'b0) begin
                    disable v_c_task;
                    //check timing
                    this.v_timing_check(v_c, vsync_c);                    
                end
                fork: v_c_task
                    this.count_ck(v_c);
                join_none
                fork: vsync_c_task
                    this.count_ck(vsync_c);
                join_none
            @(negedge this.inf.lcd_vs);
            disable vsync_c_task;
            loop = loop + 1;
        end

    endtask

    task count_ck (ref int cnt);
        forever begin
            @(posedge this.inf.lcd_clk);
            cnt = cnt + 1;
        end
    endtask

    task get_valid_data();
        logic [23:0] rgb_data[];
        int px=0;
        string i,s;
        @(posedge this.inf.lcd_rst);
        forever begin
            rgb_data = new[HDATA_T];
            fork: sample_task
                forever begin
                    @(posedge this.inf.lcd_clk iff this.inf.mon_ck.lcd_de == 1'b1);
                    rgb_data[px] = this.inf.mon_ck.lcd_rgb;
                    px = px + 1;
                end
            join_none
            @(negedge this.inf.mon_ck.lcd_de);
            disable sample_task;
            px = 0;
            //send data to checker
            i = $sformatf("[video data] h_index=%d, v_index=%d", this.h_index, this.v_index);
            s = "\n";
            foreach(rgb_data[j])
                s = {s, $sformatf("%d,%x\n",j,rgb_data[j])};
            rpt_pkg::rpt_msg(i,s,rpt_pkg::INFO, rpt_pkg::MEDIUM);
        end
    endtask

    function void h_timing_check(
        int h_c ,
        int hsync_c ,
        int hsync_pre_data_c ,
        int hsync_data_c ,
        int hsync_after_data_c ,
        int v_data_valid
    );
        string s;
        if (v_data_valid == 'b1) begin
            s = $sformatf("h_index=%d, v_index=%d,   v_data_valid = %d, h_c(hc_c_exp) = %d(%d), hsync_c(hsync_c_exp) = %d(%d), hsync_pre_data_c(hsync_pre_data_c_exp) = %d(%d), hsync_data_c(hsync_data_c_exp) = %d(%d), hsync_after_data_c(hsync_after_data_c_exp)=%d(%d)",
                         this.h_index, this.v_index, v_data_valid, h_c,H_T,hsync_c,HSYNC_T,hsync_pre_data_c,HBPH_T + HLBD_T,hsync_data_c,HDATA_T,hsync_after_data_c,HRBD_T + HFPH_T);
            if ( (h_c == H_T) && (hsync_c == HSYNC_T) && (hsync_pre_data_c == HBPH_T + HLBD_T) 
            && (hsync_data_c == HDATA_T ) && (hsync_after_data_c == HRBD_T + HFPH_T)) rpt_pkg::rpt_msg("[h_timing]",s,rpt_pkg::WARNING, rpt_pkg::HIGH);
            else rpt_pkg::rpt_msg("[h_timing_error]",s,rpt_pkg::ERROR, rpt_pkg::HIGH);
        end
        else begin
            s = $sformatf("h_index=%d, v_index=%d,   v_data_valid = %d, h_c(hc_c_exp) = %d(%d), hsync_c(hsync_c_exp) = %d(%d), hsync_pre_data_c(hsync_pre_data_c_exp) = %d(%d)",
                         this.h_index, this.v_index, v_data_valid, h_c,H_T,hsync_c,HSYNC_T,hsync_pre_data_c,HBPH_T + HLBD_T + HDATA_T + HRBD_T + HFPH_T);
            if ( (h_c == H_T) && (hsync_c == HSYNC_T) && 
            (hsync_pre_data_c == HBPH_T + HLBD_T + HDATA_T + HRBD_T + HFPH_T )) rpt_pkg::rpt_msg("[h_timing]",s,rpt_pkg::WARNING, rpt_pkg::HIGH);
            else rpt_pkg::rpt_msg("[h_timing_error]",s,rpt_pkg::ERROR, rpt_pkg::HIGH);
        end
    endfunction

    function void v_timing_check(
        int v_c,
        int vsync_c
    );
        int v_c_exp = H_T * V_T;
        int vsync_c_exp = H_T * VSYNC_T;

        string s;
        s = $sformatf("h_index=%d, v_index=%d,   v_c(v_c_exp) = %d(%d), vsync_c(vsync_c_exp) = %d(%d)",this.h_index, this.v_index,v_c,v_c_exp,vsync_c,vsync_c_exp);
        if  ((v_c == v_c_exp) && (vsync_c == vsync_c_exp)) rpt_pkg::rpt_msg("[v_timing]",s,rpt_pkg::WARNING, rpt_pkg::HIGH);
        else   rpt_pkg::rpt_msg("[v_timing_error]",s,rpt_pkg::ERROR, rpt_pkg::HIGH);
    endfunction


endclass



class base_test;
    virtual lcd_interface inf;
    monitor monitor_inst;

    function new;
        monitor_inst = new();
    endfunction

    function void set_interface(virtual lcd_interface inf);
        this.inf = inf;
        this.monitor_inst.set_interface(this.inf);
    endfunction 

    task run();
        rpt_pkg::clean_log();
        this.monitor_inst.run();
    endtask

endclass

endpackage