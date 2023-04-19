module top_uart_eeprom_iic(
    input           sys_clk         ,
    input           sys_rst_n       ,
    input           uart_rx         ,
    output          uart_tx         ,
    output          iic_scl         ,
    inout           iic_sda
);

    //uart rx
    wire [7:0] uart_rd_data;
    wire uart_rx_valid;
    wire uart_parity_error;
    wire uart_rx_busy;
    reg  uart_rx_valid_reg;
    

    //uart tx
    wire [7:0] uart_wr_data;
    reg uart_wr_en;
    wire uart_tx_busy;

    localparam EEPOM_NOP  = 2'b00 ;
	localparam EEPOM_WR   = 2'b01 ;
	localparam EEPOM_RD   = 2'b10 ;
	localparam EEPOM_LDA  = 2'b11 ;
        
    //eeprom_cntl
    reg  [1:0] eeprom_cntl_cmd;
    wire [7:0] eeprom_cntl_data;
    wire [7:0] eeprom_cntl_data_out;
    wire [7:0] eeprom_cntl_data_in;
    wire eeprom_cntl_buffer_wr_en;
    wire eeprom_cntl_buffer_full;
    reg  eeprom_cntl_buffer_rd_en;
    wire eeprom_cntl_buffer_empty;
    wire eeprom_cntl_error;
    wire eeprom_cntl_busy;
    wire eeprom_cntl_buffer_reset;

    reg  [15:0] eeprom_word_address_reg;
    wire [7:0] eeprom_cntl_word_address;
    
    //cntrl fsm gray code
    localparam FSM_UART_RD    = 2'b00;
    localparam FSM_EEPROM_PAGE_WR  = 2'b10;
    localparam FSM_EEPROM_PAGE_RD  = 2'b11;
    localparam FSM_UART_WR    = 2'b01;
    reg [1:0] fsm_c_s;  
    reg [1:0] fsm_n_s; 
    wire fsm_switch_flag;

    //cnts
    reg [3:0] fsm_cnt;
    reg fsm_even_odd_cnt;
    

    //input cntl
    assign eeprom_cntl_data = (eeprom_cntl_cmd == EEPOM_RD || eeprom_cntl_cmd == EEPOM_WR 
    || eeprom_cntl_buffer_wr_en == 1'b1) ? eeprom_cntl_data_in : 8'bz;
    assign eeprom_cntl_data_out = eeprom_cntl_data;

    //FSM logic
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            fsm_c_s <= FSM_UART_RD;
        else
            fsm_c_s <= fsm_n_s;
    end
    
    assign fsm_switch_flag = (fsm_c_s == fsm_n_s) ? 0: 1;

    always @(*) begin
        case (fsm_c_s)
            FSM_UART_RD: begin
                if ( eeprom_cntl_buffer_full == 1'b1)
                    fsm_n_s = FSM_EEPROM_PAGE_WR;
                else
                    fsm_n_s = FSM_UART_RD;
            end
            FSM_EEPROM_PAGE_WR : begin
                if (fsm_cnt == 4'hf && eeprom_cntl_busy == 1'b0)
                    fsm_n_s = FSM_EEPROM_PAGE_RD;
                else
                    fsm_n_s = FSM_EEPROM_PAGE_WR;
            end
            FSM_EEPROM_PAGE_RD:begin
                if (fsm_cnt == 4'hf && eeprom_cntl_busy == 1'b0)
                    fsm_n_s = FSM_UART_WR;
                else
                    fsm_n_s = FSM_EEPROM_PAGE_RD;
            end
            FSM_UART_WR : begin
                if ( eeprom_cntl_buffer_empty == 1'b1)
                    fsm_n_s = FSM_UART_RD;
                else
                    fsm_n_s = FSM_UART_WR;
            end
            default: fsm_n_s = FSM_UART_RD;
        endcase 
    end

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            fsm_cnt <=4'd0;
        else if (fsm_switch_flag == 1'b1)
            fsm_cnt <=4'd0;
        else if (fsm_cnt < 4'hf)
            fsm_cnt <= fsm_cnt + 4'd1;
    end

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            fsm_even_odd_cnt <=1'd0;
        else if (fsm_switch_flag == 1'b1)
            fsm_even_odd_cnt <=1'd0;
        else
            fsm_even_odd_cnt <= ~fsm_even_odd_cnt;
    end


    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            uart_rx_valid_reg <=8'd0;
        else
            uart_rx_valid_reg <= uart_rx_valid;
    end

    assign eeprom_cntl_buffer_wr_en = (uart_rx_valid_reg == 1'b1 && fsm_c_s == FSM_UART_RD) ? 1'b1 : 1'b0;
    assign eeprom_cntl_data_in =      (uart_rx_valid_reg == 1'b1 && fsm_c_s == FSM_UART_RD) ? uart_rd_data : eeprom_cntl_word_address;

    always @(*) begin
        if (fsm_cnt < 2 && fsm_c_s == FSM_EEPROM_PAGE_WR)
            eeprom_cntl_cmd = EEPOM_WR;
        else if (fsm_cnt < 2 && fsm_c_s == FSM_EEPROM_PAGE_RD)
            eeprom_cntl_cmd = EEPOM_RD;
        else 
            eeprom_cntl_cmd = EEPOM_NOP;        
    end

    assign eeprom_cntl_word_address = (fsm_cnt == 0) ? eeprom_word_address_reg[7:0] : eeprom_word_address_reg[15:8];

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            eeprom_word_address_reg <= 16'h0;
        else if (fsm_c_s == FSM_UART_WR && fsm_cnt == 4'd0)
            eeprom_word_address_reg <= eeprom_word_address_reg + 16'h20;
    end

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            uart_wr_en <= 1'b0;
            eeprom_cntl_buffer_rd_en <= 1'b0;
        end
        else if (fsm_c_s == FSM_UART_WR && uart_tx_busy == 1'b0 && fsm_even_odd_cnt == 1'b0) begin
            uart_wr_en <= 1'b1;
            eeprom_cntl_buffer_rd_en <= 1'b1;
        end
        else begin
            uart_wr_en <= 1'b0;
            eeprom_cntl_buffer_rd_en <= 1'b0;            
        end
    end

    assign uart_wr_data = eeprom_cntl_data_out;
    assign eeprom_cntl_buffer_reset = ((fsm_n_s == FSM_UART_RD || fsm_n_s == FSM_UART_RD) && fsm_switch_flag == 1'b1) ? 1'b1 : 1'b0;


uart_tx u1_uart_tx(
  .clk     (sys_clk),
  .rst_n   (sys_rst_n),
  .din     (uart_wr_data),
  .wr_en   (uart_wr_en),
  .tx      (uart_tx),
  .tx_busy (uart_tx_busy)    
);

uart_rx  u2_uart_rx(
  .clk          (sys_clk),
  .rst_n        (sys_rst_n),
  .rx           (uart_rx),
  .dout         (uart_rd_data),
  .valid        (uart_rx_valid),
  .parity_error (uart_parity_error),                          
  .rx_busy      (uart_rx_busy)                          
);


eeprom_cntl u3_eeprom_cntl(
  .sys_clk        (sys_clk)  ,  
  .sys_rst_n      (sys_rst_n)  ,  
  .cmd            (eeprom_cntl_cmd)  ,
  .data           (eeprom_cntl_data)  ,
  .buffer_reset   (eeprom_cntl_buffer_reset)  , 
  .buffer_rd_en   (eeprom_cntl_buffer_rd_en)  ,
  .buffer_wr_en   (eeprom_cntl_buffer_wr_en)  ,  
  .buffer_empty   (eeprom_cntl_buffer_empty)  ,
  .buffer_full    (eeprom_cntl_buffer_full)  ,
  .error          (eeprom_cntl_error)  ,
  .busy           (eeprom_cntl_busy)  ,
  .scl            (iic_scl)  ,
  .sda            (iic_sda)         
);

endmodule