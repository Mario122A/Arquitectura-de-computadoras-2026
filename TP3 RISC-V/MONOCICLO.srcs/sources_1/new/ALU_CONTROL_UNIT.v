`timescale 1ns / 1ps

module ALU_CONTROL_UNIT #(
    parameter OPCODE_WIDTH = 6
)(
    input  wire [1:0]              alu_op,     // Viene de Main Control
    input  wire [2:0]              funct3,     // inst[14:12]
    input  wire                    funct7_5,   // inst[30]
    output reg  [OPCODE_WIDTH-1:0] alu_opcode  // Va a ALU_BASE_COMBIN
);
    localparam [5:0] SUM_CODE  = 6'b100000;
    localparam [5:0] SUB_CODE  = 6'b100010;
    localparam [5:0] AND_CODE  = 6'b100100;
    localparam [5:0] OR_CODE   = 6'b100101;
    localparam [5:0] XOR_CODE  = 6'b100110;
    localparam [5:0] SRA_CODE  = 6'b000011;
    localparam [5:0] SRL_CODE  = 6'b000010;
    localparam [5:0] SLL_CODE  = 6'b000001;
    localparam [5:0] SLT_CODE  = 6'b101010;
    localparam [5:0] SLTU_CODE = 6'b101011;

    always @(*) begin
        alu_opcode = SUM_CODE;

        case (alu_op)
            // 1) Direcciones de memoria y jalr: siempre suma, no importan funct3 ni funct7_5
            2'b00: begin
                alu_opcode = SUM_CODE;
            end

            // 2) Branches (beq / bne): resta A - B para comparar
            2'b01: begin
                alu_opcode = SUB_CODE;
            end

            // 3) R-type: usa funct3, y funct7_5 solo en 3'b000 (add/sub) y 3'b101 (srl/sra)
            2'b10: begin
                case (funct3)
                    3'b000: alu_opcode = funct7_5 ? SUB_CODE : SUM_CODE; // sub vs add
                    3'b001: alu_opcode = SLL_CODE;                        // sll (no mira funct7_5)
                    3'b010: alu_opcode = SLT_CODE;                        // slt
                    3'b011: alu_opcode = SLTU_CODE;                       // sltu
                    3'b100: alu_opcode = XOR_CODE;                        // xor
                    3'b101: alu_opcode = funct7_5 ? SRA_CODE : SRL_CODE; // sra vs srl
                    3'b110: alu_opcode = OR_CODE;                         // or
                    3'b111: alu_opcode = AND_CODE;                        // and
                    default: alu_opcode = SUM_CODE;
                endcase
            end

            // 4) I-type aritmética/lógica: usa funct3, y funct7_5 solo en 3'b101 (srli/srai)
            2'b11: begin
                case (funct3)
                    3'b000: alu_opcode = SUM_CODE;                        // addi (funct7_5 es parte del imm, se ignora)
                    3'b001: alu_opcode = SLL_CODE;                        // slli
                    3'b010: alu_opcode = SLT_CODE;                        // slti
                    3'b011: alu_opcode = SLTU_CODE;                       // sltiu
                    3'b100: alu_opcode = XOR_CODE;                        // xori
                    3'b101: alu_opcode = funct7_5 ? SRA_CODE : SRL_CODE; // srai vs srli
                    3'b110: alu_opcode = OR_CODE;                         // ori
                    3'b111: alu_opcode = AND_CODE;                        // andi
                    default: alu_opcode = SUM_CODE;
                endcase
            end

            default: alu_opcode = SUM_CODE;
        endcase
    end
endmodule