`timescale 1ns / 1ps

module tb;
    reg wr_uart, clk;
    wire tx, tx_full;
    reg [7:0] w_data;
    
    //wires intermedios
    wire [7:0] d_in_wire;
    wire tx_done_wire, tx_start_wire;
    
    interface_rx_tx uit (
    .clk(clk),
    .dout(8'b0),
    .rx_done_tick(1'b0), 
    .rd_uart(1'b0),
    .rx_empty(),
    .r_data(),
    .w_data(w_data),
    .wr_uart(wr_uart),
    .tx_full(tx_full),
    .tx_done_tick(tx_done_wire),
    .d_in(d_in_wire),
    .tx_start(tx_start_wire)
    );
    tx uut (.tx(tx), .clk(clk), .d_in(d_in_wire), .tx_done(tx_done_wire), .tx_start(tx_start_wire));
    
    initial clk = 0;
    always #10 clk = ~clk; //50MHz
    
    initial begin
        w_data = 8'hAA;
        #52083 //no es necesario
        wr_uart = 1'b1;
        #20
        wr_uart = 1'b0;
        w_data = 8'h89;
        wr_uart = 1'b1;
        #20
        wr_uart = 1'b0; 
    end
    
    initial $monitor($time, clk, tx, d_in_wire, tx_full);
    
endmodule
