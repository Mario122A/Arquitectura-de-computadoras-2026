`timescale 1ns / 1ps

module aluCombin
    #(parameter DATA_WIDTH = 8,
      parameter OPCODE_WIDTH = 6)
    (
    input [DATA_WIDTH-1:0]A,
    input [DATA_WIDTH-1:0]B,
    input [OPCODE_WIDTH-1:0]OP,
    output reg [DATA_WIDTH-1:0]S,
    output reg C
    );
    
    localparam SUM_CODE = 6'b100000;
    localparam SUB_CODE = 6'b100010;
    localparam AND_CODE = 6'b100100;
    localparam OR_CODE  = 6'b100101;
    localparam XOR_CODE = 6'b100110;
    localparam SRA_CODE = 6'b000011;
    localparam SRL_CODE = 6'b000010;
    localparam NOR_CODE = 6'b100111;
    
    always@(*)begin
        S = 0;
        C = 0;
        case(OP)
            SUM_CODE: begin
                {C,S} = A+B;
            end
            SUB_CODE: begin
                {C,S} = A-B;
            end
            AND_CODE: begin
                S = A&B;
            end
            OR_CODE: begin
                S = A|B;
            end
            XOR_CODE: begin
                S = A^B;
            end
            SRA_CODE: begin
                S = A >>> B;
            end
            SRL_CODE: begin
                S = A >> B;
            end
            NOR_CODE: begin
                S = ~(A|B);
            end
            default: begin
            S = 0;
            C = 0;
            end
        endcase
    end
    
    
endmodule