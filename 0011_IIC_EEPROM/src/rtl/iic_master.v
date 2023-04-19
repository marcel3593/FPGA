
module iic_master (
  input                sys_clk      ,  
  input                sys_rst_n    ,  
  input       [5:0]    iic_cmd      ,
  input       [7:0]    iic_data_in  ,
  output reg  [7:0]    iic_data_out ,
  output reg           iic_done     ,
  output      [1:0]    iic_status   ,
  output reg           scl          ,
  inout                sda
);

	parameter IIC_IDLE          = 6'b000000;    
	parameter IIC_START         = 6'b000001;     
	parameter IIC_WRITE         = 6'b000010;     
	parameter IIC_READ          = 6'b000100;    
	parameter IIC_READ_LAST     = 6'b001000;         
	parameter IIC_STOP          = 6'b010000;    
	parameter IIC_RATE_CONFIG   = 6'b100000;           

    parameter IIC_CLK_RATE_DIV = 16'd500;  //!!
    localparam  IIC_SCL_CNT_MAX= IIC_CLK_RATE_DIV/2;

    localparam IIC_FSM_IDLE     = 3'b000 ;       
	localparam IIC_FSM_START    = 3'b010 ;       
	localparam IIC_FSM_WRITE    = 3'b011 ;       
	localparam IIC_FSM_READ     = 3'b110 ;      
	localparam IIC_FSM_STOP     = 3'b111 ;   

    reg   [2:0] iic_fsm_c_s;
    reg   [2:0] iic_fsm_n_s;

    reg   [7:0] scl_cnt;
    reg   [4:0] data_trans_bit_cnt;
    
    reg   [7:0]  wdata_reg_shifter;
    reg   [7:0]  rdata_reg_shifter;
    reg   master_ack;
    
    wire  scl_switch_flag;
    reg   scl_switch_flag_reg;
    wire  scl_period_pre_end_flag;
    wire  scl_period_end_flag;
    reg   scl_period_start_flag;
    reg   scl_pulse_center_h_flag;

    reg  iic_error;
    wire  iic_busy;
    reg   sda_out;
    wire  sda_in;
    
    assign sda = (sda_out == 1'b0) ? sda_out : 1'bz;
    assign sda_in = sda;
    
    //============
    // --IIC FSM--
    //============
    
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            iic_fsm_c_s <= IIC_FSM_IDLE;
        else
            iic_fsm_c_s <= iic_fsm_n_s;
    end

    always @(iic_fsm_c_s or iic_cmd or iic_done) begin
        case (iic_fsm_c_s) 
            IIC_FSM_IDLE : 
                if (iic_cmd == IIC_START) 
                    iic_fsm_n_s = IIC_FSM_START;
                else
                    iic_fsm_n_s = IIC_FSM_IDLE;
            IIC_FSM_START :
                case (iic_cmd)
                    IIC_WRITE      : iic_fsm_n_s = IIC_FSM_WRITE;
                    IIC_READ       : iic_fsm_n_s = IIC_FSM_READ;
                    IIC_READ_LAST  : iic_fsm_n_s = IIC_FSM_READ;
                    IIC_STOP       : iic_fsm_n_s = IIC_FSM_STOP;
                    default        : iic_fsm_n_s = IIC_FSM_START;
                endcase
            IIC_FSM_WRITE :
                case (iic_cmd)
                    IIC_START      : iic_fsm_n_s = IIC_FSM_START;
                    IIC_READ       : iic_fsm_n_s = IIC_FSM_READ;
                    IIC_STOP       : iic_fsm_n_s = IIC_FSM_STOP;
                    default        : iic_fsm_n_s = IIC_FSM_WRITE;
                endcase
            IIC_FSM_READ :
                case (iic_cmd)
                    IIC_START      : iic_fsm_n_s = IIC_FSM_START;
                    IIC_WRITE      : iic_fsm_n_s = IIC_FSM_WRITE;
                    IIC_STOP       : iic_fsm_n_s = IIC_FSM_STOP;
                    default        : iic_fsm_n_s = IIC_FSM_READ;
                endcase                     
            IIC_FSM_STOP :
                if (iic_done == 1'b1) 
                    iic_fsm_n_s = IIC_FSM_IDLE;
                else
                    iic_fsm_n_s = IIC_FSM_STOP;
            default  iic_fsm_n_s = IIC_FSM_IDLE;       
        endcase
    end

    //===============
    // --FSM output--
    //===============
    
    //scl logic
    assign scl_switch_flag = (scl_cnt == IIC_SCL_CNT_MAX-2) ? 1'b1 : 1'b0;

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            scl_switch_flag_reg <=1'b0;
        else
            scl_switch_flag_reg <=scl_switch_flag;
    end

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            scl_cnt <= 0;
        else if (iic_fsm_c_s == IIC_FSM_IDLE)
            scl_cnt <= 0;
        else if (scl_switch_flag_reg == 1'b1)
            scl_cnt <= 0;
        else
            scl_cnt <= scl_cnt + 1'b1;
    end

    assign scl_period_end_flag = (scl_switch_flag_reg == 1'b1 && scl == 1'b1);    
    assign scl_period_pre_end_flag = (scl_switch_flag == 1'b1 && scl == 1'b1);    

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            scl_period_start_flag <=1'b0;
        else
            scl_period_start_flag <=scl_period_end_flag;
    end

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            scl_pulse_center_h_flag <=1'b0;
        else if (scl_cnt ==  IIC_SCL_CNT_MAX/2-1 && scl == 1'b1)
            scl_pulse_center_h_flag <=1'b1;
        else
            scl_pulse_center_h_flag <=1'b0;
    end

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            scl <=1'b1;
        else if (scl_switch_flag_reg == 1'b1)
            scl <= ~ scl;
        else
            scl <=scl;
    end

//data_trans_bit_cnt
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            data_trans_bit_cnt <= 0;
        else if (iic_cmd != IIC_IDLE)
            data_trans_bit_cnt <= 0;
        else if (scl_period_start_flag == 1'b1)
            data_trans_bit_cnt <= data_trans_bit_cnt + 1;
    end

// wdata_reg_shifter 
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            wdata_reg_shifter <= 8'd0;
        else if (iic_cmd == IIC_WRITE)
            wdata_reg_shifter <= iic_data_in;
        else if (iic_fsm_c_s == IIC_FSM_WRITE && scl_period_start_flag == 1'b1)
            wdata_reg_shifter <=  wdata_reg_shifter << 1;
    end

// rdata_reg_shifter
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            rdata_reg_shifter <= 8'd0;
        else if (iic_fsm_c_s == IIC_FSM_READ && scl_pulse_center_h_flag == 1'b1 && data_trans_bit_cnt <=8)
            rdata_reg_shifter <=  {rdata_reg_shifter[6:0],sda_in};
    end

//master_ack
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            master_ack <= 8'd0;
        else if (iic_cmd == IIC_READ)
            master_ack <= 8'd0;
        else if (iic_cmd == IIC_READ_LAST)
            master_ack <= 8'd1;
    end


//sda out
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) 
            sda_out <= 1'b1;
        else
            case (iic_fsm_c_s)
                IIC_FSM_IDLE : sda_out <= 1'b1;
                IIC_FSM_START: 
                    if (scl_period_start_flag == 1'b1) //start begin
                        sda_out <= 1'b1;
                    else if (scl_pulse_center_h_flag == 1'b1) //sda negtive transition with scl=1
                        sda_out <= 1'b0;
                    else
                        sda_out <= sda_out;
                IIC_FSM_WRITE:
                    if (scl_period_start_flag == 1'b1 && data_trans_bit_cnt <=7) //write data
                        sda_out <= wdata_reg_shifter[7];
                    else if (scl_period_start_flag == 1'b1 && data_trans_bit_cnt == 8) //slave ack, release bus
                        sda_out <= 1'b1;
                    else
                        sda_out <= sda_out;
                IIC_FSM_READ:
                    if (scl_period_start_flag == 1'b1 && data_trans_bit_cnt == 8) //master ack
                        sda_out <= master_ack;
                    else if (scl_period_start_flag == 1'b1 && data_trans_bit_cnt == 0) //release bus at the beginning of read
                        sda_out <= 1'b1;
                    else
                        sda_out <= sda_out;
                IIC_FSM_STOP:
                    if (scl_period_start_flag == 1'b1) //stop begin
                        sda_out <= 1'b0;
                    else if (scl_pulse_center_h_flag == 1'b1) //sda positive transition with scl=1
                        sda_out <= 1'b1;
                    else
                        sda_out <= sda_out;
                default: sda_out <= 1'b1;
            endcase
    end    

//iic data output and error/status handling

    // iic done
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) 
            iic_done <= 1'b0;
        else
            case (iic_fsm_c_s)
                IIC_FSM_IDLE : iic_done <= 1'b0;
                IIC_FSM_START: 
                    if (scl_period_pre_end_flag == 1'b1) 
                        iic_done <= 1'b1;
                    else
                        iic_done <= 1'b0;
                IIC_FSM_WRITE:
                    if (scl_period_pre_end_flag == 1'b1 && data_trans_bit_cnt == 9) 
                        iic_done <= 1'b1;
                    else
                        iic_done <= 1'b0;
                IIC_FSM_READ:
                    if (scl_period_pre_end_flag == 1'b1 && data_trans_bit_cnt == 9) 
                        iic_done <= 1'b1;
                    else
                        iic_done <= 1'b0;
                IIC_FSM_STOP:
                    if (scl_period_pre_end_flag == 1'b1) 
                        iic_done <= 1'b1;
                    else
                        iic_done <= 1'b0;
                default: iic_done <= 1'b0;
            endcase
    end    
    
    //iic_data_out
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) 
            iic_data_out <= 8'd0;
        else if (scl_period_start_flag == 1'b1 && data_trans_bit_cnt == 8)
            iic_data_out <= rdata_reg_shifter;
    end

    //error and status handle
    assign iic_status[1] = iic_error;
    assign iic_status[0] = iic_busy;
    assign iic_busy = (iic_fsm_c_s == IIC_FSM_IDLE) ? 0 : 1;

    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            iic_error <=0;
        else if (iic_cmd == IIC_STOP)
            iic_error <=0;
        else if (iic_fsm_c_s == IIC_FSM_WRITE && 
        scl_pulse_center_h_flag == 1'b1 && data_trans_bit_cnt == 9)
            iic_error <= sda_in;
    end

endmodule