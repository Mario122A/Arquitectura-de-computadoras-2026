`timescale 1ns / 1ps


module alu_top
    #(parameter DATA_WIDTH = 8,
      parameter OPCODE_WIDTH = 6)
    (
    input [DATA_WIDTH-1:0]SW,
    output reg [DATA_WIDTH-1:0]S_LED,
    output reg C_LED,
    
    input A_btn,
    input B_btn,
    input OP_btn,
    
    input clk,
    
    input rst
    
    );
    
    reg [DATA_WIDTH-1:0] A;
    reg [DATA_WIDTH-1:0] B;
    reg [OPCODE_WIDTH-1:0] OP;
    wire [DATA_WIDTH-1:0] S;
    
    wire C;
    
    localparam [1:0]
        S_WAIT_A = 2'b00,
        S_WAIT_B = 2'b01,
        S_WAIT_OP = 2'b10,
        S_CALC = 2'b11;
        
    reg [1:0] state = S_WAIT_A;
    
    aluCombin alu(.A(A), .B(B), .OP(OP), .S(S), .C(C));
    
    
    always@(posedge clk) begin
    if (rst) begin
        state <= S_WAIT_A;
        S_LED <= 0;
        C_LED <= 0;
    end else begin
        case (state)
            S_WAIT_A: begin
                if(A_btn) begin
                    A <= SW;
                    state <= S_WAIT_B;
                end
            end
            
            
            S_WAIT_B: begin
                if(B_btn) begin
                    B <= SW;
                    state <= S_WAIT_OP;
                end
            end
            
            S_WAIT_OP: begin
                if(OP_btn) begin
                    OP <= SW;
                    state <= S_CALC;
                end
            end
            
            S_CALC: begin
                S_LED <= S;
                C_LED <= C;
                state <= S_WAIT_A;
            end          
                    
           default: state <= S_WAIT_A;
        endcase
    end
  end
endmodule
