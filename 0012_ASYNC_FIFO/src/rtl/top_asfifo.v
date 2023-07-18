module top_asfifo #(
    parameter DEPTH = 32'd32,
    parameter WR_DW = 32'd8 , 
    parameter RD_DW = 32'd8 
)
(
    input                    wclk    ,
    input                    rclk    ,
    input                    rst_n   ,
    input                    wr_en   ,
    input                    rd_en   ,
    input   [WR_DW - 1 : 0]  din     ,
    output  [RD_DW - 1 : 0]  dout    ,
    output                   empty   ,
    output                   full       
);
    `include "clog2.vh"

    localparam RD_ADDRW = clog2(DEPTH);
    localparam WR_ADDRW = clog2(DEPTH);

    wire [WR_ADDRW : 0]     wptr         ;
    wire [WR_ADDRW - 1 : 0] w_addr_ram   ;
    wire [WR_ADDRW : 0]     w2rsync_wptr ;
    wire we                              ;
    wire [RD_ADDRW : 0]     rptr         ;
    wire [RD_ADDRW - 1 : 0] r_addr_ram   ;
    wire [RD_ADDRW : 0]     r2wsync_rptr ;


    dualport_ram  
    #(
        .DEPTH    (DEPTH   )  ,
        .WR_DW    (WR_DW   )  , 
        .RD_DW    (RD_DW   )  ,
        .WR_ADDRW (WR_ADDRW)  ,
        .RD_ADDRW (RD_ADDRW)  )
    u0_dualport_ram
    (
        .wclk       (wclk      )      ,
        .rst_n      (rst_n     )      ,
        .we         (we        )      ,
        .w_addr_ram (w_addr_ram)      ,
        .r_addr_ram (r_addr_ram)      ,
        .din        (din       )      ,
        .dout       (dout      )       
    );          

    //wr addr
    wr_addr_cntl #(
        .WR_ADDRW (WR_ADDRW)
    )
    u1_wr_addr_cntl
    (
        .wclk       (wclk      )  ,
        .rst_n      (rst_n     )  ,
        .full       (full      )  ,
        .wr_en      (wr_en     )  ,
        .wptr       (wptr      )  ,
        .we         (we        )  ,
        .w_addr_ram (w_addr_ram)   
    );
    
    //rd_addr
    rd_addr_cntl #(
        .RD_ADDRW (RD_ADDRW)
    )
    u2_rd_addr_cntl
    (
        .rclk       (rclk      )  ,
        .rst_n      (rst_n     )  ,
        .empty      (empty     )  ,
        .rd_en      (rd_en     )  ,
        .rptr       (rptr      )  ,
        .r_addr_ram (r_addr_ram)   
    );

    //full
    full_logic #(
        .RD_ADDRW (RD_ADDRW),
        .WR_ADDRW (WR_ADDRW)      
    )
    u3_full_logic
    (
        .r2wsync_rptr (r2wsync_rptr)  ,
        .wptr         (wptr        )  ,
        .full         (full        )   
    );    

    //empty
    empty_logic #(
        .RD_ADDRW (RD_ADDRW),
        .WR_ADDRW (WR_ADDRW)       
    )
    u4_empty_logic
    (
        .w2rsync_wptr (w2rsync_wptr)    ,
        .rptr         (rptr        )    ,
        .empty        (empty       )     
    );    

    //r2w sync
    r2w_sync # (
        .RD_ADDRW (RD_ADDRW)
    )
    u5_r2w_sync
    (
        .rptr         (rptr        )        ,
        .wclk         (wclk        )        ,
        .rclk         (rclk        )        ,
        .r2wsync_rptr (r2wsync_rptr)        
    );

    //w2r sync
    w2r_sync # (
        .WR_ADDRW(WR_ADDRW)
    )
    u6_w2r_sync
    (
        .wptr          (wptr          ),
        .wclk          (wclk          ),
        .rclk          (rclk          ),
        .w2rsync_wptr  (w2rsync_wptr  )
    );

endmodule