`timescale  1ns/10ps



module tb_eeprom_cntl (

);

logic sys_clk      ;
logic sys_rst_n    ;
logic [1:0] cmd    ;      
wire  [7:0] data   ;     
logic buffer_rd_en ;
logic buffer_reset ;
logic buffer_wr_en ;
logic buffer_empty ;
logic buffer_full  ;
logic error        ;
logic busy         ;
logic scl          ;
wire sda           ;

parameter EEPOM_NOP  = 2'b00 ;
parameter EEPOM_WR   = 2'b01 ;
parameter EEPOM_RD   = 2'b10 ;
parameter EEPOM_LDA  = 2'b11 ;

wire [7:0] data_in;
reg [7:0] data_out;

assign data = (cmd == EEPOM_NOP && buffer_wr_en == 1'b0) ? 'Z : data_out;
assign data_in = data;

assign (weak1,weak0) sda = 1'b1;

initial begin
    main();
end

task main();
    fork
        reset();
        clk();
        begin
            simple_write();
            simple_read();          
        end
    join
endtask

task reset ();
    begin
        sys_clk = 0;
        sys_rst_n = 0;
        buffer_reset = 0;
        #25 sys_rst_n <=1;
    end
endtask

task clk ();
    forever #10 sys_clk = ~sys_clk;
endtask

task simple_write();
    fork 
        begin
            cmd <= EEPOM_NOP;
            #200 cmd <= EEPOM_WR;
            #40 cmd <= EEPOM_NOP;        
        end
        begin
            data_out <= 8'd0;
            #40 data_out <= 8'b10101010;
            #20 data_out <=0;
            #140 data_out <= 8'h20; //word address --> page #1
            #20 data_out <= 0;        
        end    
        begin
            buffer_wr_en <= 1'b0;
            buffer_rd_en <= 1'b0;
            #40 buffer_wr_en <= 1'b1;
            #20 buffer_wr_en <= 1'b0;         
        end
    join
endtask

task simple_read(); 
    begin
        @(posedge sys_clk iff (busy == 1'b0) );
        cmd <= EEPOM_RD;
        data_out <= 8'h20;
        @(posedge sys_clk);
        cmd <= EEPOM_RD;
        data_out <= 8'h00;      
        @(posedge sys_clk);
        cmd <= EEPOM_NOP;
        data_out <= 8'h00;        
    end
endtask

eeprom_cntl dut(
  .sys_clk      (sys_clk      ),  
  .sys_rst_n    (sys_rst_n    ),  
  .cmd          (cmd          ),
  .data         (data         ),
  .buffer_reset (buffer_reset ),
  .buffer_rd_en (buffer_rd_en ),  
  .buffer_wr_en (buffer_wr_en ),  
  .buffer_empty (buffer_empty ),
  .buffer_full  (buffer_full  ),
  .error        (error        ),
  .busy         (busy         ),
  .scl          (scl          ),
  .sda          (sda          )    
);


AT24C64D model_eeprom(
    .SCL(scl),
    .SDA(sda),
    .WP ('Z)
);


endmodule