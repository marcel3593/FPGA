module tmds_encoder(
  input                     display_en  ,
  input             [7:0]   d           ,
  input                     c0          ,
  input                     c1          ,
  input                     de          ,
  input                     pixel_clk   ,
  input                     rst_n       ,
  output    reg     [9:0]   q
);

parameter INSTANCE_ID = 2'd0; //TMDS Channel Number: [0,1,2]

reg c0_reg1;
reg c1_reg1;
reg de_reg1;

reg c0_reg2;
reg c1_reg2;
reg de_reg2;

reg [7:0] d_reg1;
reg [7:0] d_reg2;

reg [4:0] cnt;  // bit 4 is the sign bit.
wire [4:0] N1d;
wire [4:0] N0d;
wire [9:0] q_m;
wire [4:0] N1qm;
wire [4:0] N0qm;

wire c0m;  //use c0m to control the preamble type in control period; 
reg [9:0] qc;  //control perood encode results


//regs sample
always @(posedge pixel_clk or negedge rst_n) begin
    if (!rst_n || display_en == 1'b0) begin
        c0_reg1 <=0;
        c0_reg2 <=0;
        c1_reg1 <=0;
        c1_reg2 <=0;
        de_reg1 <=0;
        de_reg2 <=0;
        d_reg1 <=0;
        d_reg2 <=0;
    end
    else begin
        c0_reg1 <=c0;
        c0_reg2 <=c0_reg1;
        c1_reg1 <=c1;
        c1_reg2 <=c1_reg1;
        de_reg1 <=de;
        de_reg2 <=de_reg1;    
        d_reg1 <=d;
        d_reg2 <=d_reg1;    
    end
end

//control period encoding; video data preamble(ctr0,1,2,3 = 4'b1000) should be placed right before video data guard band;
assign c0m = ( INSTANCE_ID == 1 ) ? (( (de == 1'b1) && (de_reg1 == 1'b0)) ? 1 : 0 ) : c0_reg2;  //only need modify the c0m for encoder instance #1 and only modify it in video data preamble period

always @(c0m,c1_reg2) begin
    case ({c1_reg2,c0m})
        2'b00: qc[9:0] = 10'b1101010100; 
        2'b01: qc[9:0] = 10'b0010101011; 
        2'b10: qc[9:0] = 10'b0101010100; 
        2'b11: qc[9:0] = 10'b1010101011; 
    endcase
end


//video data period encoding

assign N1d = d_reg2[0] + d_reg2[1] + d_reg2[2] + d_reg2[3] + d_reg2[4] + d_reg2[5] + d_reg2[6] + d_reg2[7];
assign N1qm = q_m[0] + q_m[1] + q_m[2] + q_m[3] + q_m[4] + q_m[5] + q_m[6] + q_m[7];
assign N0qm = 5'd8 - N1qm;

wire ctrl0;
wire ctrl1;
wire ctrl2;
wire ctrl3;

assign ctrl0 =  (N1d > 5'd4) || (N1d == 5'd4 && d_reg2[0] == 1'b0 ); 
assign ctrl1 = (cnt == 0 ) || (N1qm == N0qm);
assign ctrl2 = (cnt[4] == 0 ) && (N1qm > N0qm) || (cnt[4] == 1 ) && ( N0qm > N1qm);
assign ctrl3 = (q_m[8] == 0);

assign q_m[0] = d_reg2[0];
assign q_m[1] = ctrl0 ? q_m[0] ~^ d_reg2[1] :  q_m[0] ^ d_reg2[1];
assign q_m[2] = ctrl0 ? q_m[1] ~^ d_reg2[2] :  q_m[1] ^ d_reg2[2];
assign q_m[3] = ctrl0 ? q_m[2] ~^ d_reg2[3] :  q_m[2] ^ d_reg2[3];
assign q_m[4] = ctrl0 ? q_m[3] ~^ d_reg2[4] :  q_m[3] ^ d_reg2[4];
assign q_m[5] = ctrl0 ? q_m[4] ~^ d_reg2[5] :  q_m[4] ^ d_reg2[5];
assign q_m[6] = ctrl0 ? q_m[5] ~^ d_reg2[6] :  q_m[5] ^ d_reg2[6];
assign q_m[7] = ctrl0 ? q_m[6] ~^ d_reg2[7] :  q_m[6] ^ d_reg2[7];
assign q_m[8] = ctrl0 ? 0 : 1;

//qout and cnt

always @(posedge pixel_clk or negedge rst_n) begin
    if (!rst_n || display_en == 1'b0) begin
        q <=0;
        cnt<=0;
    end
    else if (de_reg2 == 0'b0 && de_reg1 == 1'b1)  begin //video data guard band
        case (INSTANCE_ID)
            2'd0: q[9:0] <= 10'b1011001100;
            2'd1: q[9:0] <= 10'b0100110011; 
            2'd2: q[9:0] <= 10'b1011001100; 
        endcase
        cnt <=0;
    end
    else if (de_reg2 == 0'b0) begin// control period
        q <= qc;
        cnt <=0;
    end
    else begin //video data period
        if (ctrl1) begin
            q[9] <= ~q_m[8];
            q[8] <= q_m[8];
            q[7:0] <= (q_m[8])? q_m[7:0]:~q_m[7:0];
            if (ctrl3)
                cnt <= cnt + (N0qm - N1qm);
            else
                cnt <= cnt + (N1qm - N0qm);
        end
        else
            if (ctrl2) begin
                q[9] <= 1'b1;
                q[8] <= q_m[8];
                q[7:0] <= ~q_m[7:0];
                cnt <= cnt + 5'd2*q_m[8] +(N0qm - N1qm);              
            end
            else begin
                q[9] <= 0'b0;
                q[8] <= q_m[8];
                q[7:0] <= q_m[7:0];
                cnt <= cnt - 5'd2*(~q_m[8]) +(N1qm - N0qm);                   
            end
    end
end

endmodule
