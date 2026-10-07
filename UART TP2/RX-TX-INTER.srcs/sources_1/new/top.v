`timescale 1ns / 1ps

module top
    #(parameter DATA_WIDTH = 8)
    (
     output [DATA_WIDTH-1:0] r_data,
     input rd_uart,
     output rx_empty,
     input [DATA_WIDTH-1:0] w_data,
     input wr_uart,
     output tx_full,
     input clk
    );
    //wire tx con rx
    wire trex;
    //wire rx con interface
    wire [DATA_WIDTH-1:0] d_out_w;
    wire rx_done_w;
    //wire tx con interface
    wire [DATA_WIDTH-1:0] d_in_w;
    wire tx_done_w;
    wire tx_start_w;
    
    rx rx_uut(.rx(trex), .clk(clk), .d_out(d_out_w), .rx_done(rx_done_w));
    
    tx tx_uut(.tx(trex), .clk(clk), .d_in(d_in_w), .tx_done(tx_done_w), .tx_start(tx_start_w));
    
    interface_rx_tx interface_uut(
        .clk(clk),
        .dout(d_out_w),
        .rx_done_tick(rx_done_w),
        .rd_uart(rd_uart),
        .rx_empty(rx_empty),
        .r_data(r_data),
        .w_data(w_data),
        .wr_uart(wr_uart),
        .tx_full(tx_full),
        .tx_done_tick(tx_done_w),
        .d_in(d_in_w),
        .tx_start(tx_start_w)
    );
endmodule
