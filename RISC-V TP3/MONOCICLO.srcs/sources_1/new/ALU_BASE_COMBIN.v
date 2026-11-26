`timescale 1ns / 1ps

module ALU_BASE_COMBIN
    #(parameter DATA_WIDTH = 32,
      parameter OPCODE_WIDTH = 6)
    (
    input [DATA_WIDTH-1:0]A,
    input [DATA_WIDTH-1:0]B,
    input [OPCODE_WIDTH-1:0]OPCODE,
    output reg [DATA_WIDTH-1:0]S,
    output reg C,
    output wire ZERO
    );
    
    localparam SUM_CODE = 6'b100000;
    localparam SUB_CODE = 6'b100010;
    localparam AND_CODE = 6'b100100;
    localparam OR_CODE  = 6'b100101;
    localparam XOR_CODE = 6'b100110;
    localparam SRA_CODE = 6'b000011;
    localparam SRL_CODE = 6'b000010;
    localparam NOR_CODE = 6'b100111;
    localparam SLL_CODE = 6'b000001;
    localparam SLT_CODE = 6'b101010;
    localparam SLTU_CODE = 6'b101011;
    
    wire [4:0] shift = B[4:0];
        
    always@(*)begin
        S = 0;
        C = 0;
        case(OPCODE)
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
            NOR_CODE: begin
                S = ~(A|B);
            end
            SRA_CODE: begin
                S = $signed(A) >>> shift;
            end
            SRL_CODE: begin
                S = A >> shift;
            end
            SLL_CODE: begin
                S = A << shift;
            end
            SLT_CODE: begin  
                S = ($signed(A) < $signed(B)) ? {{(DATA_WIDTH-1){1'b0}}, 1'b1} : {DATA_WIDTH{1'b0}};
            end
            SLTU_CODE: begin
                S = (A < B) ? {{(DATA_WIDTH-1){1'b0}}, 1'b1} : {DATA_WIDTH{1'b0}};
            end
            default: begin
                S = 0;
                C = 0;
            end
        endcase
    end
    
    assign ZERO = (S=={DATA_WIDTH{1'b0}});
    
endmodule