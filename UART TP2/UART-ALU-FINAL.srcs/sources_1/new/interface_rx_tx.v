`timescale 1ns / 1ps

module interface_rx_tx (
    input  wire       clk,
    // ---------- lado Rx ----------
    input  wire [7:0] dout,         // dato recibido (desde Rx)
    input  wire       rx_done_tick, // fin de recepción (desde Rx)
    input  wire       rd_uart,      // pedido de lectura (desde ALU, "rd")
    output wire       rx_empty,     // FIFO Rx vacía (hacia ALU)
    output wire [7:0] r_data,       // dato a leer (hacia ALU)
    // ---------- lado Tx ----------
    input  wire [7:0] w_data,       // dato a transmitir (desde ALU)
    input  wire       wr_uart,      // pedido de escritura (desde ALU, "wr")
    output wire       tx_full,      // FIFO Tx llena (hacia ALU)
    input  wire       tx_done_tick, // fin de transmisión (desde Tx, "tx_done")
    output wire [7:0] d_in,         // dato a transmitir (hacia Tx)
    output wire       tx_start      // arranque (hacia Tx)
);

    //=========================================================
    // FIFO Rx (idéntica a la que ya tenías)
    //=========================================================
    reg [7:0] rx_mem [0:3];
    reg [1:0] wp = 0;
    reg [1:0] rp = 0;
    
    //contador para muestreo de datos en buffer rx
    reg [2:0] counter = 0; 
    
    assign rx_empty = (counter==0);
    assign rx_full = (counter==4);
    assign r_data   = rx_mem[rp];
    

    //=========================================================
    // FIFO Tx (nueva)
    //=========================================================
    reg [7:0] tx_mem [0:3];
    reg [1:0] twp = 0;        // write pointer (lado ALU)
    reg [1:0] trp = 0;        // read pointer  (lado UART)
    reg [2:0] ocup = 0;       // ocupación 0..4 => permite detectar "llena"
    reg       tx_ready = 1;   // 1 => Tx en IDLE, puede aceptar un byte

    wire tx_empty = (ocup == 0);
    assign tx_full  = (ocup == 4);
    assign d_in     = tx_mem[trp];             // mux: cabeza de la FIFO
    assign tx_start = tx_ready && !tx_empty;   // pulso de exactamente 1 clk

    always @(posedge clk) begin
        // ----- FIFO Rx: sin cambios -----
        if (rx_done_tick && !rx_full) begin
            rx_mem[wp] <= dout;
            wp <= wp + 1;
            counter<=counter+1;
        end
        if (rd_uart && !rx_empty) begin
            rp <= rp + 1;
            counter<=counter-1;
        end

        // ----- FIFO Tx: escritura (lado ALU) -----
        if (wr_uart && !tx_full) begin
            tx_mem[twp] <= w_data;
            twp <= twp + 1;
        end

        // ----- FIFO Tx: lectura (lado UART) -----
        // En el borde en que tx_start está alto, el Tx latchea d_in,
        // así que el "pop" se puede hacer en ese mismo borde.
        if (tx_start) begin
            trp      <= trp + 1;
            tx_ready <= 0;         // Tx ocupado durante toda la trama
        end
        else if (tx_done_tick)
            tx_ready <= 1;         // el Tx volvió a IDLE: pide el próximo

        // ----- contador de ocupación -----
        case ({wr_uart && !tx_full, tx_start})
            2'b10:   ocup <= ocup + 1;   // solo escritura
            2'b01:   ocup <= ocup - 1;   // solo lectura
            default: ocup <= ocup;       // nada, o escritura+lectura juntas
        endcase
    end
endmodule