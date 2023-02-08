`timescale 1ns/1ps

interface lcd_interface(input lcd_clk, input lcd_rst);
    logic          lcd_bl      ;
    logic  [23:0]  lcd_rgb     ;
    logic          lcd_hs      ;
    logic          lcd_vs      ;
    logic          lcd_de      ;

    clocking  mon_ck @(posedge lcd_clk);
        default input #1 output #1;
        input lcd_bl, lcd_rgb, lcd_hs, lcd_vs, lcd_de;
    endclocking 
endinterface //interfacename


module tb_lcd_display ();
    logic           sys_clk         ;
    logic           sys_rst_n       ;
    logic           lcd_clk         ;
    logic           lcd_rst         ;
    logic           lcd_bl          ;
    logic   [23:0]  lcd_rgb         ;
    logic           lcd_hs          ;
    logic           lcd_vs          ;
    logic           lcd_de          ;


    lcd_display dut(
        .sys_clk  (sys_clk  )   ,
        .sys_rst_n(sys_rst_n)   ,
        .lcd_clk  (lcd_clk  )   ,
        .lcd_rst  (lcd_rst  )   ,
        .lcd_bl   (lcd_bl   )   ,
        .lcd_rgb  (lcd_rgb  )   ,
        .lcd_hs   (lcd_hs   )   ,
        .lcd_vs   (lcd_vs   )   ,
        .lcd_de   (lcd_de   )   
    );

    initial begin    
        sys_rst_n <=0;
        #30 sys_rst_n <=1;
    end
    
    initial begin
        sys_clk <= 1;
        forever #10 sys_clk<=~sys_clk;
    end

    lcd_interface inf(lcd_clk, lcd_rst);

    assign inf.lcd_bl = lcd_bl;
    assign inf.lcd_rgb = lcd_rgb;
    assign inf.lcd_hs = lcd_hs;
    assign inf.lcd_vs = lcd_vs;
    assign inf.lcd_de = lcd_de;

    
    initial begin
        import lcd_pkg::*;
        import rpt_pkg::*;
        base_test test;
        test = new();
        test.set_interface(inf);
        test.run();
    end

endmodule