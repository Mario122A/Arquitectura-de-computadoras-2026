`timescale 1ns / 1ps
module CONTROL_UNIT (
    input  wire [6:0] opcode,
    output reg  [2:0] imm_src,
    output reg        reg_write,
    output reg        alu_src,     // 0: rs2, 1: imm_out
    output reg        mem_read,
    output reg        mem_write,
    output reg        branch,
    output reg        jump,
    output reg  [1:0] alu_op,
    output reg  [1:0] result_src   // 0: ALU, 1: MEM, 2: PC+4, 3: IMM
);
    localparam [6:0] OP_R      = 7'b0110011;
    localparam [6:0] OP_I_IMM  = 7'b0010011;
    localparam [6:0] OP_I_LOAD = 7'b0000011;
    localparam [6:0] OP_S      = 7'b0100011;
    localparam [6:0] OP_B      = 7'b1100011;
    localparam [6:0] OP_U_LUI  = 7'b0110111;
    localparam [6:0] OP_J_JAL  = 7'b1101111;
    localparam [6:0] OP_I_JALR = 7'b1100111;

    always @(*) begin
        // Valores seguros por defecto (evita latches y escrituras accidentales)
        imm_src    = 3'd0;
        reg_write  = 1'b0;
        alu_src    = 1'b0;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        branch     = 1'b0;
        jump       = 1'b0;
        alu_op     = 2'b00;
        result_src = 2'b00;

        case (opcode)
            OP_R: begin
                reg_write  = 1'b1;
                alu_src    = 1'b0;
                alu_op     = 2'b10;
                result_src = 2'b00;
            end
            OP_I_IMM: begin
                imm_src    = 3'd0; // I
                reg_write  = 1'b1;
                alu_src    = 1'b1;
                alu_op     = 2'b11; // I-type ALU
                result_src = 2'b00;
            end
            OP_I_LOAD: begin
                imm_src    = 3'd0; // I
                reg_write  = 1'b1;
                alu_src    = 1'b1;
                mem_read   = 1'b1;
                alu_op     = 2'b00; // suma para dirección
                result_src = 2'b01;
            end
            OP_S: begin
                imm_src    = 3'd1; // S
                alu_src    = 1'b1;
                mem_write  = 1'b1;
                alu_op     = 2'b00; // suma para dirección
            end
            OP_B: begin
                imm_src    = 3'd2; // B
                branch     = 1'b1;
                alu_op     = 2'b01; // comparación
            end
            OP_U_LUI: begin
                imm_src    = 3'd3; // U
                reg_write  = 1'b1;
                result_src = 2'b11; // inmediato directo
            end
            OP_J_JAL: begin
                imm_src    = 3'd4; // J
                reg_write  = 1'b1;
                jump       = 1'b1;
                result_src = 2'b10; // PC + 4
            end
            OP_I_JALR: begin
                imm_src    = 3'd0; // I
                reg_write  = 1'b1;
                alu_src    = 1'b1;
                jump       = 1'b1;
                alu_op     = 2'b00; // rs1 + imm
                result_src = 2'b10; // PC + 4
            end
            default: ;
        endcase
    end
endmodule