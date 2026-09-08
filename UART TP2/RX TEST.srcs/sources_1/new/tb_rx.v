`timescale 1ns / 1ps

module tb_rx;
    reg rx, clk;
    wire [7:0] d_out;
    wire rx_done;
    
    rx uut(.rx(rx), .clk(clk), .d_out(d_out), .rx_done(rx_done));
    
    initial clk = 0;
    always #10 clk = ~clk; //50MHz
    
    initial begin
        rx = 1'b1; //inicio
        #52083;
        rx = 1'b0;
        #52083;
        
        
        rx = 1'b1; //dato
        #52083;
        rx = 1'b0;
        #52083;
        rx = 1'b1;
        #52083;
        rx = 1'b0;
        #52083;
        rx = 1'b1;
        #52083;
        rx = 1'b1;
        #52083;
        rx = 1'b1;
        #52083;
        rx = 1'b0;
        #52083;
        
        rx = 1'b1; //stop bits
        #52083;
        rx = 1'b1;
        #52083;
        
        $finish;
    end
    
    initial $monitor($time, clk, rx, rx_done, d_out);
    
endmodule
