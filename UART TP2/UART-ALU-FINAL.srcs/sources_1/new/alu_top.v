`timescale 1ns / 1ps


module alu_top
    #(parameter DATA_WIDTH = 8,
      parameter OPCODE_WIDTH = 6)
    (
    input [DATA_WIDTH-1:0]r_data_alu,
    output reg [DATA_WIDTH-1:0]w_data_alu,
    output reg C_LED,
    output reg rd_alu = 1'b0,
    output reg wr_alu = 1'b0,
    
    input rx_empty_alu,
    input tx_full_alu,
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
    rd_alu <= 1'b0;
    wr_alu <= 1'b0;
    if (rst) begin
        state <= S_WAIT_A;
        w_data_alu <= 0;
        C_LED <= 0;
    end else begin
        case (state)
            S_WAIT_A: begin
                if(!rx_empty_alu) begin
                    A <= r_data_alu;
                    rd_alu <= 1'b1;
                    state <= S_WAIT_B;
                end
            end
            
            
            S_WAIT_B: begin
                if(!rx_empty_alu) begin
                    B <= r_data_alu;
                    rd_alu <= 1'b1;
                    state <= S_WAIT_OP;
                end
            end
            
            S_WAIT_OP: begin
                if(!rx_empty_alu) begin
                    OP <= r_data_alu;
                    rd_alu <= 1'b1;
                    state <= S_CALC;
                end
            end
            
            S_CALC: begin
                w_data_alu <= S;
                if(!tx_full_alu) begin
                    C_LED <= C;
                    wr_alu <= 1'b1;
                    state <= S_WAIT_A;
                end
            end          
                    
           default: state <= S_WAIT_A;
        endcase
    end
  end
endmodule