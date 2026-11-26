`timescale 1ns / 1ps

module tb_uart_top;

reg rx_tb;
reg clk_tb;
wire tx_tb;

uart_top uart_top_uut (.rx_uart_top(rx_tb), .clk(clk_tb), .tx_uart_top(tx_tb));

always #10 clk_tb = ~clk_tb;

initial begin
    clk_tb = 0;
    
    //A
    
    //start
    rx_tb = 1'b1;
    #52083
    rx_tb = 1'b0;
    #52083
    //dato 3 decimal
    rx_tb = 1'b1;
    #52083
    rx_tb = 1'b1;
    #52083
    rx_tb = 1'b0;
    #52083
    rx_tb = 1'b0;
    #52083
    rx_tb = 1'b0;
    #52083
    rx_tb = 1'b0;
    #52083
    rx_tb = 1'b0;
    #52083
    rx_tb = 1'b0;
    #52083
    //stop
    rx_tb = 1'b1;
    #52083
    rx_tb = 1'b1;
    #52083
    
    
    //B
    
    //start
    rx_tb = 1'b1;
    #52083
    rx_tb = 1'b0;
    #52083
    //dato 1 decimal
    rx_tb = 1'b1;
    #52083
    rx_tb = 1'b0;
    #52083
    rx_tb = 1'b0;
    #52083
    rx_tb = 1'b0;
    #52083
    rx_tb = 1'b0;
    #52083
    rx_tb = 1'b0;
    #52083
    rx_tb = 1'b0;
    #52083
    rx_tb = 1'b0;
    #52083
    //stop
    rx_tb = 1'b1;
    #52083
    rx_tb = 1'b1;
    #52083
    
    //OP (suma)
    
    //start
    rx_tb = 1'b1;
    #52083
    rx_tb = 1'b0;
    #52083
    //128 decimal
    rx_tb = 1'b0;
    #52083
    rx_tb = 1'b0;
    #52083
    rx_tb = 1'b0;
    #52083
    rx_tb = 1'b0;
    #52083
    rx_tb = 1'b0;
    #52083
    rx_tb = 1'b1;
    #52083
    rx_tb = 1'b0;
    #52083
    rx_tb = 1'b0;
    #52083
    //stop
    rx_tb = 1'b1;
    #52083
    rx_tb = 1'b1;
    #52083
    
    //wait de 1 dato
    #572913
    
    $finish;
end

initial $monitor($time, rx_tb, tx_tb, clk_tb);

endmodule
