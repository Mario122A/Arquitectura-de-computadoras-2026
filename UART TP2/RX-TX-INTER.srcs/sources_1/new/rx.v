`timescale 1ns / 1ps

//Se hace uso del clock para cálculo de ticks internos
//dada la complejidad que implica generar una unidad
//externa que provoque ticks, debido al hecho de que los
//pulsos asociados al arribo del clock a las 163 repeticiones
//suceden en los instantes de flanco de subida (o de bajada)
//al estar la unidad de generación de ticks sincronizada
//con la unidad rx es probable que esta última no logre
//visualizar correctamente el pulso de tick. Es por esto
//que de las soluciones planteadas hasta el momento la
//más óptima es la aplicada en este código
//
//Como soluciones alternativas se pueden considerar la extensión
//del pulso del tick 2 ciclos de clock o el desplazamiento del
//clock asociado al rx medio ciclo respecto del clock
//asociado a la unidad de generación de ticks, como se podrá ver
//con un poco de análisis mental estos dos planteamientos
//traen consigo diversos problemas de aplicación y diseño


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