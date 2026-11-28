`timescale 1ns / 1ps

module PC #(
    parameter RESET_ADDR = 32'h0000_0000
)(
    input  wire        clk,
    input  wire        rst,         // Reset sincrono (activo en alto)
    input  wire        pc_en,       // 1 = permite actualizar PC, 0 = stall / pausado
    input  wire        pc_src,      // 0 = PC + 4, 1 = direccion de salto/branch
    input  wire [31:0] jump_addr,   // Direccion destino (desde EX o ID segun tu diseno)
    output reg  [31:0] pc_out
);

    wire [31:0] pc_plus_4 = pc_out + 32'd4;
    wire [31:0] next_pc   = pc_src ? jump_addr : pc_plus_4;

    always @(posedge clk) begin
        if (rst) begin
            pc_out <= RESET_ADDR;
        end else if (pc_en) begin
            pc_out <= next_pc;
        end
        // Si !pc_en, mantiene pc_out sin tocar el reloj
    end

endmodule