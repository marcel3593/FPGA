module SPI_flash_controller(
  input                       sys_clk     ,
  input                       sys_rst_n   ,
  output                      mosi        ,
  input                       miso        ,
  output                      sck         ,
  output                      cs_n        ,
  input       [3:0]           cmd         ,
  input       [31:0]          addr        ,
  inout       [7:0]           data        , 
  output reg                  valid       , 
  output                      busy       
);

// flash cmd table
    parameter WE = 8'h06;
    parameter SE = 8'h20;
    parameter PP = 8'h02;
    parameter RD = 8'h03;

//flash timing unit is sys_clk
    parameter tSHSL = 4'd3; //50ns
    
    parameter tBP1  = 16'd2500;    //50 us
    parameter tBP2  = 16'd600;     //12 us
    `ifdef SIM
      parameter tSE   = 32'd500; //400ms
      parameter tPP   = 32'd500;  //3ms
    `endif
    `ifndef SIM
      parameter tSE   = 32'd20000000; //400ms
      parameter tPP   = 32'd150000;  //3ms
    `endif

//flash density
    parameter DENSITY= 8'd128;  //128MB 
    parameter ADDR_W= 8'd3;  //128MB 3byte address width


//controller cmd table
    parameter C_NOP = 4'b0000; //no action
    parameter C_SE =  4'b0001 ; //sector erase 
    parameter C_PP =  4'b0010 ; //page program
    parameter C_RD =  4'b0100 ; //read
    parameter C_LD =  4'b1000 ; //load_data  

//=============
// FSM
//=============


    //fsm stat define
    localparam FSM_IDLE   =  4'b0000;
    localparam FSM_WE     =  4'b0001;
    localparam FSM_WRITE  =  4'b0011;
    localparam FSM_READ   =  4'b0010;
    
    reg  [3:0] fsm_c_s;  //fsm current stat
    reg  [3:0] fsm_n_s;  //fsm next stat
    wire fsm_switch_flag;

    assign fsm_switch_flag = (fsm_c_s == fsm_n_s) ? 0 : 1;
    
    //input buffer
    reg  [3:0]  cmd_reg; //reg the cmd
    reg  [31:0] addr_reg; //reg the cmd
    reg  [7:0]  instruction;
    reg  [7:0]  spi_tx_data_buffer [0:255]; //tx data buffer
    reg  [8:0]  data_byte_cnt;               //how many tx data byte number need to be writen
    wire [7:0]  d_out;
    wire [7:0]  d_in;
    assign data = (cmd == C_LD || cmd == C_RD) ? 'Z : d_out;
    //assign data = (cmd == C_PP || cmd == C_SE || cmd == C_LD || cmd == C_RD) ? 'Z : d_out;
    assign d_in = data; 

    //spi interface
    reg  [1:0]  spi_reg_addr  ;
    wire [7:0]  spi_reg_data  ; 
    reg  [1:0]  spi_reg_cmd   ;
    wire [1:0]  spi_status    ;  
    reg         spi_en        ; 
    reg  [7:0]  spi_dout;
    wire [7:0]  spi_din;
    assign spi_reg_data = (spi_reg_cmd != 2'b10 ) ? spi_dout : 'Z;
    assign spi_din  =  spi_reg_data;
    
    //flag pulse
    reg         spi_en_reg;
    wire        spi_disable_pulse  ;   //negedge of spi_en
    reg         spi_status_1_reg   ;   //write empty reg
    reg         spi_status_0_reg   ;   //write empty reg
    wire        byte_writen_done_pulse ; //1byte writen done flag
    wire        byte_read_done_pulse ; //1byte read done flag
    reg        byte_data_ready ; //1byte read data ready flag
    
    //cnts
    reg  [7:0] fsm_cnt;
    reg  [8:0] writen_byte_cnt;
    reg  [8:0] writen_byte_max;
    reg  [7:0] read_byte_cnt;
    reg  [7:0] read_byte_max;    

    //delay counts
    reg [31:0] wait_cnt;
    reg [31:0] tW; //twait
    
    //output buffer
    reg  [7:0] rd_data_out;

    assign d_out  = rd_data_out;
  
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            fsm_c_s <= FSM_IDLE;
        else
            fsm_c_s <= fsm_n_s;
    end

    always @(fsm_c_s  or cmd or wait_cnt or tW) begin
      case (fsm_c_s)
        FSM_IDLE: begin
          case (cmd)
            C_NOP: fsm_n_s  = FSM_IDLE    ;
            C_SE : fsm_n_s  = FSM_WE      ;
            C_PP : fsm_n_s  = FSM_WE      ;
            C_RD : fsm_n_s  = FSM_READ    ;
            C_LD : fsm_n_s  = fsm_c_s ;
            default : fsm_n_s  = fsm_c_s ;
          endcase
        end
        FSM_WE: begin
          if (wait_cnt == tW)
            fsm_n_s  = FSM_WRITE   ;
          else
            fsm_n_s  = fsm_c_s ;
        end
        FSM_WRITE:
          if (wait_cnt == tW)
            fsm_n_s  = FSM_IDLE   ;
          else
            fsm_n_s  = fsm_c_s ;        
        FSM_READ:
          if (wait_cnt == tW)
            fsm_n_s  = FSM_IDLE   ;
          else
            fsm_n_s  = fsm_c_s ;              
      endcase
    end
    
    //===============
    //input buffer
    //===============
    always @(posedge sys_clk or negedge sys_rst_n) begin
      if (!sys_rst_n)
        cmd_reg <=0;
      else if (fsm_c_s == FSM_IDLE)
        cmd_reg <= cmd;
      else
        cmd_reg <= cmd_reg;
    end

    always @(posedge sys_clk or negedge sys_rst_n) begin
      if (!sys_rst_n)
        addr_reg <=0;
      else if (fsm_c_s == FSM_IDLE)
        addr_reg <= addr;
      else
        addr_reg <= addr_reg;
    end
    
    integer i;
    always @(posedge sys_clk or negedge sys_rst_n) begin
      if (!sys_rst_n)
        for (i=0;i<256;i=i+1)
          spi_tx_data_buffer[i] <=0;
      else if (cmd == C_LD && cmd_reg == C_PP) //page program mode
        spi_tx_data_buffer[data_byte_cnt] <= d_in;
      else
        ;
    end

    always @(posedge sys_clk or negedge sys_rst_n) begin
      if (!sys_rst_n)
        data_byte_cnt <= 0;
      else if (fsm_c_s == FSM_IDLE)
        data_byte_cnt <= 0;
      else if (cmd == C_LD && cmd_reg == C_PP) //page program mode
        data_byte_cnt <= data_byte_cnt + 1;
      else
        ;
    end    
    
    always @(posedge sys_clk or negedge sys_rst_n) begin
      if (!sys_rst_n)
        read_byte_max <= 0;
      else if (cmd == C_RD && fsm_c_s == FSM_IDLE)
        read_byte_max <= d_in;
      else
        read_byte_max <= read_byte_max;
    end    

    always @(fsm_c_s or cmd_reg) begin
      if (fsm_c_s == FSM_IDLE)
        instruction = 8'h00 ;
      else if (fsm_c_s == FSM_WRITE && cmd_reg == C_SE)
        instruction = SE    ;
      else if (fsm_c_s == FSM_WRITE && cmd_reg == C_PP)
        instruction = PP    ;
      else if (fsm_c_s == FSM_WE)
        instruction = WE    ;
      else if (fsm_c_s == FSM_READ)
        instruction = RD    ;
      else
        instruction = 8'h00 ;
    end
    
    // flags pulse
    always @(posedge sys_clk or negedge sys_rst_n) begin
      if (!sys_rst_n) begin
        spi_en_reg <=0;
        spi_status_0_reg <=0;
        spi_status_1_reg <=1;
        byte_data_ready <=0;
      end
      else begin
        spi_en_reg <=spi_en;
        spi_status_0_reg <=spi_status[0];
        spi_status_1_reg <=spi_status[1];
        byte_data_ready <=byte_read_done_pulse;
      end
    end

    assign spi_disable_pulse = (spi_en_reg == 1'b1 && spi_en == 1'b0) ? 1 : 0;
    assign byte_writen_done_pulse = (spi_status_1_reg == 1'b0 && spi_status[1] == 1'b1) ? 1 : 0;
    assign byte_read_done_pulse = (spi_status_0_reg == 1'b0 && spi_status[0] == 1'b1) ? 1 : 0;

    

    //===============
    // SPI interface
    //===============
    always @(posedge sys_clk or negedge sys_rst_n) begin
      if (!sys_rst_n) begin
        spi_reg_addr <=2'd0;
        spi_dout <=8'd0;
        spi_reg_cmd  <=2'd0;
      end
      else if (fsm_n_s == FSM_IDLE && fsm_switch_flag == 1'b1) begin// when switch to idle, reset the SPI control register
          spi_reg_addr <= 2'd0;
          spi_dout <= 8'b0000_0000;
          spi_reg_cmd  <= 2'd1;        
      end
      else if (fsm_c_s == FSM_WE) begin
        if (fsm_cnt == 16'd0) begin //enble SPTIE
          spi_reg_addr <= 2'd0;
          spi_dout <= 8'b0010_0000;
          spi_reg_cmd  <= 2'd1;            
        end
        else if (fsm_cnt == 16'd1) begin //write instruction
          spi_reg_addr <= 2'd3;
          spi_dout <= WE;
          spi_reg_cmd  <= 2'd1;            
        end
        else begin
          spi_reg_addr <= spi_reg_addr;
          spi_dout <= spi_dout;
          spi_reg_cmd  <= 2'd0;            
        end
      end //FSM_WE end
      else if (fsm_c_s == FSM_WRITE) begin
        if (fsm_cnt == 16'd0) begin //write instruction
          spi_reg_addr <= 2'd3;
          spi_dout <= instruction;
          spi_reg_cmd  <= 2'd1;            
        end
        else if (writen_byte_cnt >=0 && writen_byte_cnt < ADDR_W 
        &&  byte_writen_done_pulse == 1'b1) begin //write addr
          spi_reg_addr <= 2'd3;
          spi_dout <= addr_reg[8*ADDR_W-1 : 8*ADDR_W-8];
          spi_reg_cmd  <= 2'd1;
          addr_reg <= (addr_reg << 8);
        end
        else if (writen_byte_cnt >= ADDR_W && writen_byte_cnt < writen_byte_max 
        && byte_writen_done_pulse == 1'b1) begin //write data
          spi_reg_addr <= 2'd3;
          spi_dout <= spi_tx_data_buffer[writen_byte_cnt - ADDR_W];
          spi_reg_cmd  <= 2'd1;
        end
        else begin 
          spi_reg_addr <= spi_reg_addr;
          spi_dout <= spi_dout;
          spi_reg_cmd  <= 2'd0;
        end         
      end //write end
      else if (fsm_c_s == FSM_READ) begin
        if (fsm_cnt == 16'd0) begin //SPTIE enable
          spi_reg_addr <= 2'd0;
          spi_dout <= 8'b0010_0000;
          spi_reg_cmd  <= 2'd1;          
        end
        else if (fsm_cnt == 16'd1) begin //write instruction
          spi_reg_addr <= 2'd3;
          spi_dout <= instruction;
          spi_reg_cmd  <= 2'd1;          
        end 
        else if (writen_byte_cnt >=0 && writen_byte_cnt < ADDR_W 
        &&  byte_writen_done_pulse == 1'b1) begin //write addr
          spi_reg_addr <= 2'd3;
          spi_dout <= addr_reg[8*ADDR_W-1 : 8*ADDR_W-8];
          spi_reg_cmd  <= 2'd1;
          addr_reg <= (addr_reg << 8);
        end
        else if (writen_byte_cnt == ADDR_W 
        && byte_writen_done_pulse == 1'b1) begin //enable SPIE, and disable SPTIE
          spi_reg_addr <= 2'd0;
          spi_dout <= 8'b1000_0000;
          spi_reg_cmd  <= 2'd1;
        end
        else if (read_byte_cnt <= read_byte_max && byte_read_done_pulse == 1'b1) begin //read data
          spi_reg_addr <= 2'd2;
          spi_reg_cmd  <= 2'd2;        
        end //read end
        else begin
          spi_reg_addr <= spi_reg_addr;
          spi_dout <= spi_dout;
          spi_reg_cmd  <= 2'd0;          
        end        
      end
      else begin
        spi_reg_addr <= spi_reg_addr;
        spi_dout <= spi_dout;
        spi_reg_cmd  <= 2'd0;
      end
    end

    //spi_en
    always @(posedge sys_clk or negedge sys_rst_n) begin
      if (!sys_rst_n)
        spi_en <= 0;
      else if ( (fsm_n_s == FSM_WE || fsm_n_s == FSM_READ || fsm_n_s == FSM_WRITE) 
      && (fsm_switch_flag == 1'b1) && spi_en == 1'b0) //rising edge
        spi_en <= 1;  
      else if ( (fsm_n_s == FSM_WE || fsm_n_s == FSM_WRITE) && writen_byte_cnt == writen_byte_max 
        &&  byte_writen_done_pulse == 1'b1 && spi_en == 1'b1) //falling edge write done
        spi_en <= 0;
      else if ( fsm_n_s == FSM_READ && read_byte_cnt == read_byte_max 
        &&  byte_read_done_pulse == 1'b1 && spi_en == 1'b1) //falling edge write done
        spi_en <= 0;      
      else
        spi_en <= spi_en;
    end

    //===============
    // counts
    //===============
    
    //fsm_cnt
      //writen_byte_cnt
    always @(posedge sys_clk or negedge sys_rst_n) begin
      if (!sys_rst_n)
        fsm_cnt <= 0;
      else if (fsm_switch_flag == 1'b1)
        fsm_cnt <= 0;
      else if (fsm_c_s == FSM_IDLE)
        fsm_cnt <= 0;
      else if (fsm_cnt < 8'd10) //only need count to 10
        fsm_cnt <= fsm_cnt +1;
      else
        fsm_cnt <= fsm_cnt;
    end  

    //write_byte_max
    always @(fsm_c_s or data_byte_cnt) begin
      case (fsm_c_s)
        FSM_IDLE : writen_byte_max = 0;
        FSM_WE   : writen_byte_max = 0;
        FSM_READ : writen_byte_max = ADDR_W;
        FSM_WRITE: writen_byte_max = data_byte_cnt + ADDR_W;
      endcase
    end

    //writen_byte_cnt
    always @(posedge sys_clk or negedge sys_rst_n) begin
      if (!sys_rst_n)
        writen_byte_cnt <= 0;
      else if (fsm_switch_flag == 1'b1)
        writen_byte_cnt <= 0;
      else if (fsm_c_s != FSM_IDLE && byte_writen_done_pulse == 1'b1)
        writen_byte_cnt <= writen_byte_cnt +1;
      else
        writen_byte_cnt <= writen_byte_cnt;
    end

    //read_bte_cnt
    always @(posedge sys_clk or negedge sys_rst_n) begin
      if (!sys_rst_n)
        read_byte_cnt <= 0;
      else if (fsm_switch_flag == 1'b1)
        read_byte_cnt <= 0;
      else if (fsm_c_s == FSM_READ && byte_data_ready == 1'b1)
        read_byte_cnt <= read_byte_cnt +1;
      else
       read_byte_cnt <= read_byte_cnt;
    end
    
    //wait count and tWait
    always @(fsm_c_s or cmd_reg) begin
      if (fsm_c_s == FSM_IDLE)
        tW = 32'd100 ;
      else if (fsm_c_s == FSM_WRITE && cmd_reg == C_SE)
        tW = tSE     ;
      else if (fsm_c_s == FSM_WRITE && cmd_reg == C_PP)
        tW = tPP     ;
      else if (fsm_c_s == FSM_WE)
        tW = tSHSL    ;
      else if (fsm_c_s == FSM_READ)
        tW = tSHSL    ;
      else
        tW = 32'd100  ;
    end

    always @(posedge sys_clk or negedge sys_rst_n) begin
      if (!sys_rst_n)
        wait_cnt <= 0;
      else if (spi_en == 1'b0 && fsm_c_s != FSM_IDLE)
        wait_cnt <= wait_cnt + 1;
      else
        wait_cnt <= 0;
    end
  

    //===============
    // output
    //===============

    always @(posedge sys_clk or negedge sys_rst_n) begin
      if (!sys_rst_n) begin
        rd_data_out <=0;
        valid <=0;
      end
      else if (fsm_c_s == FSM_READ && byte_data_ready == 1'b1)begin
        rd_data_out <=spi_din;
        valid <=1;
      end
      else begin
        rd_data_out <= rd_data_out;
        valid <=0;
      end
    end 

    assign busy = (fsm_c_s == FSM_IDLE && fsm_n_s == FSM_IDLE) ? 0 : 1;

  SPI_master u_spi(
    .sys_clk     (sys_clk     )          ,
    .sys_rst_n   (sys_rst_n   )            ,
    .spi_reg_addr(spi_reg_addr)               ,
    .spi_reg_data(spi_reg_data)               ,
    .spi_reg_cmd (spi_reg_cmd )              ,
    .spi_status  (spi_status  )             ,
    .spi_en      (spi_en      )         ,
    .mosi        (mosi        )       ,
    .miso        (miso        )       ,
    .sck         (sck         )      ,
    .cs_n        (cs_n        )        
  );



endmodule