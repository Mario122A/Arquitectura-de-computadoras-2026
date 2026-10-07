`timescale 1ns / 1ps

module tx
    #(parameter DATA_WIDTH = 8,
      parameter COUNTER_MODULE = 8,
      parameter STOP_BITS_TICKS = 32)
    (
    output wire tx,
    input wire clk,
    input wire [DATA_WIDTH-1:0] d_in,
    output wire tx_done,
    input wire tx_start
    );
    
    reg [COUNTER_MODULE-1:0] counter = 0;
    reg [3:0] state = 4'b0001;
    reg [4:0] s = 0;
    reg [3:0] n = 0;
    reg s_tick = 0;
    reg [DATA_WIDTH-1:0] in_latch;
    reg tx_done_r = 0;   
    reg tx_r;
    
    assign tx = tx_r;
    assign tx_done = tx_done_r;
    
    localparam IDLE = 4'b0001;
    localparam START = 4'b0010;
    localparam DATA = 4'b0100;
    localparam STOP = 4'b1000;
    
    
    always @(posedge clk)begin
        if(counter==163) begin
            counter <= 0;
            s_tick <= 1;
        end
        else begin
            counter <= counter+1;
            s_tick <= 0;
        end
        
        tx_r <= 1;
        
        case(state)
            IDLE: begin
            
            tx_r <= 1;
            tx_done_r <= 0;   // la flag de tx_done se mantiene en 0 en IDLE
            if(tx_start) begin 
                in_latch <= d_in;
                s <= 0;
                state <= START;
                end            
            end
            
            START: begin
            tx_r <= 0;
                if(s_tick==1)begin
                    if(s==15)   begin
                        s <= 0;
                        n <= 0;
                        state <= DATA;                        
                        end
                    else s <= s + 1;
                    end                 
            end
            
            DATA: begin
            
                tx_r <= in_latch[n];
            
                if (s_tick) begin
                    if(s==15) begin
                        s <= 0;
                       
                        if (n == DATA_WIDTH - 1) begin
                            state <= STOP;                            
                        end else begin
                             n <= n+1;
                        end
                    end else s <= s+1;
                    
                    end
            
            end
            
            STOP: begin 
            
                if (s_tick) begin
                
                    tx_r <= 1;
                    
                    if(s >= STOP_BITS_TICKS-1) begin
                        tx_done_r <= 1;
                        state <= IDLE;
                        end
                    else s <= s+1;
                    
                    
                    end
            end 
            
            default: state <= IDLE;
    endcase
    
    end
    
endmodule