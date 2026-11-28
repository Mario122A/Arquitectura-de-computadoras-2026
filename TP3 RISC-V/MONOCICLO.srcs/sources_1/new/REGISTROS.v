`timescale 1ns / 1ps

module REGISTROS (
    input  wire        clk,
    input  wire        rst,        // reset síncrono activo en alto (opcional si inicializas)
    input  wire        we,         // habilitación de escritura desde WB
    input  wire [4:0]  rs1_addr,
    input  wire [4:0]  rs2_addr,
    input  wire [4:0]  rd_addr,
    input  wire [31:0] rd_data,
    output wire [31:0] rs1_data,
    output wire [31:0] rs2_data
);

    reg [31:0] regs [0:31];
    integer i;

    // Escritura síncrona en flanco de subida; x0 nunca se sobrescribe
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) begin
                regs[i] <= 32'd0;
            end
        end else if (we && (rd_addr != 5'd0)) begin
            regs[rd_addr] <= rd_data;
        end
    end

    // Lectura combinacional con bypass interno si se lee el mismo registro que se escribe en este ciclo
    assign rs1_data = (rs1_addr == 5'd0) ? 32'd0 :
                      (we && (rd_addr == rs1_addr)) ? rd_data : regs[rs1_addr];

    assign rs2_data = (rs2_addr == 5'd0) ? 32'd0 :
                      (we && (rd_addr == rs2_addr)) ? rd_data : regs[rs2_addr];

endmodule