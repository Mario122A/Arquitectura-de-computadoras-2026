`timescale 1ns / 1ps

module imem_rv32 #(
    parameter ADDR_WIDTH = 10,              // 1024 palabras de 32 bits = 4 KB de instrucciones
    parameter MEM_DEPTH  = (1 << ADDR_WIDTH)
)(
    input  wire                  clk,
    // Puerto de ejecución (etapa IF)
    input  wire [ADDR_WIDTH-1:0] instr_word_addr, // ej: pc[ADDR_WIDTH+1:2] si pc es en bytes
    output wire [31:0]           instr_data,

    // Puerto de carga/reprogramación por UART / Debug Unit
    input  wire                  prog_we,
    input  wire [ADDR_WIDTH-1:0] prog_word_addr,
    input  wire [31:0]           prog_wdata,
    output wire [31:0]           dbg_read_data
);

    reg [31:0] mem [0:MEM_DEPTH-1];
    integer i;

    initial begin
        for (i = 0; i < MEM_DEPTH; i = i + 1) begin
            mem[i] = 32'h00000013; // NOP (addi x0, x0, 0) por defecto
        end
    end

    // Escritura síncrona desde UART para cargar/reprogramar
    always @(posedge clk) begin
        if (prog_we) begin
            mem[prog_word_addr] <= prog_wdata;
        end
    end

    // Lectura combinacional para IF (facilita pipeline y flush sin latencia extra)
    assign instr_data    = mem[instr_word_addr];
    assign dbg_read_data = mem[prog_word_addr];

endmodule