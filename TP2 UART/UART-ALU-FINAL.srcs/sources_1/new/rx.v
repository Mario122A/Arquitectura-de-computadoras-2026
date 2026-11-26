`timescale 1ns / 1ps

module rx
    #(parameter DATA_WIDTH = 8,
      parameter COUNTER_MODULE = 8,
      parameter STOP_BITS_TICKS = 32)
    (
    input wire rx,
    input wire clk,
    output wire [DATA_WIDTH-1:0] d_out,
    output wire rx_done
    );
    
    //DEFINICIÓN DE (E INICIALIZACIÓN DE ALGUNOS) REGISTROS
    reg [COUNTER_MODULE-1:0] counter = 0;
    reg [3:0] state,n;
    reg [4:0] s;
    reg s_tick = 0;
    reg [DATA_WIDTH-1:0] b;
    reg done = 0;
    
    assign d_out = b; //asocia el registro de datos al wire de salida
    assign rx_done = done; //asocia el registro de listo al wire de aviso de rx
    
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
        
        case(state)
            IDLE: begin
                done <= 0;
                if(rx==0) begin
                    s <= 0;
                    state <= START;
                end
                
            end
            START: begin
            
                if(s_tick) begin        
                    if(s==7) begin
                        s <= 0;
                        n <= 0;
                        state <= DATA;
                    end
                    else begin
                        s <= s+1;
                    end                
                end               
            
            end
            DATA: begin
            
                if(s_tick==1) begin
                    if(s==15) begin
                        s <= 0;
                        b <= {rx,b[7:1]};
                        if(n==DATA_WIDTH-1) begin
                            state <= STOP;
                        end
                        else begin
                            n <= n+1;
                        end
                    end
                    else begin
                        s <= s+1;
                    end
                end
                
            end
            STOP: begin //suponiendo ausencia de bit de paridad y dos bits de stop
                
                if(s_tick==1) begin
                    if(s==STOP_BITS_TICKS-1) begin
                        done <= 1;
                        state <= IDLE;
                    end
                    else begin
                        s <= s+1;
                    end
                end
            
            end
            
            default: state <= IDLE;
        endcase
        
    end
    
endmodule