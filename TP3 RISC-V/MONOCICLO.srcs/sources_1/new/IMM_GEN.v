module IMM_GEN (
    input  wire [2:0]  imm_src,
    input  wire [31:7] inst_upper, // o inst[31:0] si preferís pasar la instrucción entera
    output reg  [31:0] imm_out
);
    localparam [2:0] IMM_I = 3'd0;
    localparam [2:0] IMM_S = 3'd1;
    localparam [2:0] IMM_B = 3'd2;
    localparam [2:0] IMM_U = 3'd3;
    localparam [2:0] IMM_J = 3'd4;

    always @(*) begin
        case (imm_src)
            IMM_I: imm_out = {{20{inst_upper[31]}}, inst_upper[31:20]};
            IMM_S: imm_out = {{20{inst_upper[31]}}, inst_upper[31:25], inst_upper[11:7]};
            IMM_B: imm_out = {{19{inst_upper[31]}}, inst_upper[31], inst_upper[7], inst_upper[30:25], inst_upper[11:8], 1'b0};
            IMM_U: imm_out = {inst_upper[31:12], 12'b0};
            IMM_J: imm_out = {{11{inst_upper[31]}}, inst_upper[31], inst_upper[19:12], inst_upper[20], inst_upper[30:21], 1'b0};
            default: imm_out = 32'd0;
        endcase
    end
endmodule