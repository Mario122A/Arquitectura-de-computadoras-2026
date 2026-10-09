`timescale 1ns / 1ps

module tb_inter_rx;
parameter DATA_WIDTH = 8;
//definición conexiones externas al bloque conjunto interface-rx
reg rx_tb;
reg clk_tb=0;
reg rd_uart_tb=0;
wire [DATA_WIDTH-1:0] r_data_tb;
wire rx_empty_tb;

//wires intermedios para la conexión entre módulo interface y módulo rx
wire [DATA_WIDTH-1:0] d_out_w;
wire rx_done_w;

rx rx_uut (.rx(rx_tb), .clk(clk_tb), .d_out(d_out_w), .rx_done(rx_done_w));

interface_rx_tx interface_rx_tx_uut (
    .clk(clk_tb),
    .dout(d_out_w),
    .rx_done_tick(rx_done_w),
    .rd_uart(rd_uart_tb),
    .rx_empty(rx_empty_tb),
    .r_data(r_data_tb),
    .w_data(8'b0),
    .wr_uart(1'b0),
    .tx_full(),
    .tx_done_tick(1'b0),
    .d_in(),
    .tx_start()
);

always #10 clk_tb = ~clk_tb;

initial begin
//start
rx_tb=1'b1;
#52083
rx_tb=1'b0;
#52083
//dato h91
rx_tb=1'b1;
#52083
rx_tb=1'b0;
#52083
rx_tb=1'b0;
#52083
rx_tb=1'b0;
#52083
rx_tb=1'b1;
#52083
rx_tb=1'b0;
#52083
rx_tb=1'b0;
#52083
rx_tb=1'b1;
#52083
//bit stop
rx_tb=1'b1;
#52083
rx_tb=1'b1;
#52083


//start
rx_tb=1'b1;
#52083
rx_tb=1'b0;
#52083
//dato hC1
rx_tb=1'b1;
#52083
rx_tb=1'b0;
#52083
rx_tb=1'b0;
#52083
rx_tb=1'b0;
#52083
rx_tb=1'b0;
#52083
rx_tb=1'b0;
#52083
rx_tb=1'b1;
#52083
rx_tb=1'b1;
#52083
//bit stop
rx_tb=1'b1;
#52083
rx_tb=1'b1;
#52083


//start
rx_tb=1'b1;
#52083
rx_tb=1'b0;
#52083
//dato hC5
rx_tb=1'b1;
#52083
rx_tb=1'b0;
#52083
rx_tb=1'b1;
#52083
rx_tb=1'b0;
#52083
rx_tb=1'b0;
#52083
rx_tb=1'b0;
#52083
rx_tb=1'b1;
#52083
rx_tb=1'b1;
#52083
//bit stop
rx_tb=1'b1;
#52083
rx_tb=1'b1;
#52083


//start
rx_tb=1'b1;
#52083
rx_tb=1'b0;
#52083
//dato h80
rx_tb=1'b0;
#52083
rx_tb=1'b0;
#52083
rx_tb=1'b0;
#52083
rx_tb=1'b0;
#52083
rx_tb=1'b0;
#52083
rx_tb=1'b0;
#52083
rx_tb=1'b0;
#52083
rx_tb=1'b1;
#52083
//bit stop
rx_tb=1'b1;
#52083
rx_tb=1'b1;
#52083
//queda permanentemente en 1 porque jamás bajo rx_tb
#60 //espera 3 ciclos de clock extra
rd_uart_tb=1'b1;
#70 //lo mantiene por levemente más de tres ciclos para que
//cuenten 3 pulsaciones de rd
rd_uart_tb=1'b0;

//en esta instancia wp de rx debe quedar en la primera posición
//de la matriz y rp en la última

$finish;

end

initial $monitor($time, rx_tb, clk_tb, rd_uart_tb, r_data_tb, rx_empty_tb);

endmodule
