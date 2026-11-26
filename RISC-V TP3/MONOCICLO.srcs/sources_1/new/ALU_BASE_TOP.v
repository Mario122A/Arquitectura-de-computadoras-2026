`timescale 1ns / 1ps

module ALU_BASE_TOP
    #(parameter DATA_WIDTH   = 32,
      parameter OPCODE_WIDTH = 6)
    (
    input  wire [DATA_WIDTH-1:0]   A,
    input  wire [DATA_WIDTH-1:0]   B,
    input  wire                    CLK,
    input  wire [OPCODE_WIDTH-1:0] OPCODE,
    output reg                     ZERO,
    output reg  [DATA_WIDTH-1:0]   OUTPUT
    );

    wire [DATA_WIDTH-1:0] s_sync; //intermediario para sincronización con clock
    wire                  c_sync;
    wire                  zero_sync;

    ALU_BASE_COMBIN #(
        .DATA_WIDTH(DATA_WIDTH),
        .OPCODE_WIDTH(OPCODE_WIDTH)
    ) alu_base (
        .A(A),
        .B(B),
        .OPCODE(OPCODE),
        .S(s_sync),
        .C(c_sync),
        .ZERO(zero_sync)
    );

    always @(posedge CLK) begin
        OUTPUT  <= s_sync;
        ZERO <= zero_sync;
    end
endmodule