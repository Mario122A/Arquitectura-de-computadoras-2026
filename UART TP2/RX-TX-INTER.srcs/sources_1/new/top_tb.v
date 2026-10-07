`timescale 1ns / 1ps

module top_tb;
parameter DATA_WIDTH = 8;

reg clk=0;

reg rd;
reg wr;
reg [DATA_WIDTH-1:0] w_data;

wire [DATA_WIDTH-1:0] r_data;
wire rx_empty;
wire tx_full;

top top_uut(
    .r_data(r_data),
    .rd_uart(rd),
    .rx_empty(rx_empty),
    .w_data(w_data),
    .wr_uart(wr),
    .tx_full(tx_full),
    .clk(clk)
);
//50MHz
always #10 clk = ~clk;

initial begin
w_data=8'h89;
wr=1'b1;
rd=1'b0;
#20
wr=1'b0;
#700000
rd=1'b1;
#20
rd=1'b0;
#300000
$finish;
end

initial $monitor($time, clk, r_data, w_data, tx_full, rx_empty);

endmodule
