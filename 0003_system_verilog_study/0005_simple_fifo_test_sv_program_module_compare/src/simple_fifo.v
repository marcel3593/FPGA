module sp_fifo(
    input clk,
    input rst_n,
    input wr_en,
    input [7:0] din,
    input rd_en,
    output reg [7:0] dout
);


reg [3:0] wr_addr_count;
reg [3:0] rd_addr_count;

reg [7:0] mem [0:15]; //depth = 16
integer i;


//wr_cnt
always @(posedge clk or negedge rst_n) begin
    if ( !rst_n )
        wr_addr_count<=0;
    else if ( wr_en == 1'b1)
        wr_addr_count <= wr_addr_count +1;
    end

//write memory
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        for (i=0; i < 16; i = i + 1)
            mem[i] <=0;
    else if (wr_en == 1'b1)
        mem[wr_addr_count] <= din;
end

//rd_cnt
always @(posedge clk or negedge rst_n) begin
    if ( !rst_n )
        rd_addr_count<=0;
    else if ( rd_en == 1'b1)
        rd_addr_count <= rd_addr_count +1;
end

//read memory
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        dout <= 8'hff;
    else if ( rd_en == 1'b1)
        dout <= mem[rd_addr_count];
end


endmodule




