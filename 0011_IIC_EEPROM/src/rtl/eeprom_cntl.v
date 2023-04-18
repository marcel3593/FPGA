module eeprom_cntl (
  input                sys_clk      ,  
  input                sys_rst_n    ,  
  input       [1:0]    cmd          ,
  inout       [7:0]    data         ,
  input                buffer_reset , 
  input                buffer_rd_en ,
  input                buffer_wr_en ,  
  output               buffer_empty ,
  output               buffer_full  ,
  output reg           error        ,
  output               busy         ,
  output               scl          ,
  inout                sda    
);
    parameter IIC_CLK_RATE_DIV = 16'd500;  //!!
    parameter EEPOM_NOP  = 2'b00 ;
	  parameter EEPOM_WR   = 2'b01 ;
	  parameter EEPOM_RD   = 2'b10 ;
	  parameter EEPOM_LDA  = 2'b11 ;
    parameter CLK_FREQ = 32'd50; //Mhz
    
    localparam tWR = 32'd20_000*CLK_FREQ; // corresponding clock period of 20ms
    localparam tBUF = 32'd5*CLK_FREQ; // corresponding clock period of 4.7us

    wire [7:0] data_in;
    wire [7:0] data_out;
    reg [1:0] cmd_reg;
    wire cmd_pulse;
    reg [7:0]  device_addr_reg;
    reg [15:0] word_address_reg;

    reg  [8:0] fsm_n_s;
    reg  [8:0] fsm_c_s;
    wire       fsm_switch_flag;

	  localparam FSM_IDLE    =   9'b000000000 ;       
	  localparam FSM_START   =   9'b000000010 ;        
	  localparam FSM_DA      =   9'b000000100 ;     
	  localparam FSM_WA      =   9'b000001000 ;     
	  localparam FSM_DA2     =   9'b000010000 ;      
	  localparam FSM_READ    =   9'b000100000 ;       
	  localparam FSM_WRITE   =   9'b001000000 ;        
	  localparam FSM_STOP    =   9'b010000000 ;     
	  localparam FSM_DELAY    =  9'b100000000 ;     

    wire eeprom_read_write_status;
    
    reg [7:0] trans_byte_cnts;
    reg [31:0] delay_cnts;
    wire delay_done;

    wire fifo_rd_en;
    wire fifo_empty;
    wire fifo_wr_en;
    wire fifo_full;
    wire [7:0] fifo_din;
    wire [7:0] fifo_dout;
    wire fifo_reset;

	  localparam IIC_IDLE          = 6'b000000;    
	  localparam IIC_START         = 6'b000001;     
	  localparam IIC_WRITE         = 6'b000010;     
	  localparam IIC_READ          = 6'b000100;    
	  localparam IIC_READ_LAST     = 6'b001000;         
	  localparam IIC_STOP          = 6'b010000;    
	  localparam IIC_RATE_CONFIG   = 6'b100000;   

    wire iic_fifo_wr_en;
    wire iic_fifo_rd_en;
    reg  [5:0] iic_cmd;
    reg  [7:0] iic_data_in;
    wire [7:0] iic_data_out;
    wire iic_done;
    wire [1:0] iic_status;
    wire iic_error;
    

    //========================
    // --input output handle--
    //=======================
    
    //cmd_reg
    always @(posedge sys_clk or negedge sys_rst_n) begin
      if (!sys_rst_n)
        cmd_reg <= EEPOM_NOP;
      else if (cmd == EEPOM_RD || cmd == EEPOM_WR)
        cmd_reg <= cmd;
    end
    
    assign cmd_pulse = (cmd_reg == cmd || cmd == EEPOM_LDA || cmd == EEPOM_NOP) ? 0 : 1;

    //word_address_reg
    always @(posedge sys_clk or negedge sys_rst_n) begin
      if (!sys_rst_n)
        word_address_reg <= 0;
      else if (cmd == EEPOM_WR || cmd == EEPOM_RD)
        word_address_reg <= {data_in,word_address_reg[15:8]};
    end

    //device_addr_reg
    always @(posedge sys_clk or negedge sys_rst_n) begin
      if (!sys_rst_n)
        device_addr_reg <= 8'b1010_0000;
      else if (cmd == EEPOM_LDA)
        device_addr_reg <= data_in; //touch the R/W bit also, if use current address read, set the R/W=1
      else if (fsm_c_s == FSM_WA && cmd_reg == EEPOM_RD)
        device_addr_reg[0] <=1;
      else if (fsm_c_s == FSM_STOP)
        device_addr_reg[0] <=0;
    end
    
    //data inout port
    assign data = (cmd == EEPOM_NOP && buffer_wr_en == 1'b0) ? data_out : 8'bz;
    assign data_in = data;

    //===============
    // --EEPROM FSM--
    //===============
    assign eeprom_read_write_status = device_addr_reg[0]; //0:write; 1:read
    assign iic_error = iic_status[1];
    assign fsm_switch_flag = (fsm_c_s == fsm_n_s) ? 0 : 1;

    always @(posedge sys_clk or negedge sys_rst_n) begin
      if (!sys_rst_n)
        fsm_c_s <= FSM_IDLE;
      else
        fsm_c_s <= fsm_n_s;
    end

    always @(*) begin
      case (fsm_c_s)
        FSM_IDLE : begin
          if (cmd_pulse == 1'b1)
            fsm_n_s = FSM_START;
          else
            fsm_n_s = FSM_IDLE;
        end
        FSM_START : begin
          if (iic_done == 1'b1 && eeprom_read_write_status == 1'b0)
            fsm_n_s = FSM_DA;
          else if (iic_done == 1'b1 && eeprom_read_write_status == 1'b1)
            fsm_n_s = FSM_DA2;
          else
            fsm_n_s = FSM_START;
        end
        FSM_DA :  begin
          if (iic_done == 1'b1 && iic_error == 1'b0)
            fsm_n_s = FSM_WA;
          else if (iic_done == 1'b1 && iic_error == 1'b1)
            fsm_n_s = FSM_STOP;
          else
            fsm_n_s = FSM_DA;
        end
        FSM_WA: begin
          if (iic_done == 1'b1 && iic_error == 1'b1)
            fsm_n_s = FSM_STOP;
          else if (iic_done == 1'b1 && trans_byte_cnts == 8'd1 && cmd_reg == EEPOM_WR)
            fsm_n_s = FSM_WRITE;
          else if (iic_done == 1'b1 && trans_byte_cnts == 8'd1 && cmd_reg == EEPOM_RD)
            fsm_n_s = FSM_START;
          else
            fsm_n_s = FSM_WA;
        end
        FSM_WRITE: begin
          if (iic_done == 1'b1 && iic_error == 1'b1)
            fsm_n_s = FSM_STOP;
          else if (iic_done == 1'b1 && fifo_empty == 1'b1)
            fsm_n_s = FSM_STOP;
          else
            fsm_n_s = FSM_WRITE;
        end
        FSM_DA2 : begin
          if (iic_done == 1'b1 && iic_error == 1'b1)
            fsm_n_s = FSM_STOP;
          else if (iic_done == 1'b1)
            fsm_n_s = FSM_READ;
          else
            fsm_n_s = FSM_DA2;             
        end
        FSM_READ : begin
          if (iic_done == 1'b1 && trans_byte_cnts == 8'd31)
            fsm_n_s = FSM_STOP;
          else
            fsm_n_s = FSM_READ;             
        end          
        FSM_STOP : begin
          if (iic_done == 1'b1)
            fsm_n_s = FSM_DELAY;
          else
            fsm_n_s = FSM_STOP;
        end
        FSM_DELAY: begin
          if (delay_done == 1'b1)
            fsm_n_s = FSM_IDLE;
          else
            fsm_n_s = FSM_DELAY;             
        end          
        default: begin
          fsm_n_s = FSM_IDLE;
        end     
      endcase  
    end

    //fsm output

    //trans_byte_cnts
    always @(posedge sys_clk or negedge sys_rst_n) begin
      if (!sys_rst_n)
        trans_byte_cnts <=0;
      else if (fsm_switch_flag == 1'b1)
        trans_byte_cnts <=0;
      else if (iic_done == 1'b1)
        trans_byte_cnts <= trans_byte_cnts + 1;
    end

    assign delay_done = ((cmd_reg == EEPOM_WR && delay_cnts == tWR) || (cmd_reg == EEPOM_RD && delay_cnts == tBUF)) ? 1 : 0;
    //tWR counts
    always @(posedge sys_clk or negedge sys_rst_n) begin
      if (!sys_rst_n)
        delay_cnts <=0;
      else if (fsm_switch_flag == 1'b1)
        delay_cnts <=0;
      else if (fsm_c_s == FSM_DELAY)
        delay_cnts <= delay_cnts + 1;
    end


    //iic master interface
    always @(*) begin
        case (fsm_n_s)
          FSM_IDLE : begin
            iic_cmd = IIC_IDLE;
            iic_data_in = 8'd0;
          end
          FSM_START: 
            if (fsm_switch_flag == 1'b1) begin
              iic_cmd = IIC_START;
              iic_data_in = 8'd0;            
            end
            else begin
              iic_cmd = IIC_IDLE;
              iic_data_in = 8'd0;                  
            end
          FSM_DA     : 
            if (fsm_switch_flag == 1'b1) begin
              iic_cmd = IIC_WRITE;
              iic_data_in = device_addr_reg;
            end   
            else begin
              iic_cmd = IIC_IDLE;
              iic_data_in = 8'd0;            
            end
          FSM_WA     : 
            if (fsm_switch_flag == 1'b1) begin
              iic_cmd = IIC_WRITE;
              iic_data_in = word_address_reg[15:8];
            end  
            else if (iic_done == 1'b1) begin
              iic_cmd = IIC_WRITE;
              iic_data_in = word_address_reg[7:0];
            end
            else begin
              iic_cmd = IIC_IDLE;
              iic_data_in = 8'd0;            
          end 
          FSM_WRITE   :
            if (fsm_switch_flag == 1'b1 || iic_done == 1'b1) begin
              iic_cmd = IIC_WRITE;
              iic_data_in = fifo_dout;
            end  
            else begin
              iic_cmd = IIC_IDLE;
              iic_data_in = 8'd0;            
          end 
          FSM_DA2    : 
            if (fsm_switch_flag == 1'b1) begin
              iic_cmd = IIC_WRITE;
              iic_data_in = device_addr_reg;
            end   
            else begin
              iic_cmd = IIC_IDLE;
              iic_data_in = 8'd0;            
            end
          FSM_READ    : 
            if ((fsm_switch_flag == 1'b1 || iic_done == 1'b1) && trans_byte_cnts < 30) begin
              iic_cmd = IIC_READ;
              iic_data_in = 0;
            end   
            else if (iic_done == 1'b1) begin
              iic_cmd = IIC_READ_LAST;
              iic_data_in = 0;
            end   
            else begin
              iic_cmd = IIC_IDLE;
              iic_data_in = 8'd0;            
            end
          FSM_STOP    :
            if (fsm_switch_flag == 1'b1) begin
              iic_cmd = IIC_STOP;
              iic_data_in = 8'd0;            
            end
            else begin
              iic_cmd = IIC_IDLE;
              iic_data_in = 8'd0;                  
            end
          default: begin
              iic_cmd = IIC_IDLE;
              iic_data_in = 8'd0;  
          end     
        endcase
    end
    
    //fifo handle

    assign fifo_wr_en = (fsm_c_s == FSM_IDLE ) ? buffer_wr_en : iic_fifo_wr_en; //external only can write the fifo when didn't do any EEPROM read/write
    assign fifo_rd_en = (fsm_c_s == FSM_IDLE ) ? buffer_rd_en : iic_fifo_rd_en;
    assign fifo_din = (fsm_c_s == FSM_IDLE) ? data_in : iic_data_out;

    assign iic_fifo_rd_en = ( fsm_n_s == FSM_WRITE && (fsm_switch_flag == 1'b1 || iic_done == 1'b1) && fifo_empty == 1'b0) ? 1'b1 : 1'b0;
    assign iic_fifo_wr_en = (fsm_c_s == FSM_READ && iic_done == 1'b1) ? 1'b1 : 1'b0;
    assign fifo_reset = buffer_reset;
    assign buffer_empty = fifo_empty;
    assign buffer_full = fifo_full;
    assign data_out = fifo_dout;
    

    //error and busy handle
    assign busy = (fsm_c_s == FSM_IDLE && fsm_n_s == FSM_IDLE) ? 1'b0 : 1'b1;
    
    always @(posedge sys_clk or negedge sys_rst_n) begin
      if (!sys_rst_n)
        error <=0;
      else if (cmd_pulse == 1'b1)
        error <=0;
      else if (iic_error == 1'b1)
        error <=1;
    end

    //===========================
    // --IIC and FIFO instance--
    //===========================

    iic_master #(
      .IIC_CLK_RATE_DIV(IIC_CLK_RATE_DIV)
    )
      u1_iic_master
    (
      .sys_clk       (sys_clk      ),  
      .sys_rst_n     (sys_rst_n    ),  
      .iic_cmd       (iic_cmd      ),
      .iic_data_in   (iic_data_in ),
      .iic_data_out  (iic_data_out  ),
      .iic_done      (iic_done     ),
      .iic_status    (iic_status   ),
      .scl           (scl          ),
      .sda           (sda          )
    );


    sync_fifo #(
      .DEPTH   (8'd32),
      .ffft_en (1'b1) 
    )
      u2_sync_fifo
    (
      .sys_clk     (sys_clk       ) ,  
      .sys_rst_n   (sys_rst_n     ) ,     
      .reset       (fifo_reset    ) ,
      .rd_en       (fifo_rd_en    ) ,
      .wr_en       (fifo_wr_en    ) ,
      .din         (fifo_din      ) ,
      .dout        (fifo_dout     ) ,
      .empty       (fifo_empty    ) ,
      .full        (fifo_full     ) 
    );

    endmodule
