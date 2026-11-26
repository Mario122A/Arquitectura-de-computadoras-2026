`timescale 1ns / 1ps

module ALU_PC_TOP
    #(parameter DATA_WIDTH   = 32)
    (
    input wire A,
    input wire B,
    output reg OUTPUT,
    input wire CLK
    );
    
    wire [DATA_WIDTH-1:0] s_sync; //intermediario para sincronización con clock
    wire                  c_sync;
    
    ALU_PC_COMBIN
    #(
.DATA_WIDTH(DATA_WIDTH))
    alu_pc 
    (
    .A(A),
    .B(B),
    .S(a_sync),
    .C(c_sync)
    );
    
    always@(posedge CLK)begin
        OUTPUT <= s_sync;
    end
endmodule
