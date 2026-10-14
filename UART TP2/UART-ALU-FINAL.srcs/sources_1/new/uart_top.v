`timescale 1ns / 1ps

module uart_top(
    input rx_uart_top,
    input clk,
    output reg tx_uart_top
    );
    
    //wires rx
    wire d_out_w;
    wire rx_done_w;
    //wires tx
    wire d_in_w;
    wire tx_done_w;
    wire tx_start_w;
    //wires alu
    wire r_data_w;
    wire rd_w;
    wire rx_empty_w;
    wire w_data_w;
    wire wr_w;
    wire tx_full_w;
    
    rx rx_uut (.rx(rx_uart_top), .clk(clk), .d_out(d_out_w), .rx_done(rx_done_w));
    tx tx_uut (.tx(tx_uart_top), .clk(clk), .d_in(d_in_w), .tx_done(tx_done_w), .tx_start(tx_start_w));
    interface_rx_tx interface_rx_tx_uut (
        .clk(clk),
        .dout(d_out_w),
        .rx_done_tick(rx_done_w),
        .rd_uart(rd_w),
        .rx_empty(rx_empty_w),
        .r_data(r_data_w),
        .w_data(w_data_w),
        .wr_uart(wr_w),
        .tx_full(tx_full_w),
        .tx_done_tick(tx_done_w),
        .d_in(d_in_w),
        .tx_start(tx_start_w)
    );
    alu_top alu_top_uut(
        .r_data_alu(r_data_w),
        .w_data_alu(w_data_w),
        .C_LED(),
        .rd_alu(rd_w),
        .wr_alu(wr_w),
        .rx_empty_alu(rx_empty_w),
        .tx_full_alu(tx_full_w),
        .clk(clk),
        .rst(1'b0)
    );
    
endmodule
