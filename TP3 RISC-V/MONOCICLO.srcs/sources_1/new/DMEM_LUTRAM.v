`timescale 1ns / 1ps

module DEMEM_LUTRAM #(
    parameter ADDR_WIDTH = 10,              // 1024 palabras de 32 bits = 4 KB de datos
    parameter MEM_DEPTH  = (1 << ADDR_WIDTH)
)(
    input  wire                  clk,

    // Puerto de ejecución (etapa MEM)
    input  wire                  mem_re,        // 1 = lectura (lb, lh, lw, lbu, lhu) desde CONTROL_UNIT
    input  wire                  mem_we,        // 1 = escritura (sb, sh, sw) desde CONTROL_UNIT
    input  wire [31:0]           addr,          // dirección en bytes desde ALU
    input  wire [31:0]           wdata,         // dato rs2 sin alinear
    input  wire [2:0]            funct3,        // instr[14:12] vía ID/EX -> EX/MEM
    output reg  [31:0]           rdata,         // dato ya alineado y extendido (signo o cero)

    // Puerto de lectura para Debug Unit (enviar memoria usada por UART)
    input  wire [ADDR_WIDTH-1:0] dbg_word_addr,
    output wire [31:0]           dbg_word_data
);

    reg [31:0] mem [0:MEM_DEPTH-1];
    reg [3:0]  byte_en;
    reg [31:0] aligned_wdata;

    wire [ADDR_WIDTH-1:0] word_addr = addr[ADDR_WIDTH+1:2];
    wire [31:0] raw_word;
    wire [15:0] half_sel;
    wire [7:0]  byte_sel;

    integer i;

    initial begin
        for (i = 0; i < MEM_DEPTH; i = i + 1) begin
            mem[i] = 32'd0;
        end
    end

    // Decodificación de byte enable y alineación de escritura según funct3 y addr[1:0]
    always @(*) begin
        byte_en       = 4'b0000;
        aligned_wdata = 32'd0;

        if (mem_we) begin
            case (funct3)
                3'b000: begin // SB
                    case (addr[1:0])
                        2'b00: begin byte_en = 4'b0001; aligned_wdata = {24'd0, wdata[7:0]}; end
                        2'b01: begin byte_en = 4'b0010; aligned_wdata = {16'd0, wdata[7:0], 8'd0}; end
                        2'b10: begin byte_en = 4'b0100; aligned_wdata = {8'd0, wdata[7:0], 16'd0}; end
                        2'b11: begin byte_en = 4'b1000; aligned_wdata = {wdata[7:0], 24'd0}; end
                    endcase
                end
                3'b001: begin // SH
                    case (addr[1])
                        1'b0: begin byte_en = 4'b0011; aligned_wdata = {16'd0, wdata[15:0]}; end
                        1'b1: begin byte_en = 4'b1100; aligned_wdata = {wdata[15:0], 16'd0}; end
                    endcase
                end
                3'b010: begin // SW
                    byte_en       = 4'b1111;
                    aligned_wdata = wdata;
                end
                default: begin
                    byte_en       = 4'b0000;
                    aligned_wdata = 32'd0;
                end
            endcase
        end
    end

    // Escritura síncrona byte a byte
    always @(posedge clk) begin
        if (mem_we) begin
            if (byte_en[0]) mem[word_addr][7:0]   <= aligned_wdata[7:0];
            if (byte_en[1]) mem[word_addr][15:8]  <= aligned_wdata[15:8];
            if (byte_en[2]) mem[word_addr][23:16] <= aligned_wdata[23:16];
            if (byte_en[3]) mem[word_addr][31:24] <= aligned_wdata[31:24];
        end
    end

    wire [31:0] raw_word = mem_re ? mem[word_addr] : 32'd0;
    wire [15:0] half_sel = mem_re ? (addr[1] ? raw_word[31:16] : raw_word[15:0]) : 16'd0;
    wire [7:0]  byte_sel = mem_re ? (
                               (addr[1:0] == 2'b00) ? raw_word[7:0]   :
                               (addr[1:0] == 2'b01) ? raw_word[15:8]  :
                               (addr[1:0] == 2'b10) ? raw_word[23:16] : raw_word[31:24]
                           ) : 8'd0;

    always @(*) begin
        if (!mem_re) begin
            rdata = 32'd0;
        end else begin
            case (funct3)
                3'b000:  rdata = {{24{byte_sel[7]}},  byte_sel}; // LB (sign-extend)
                3'b001:  rdata = {{16{half_sel[15]}}, half_sel}; // LH (sign-extend)
                3'b010:  rdata = raw_word;                       // LW
                3'b100:  rdata = {24'd0, byte_sel};              // LBU (zero-extend)
                3'b101:  rdata = {16'd0, half_sel};              // LHU (zero-extend)
                default: rdata = raw_word;
            endcase
        end
    end

    // Lectura para Debug Unit
    assign dbg_word_data = mem[dbg_word_addr];

endmodule