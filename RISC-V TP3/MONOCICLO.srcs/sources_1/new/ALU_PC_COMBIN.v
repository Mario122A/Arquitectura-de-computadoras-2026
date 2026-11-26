`timescale 1ns / 1ps

module ALU_PC_COMBIN
    #(parameter DATA_WIDTH = 32)
    (
    input [DATA_WIDTH-1:0]A,
    input [DATA_WIDTH-1:0]B,
    
    output reg [DATA_WIDTH-1:0]S,
    output reg C
    );
  
    always@(*)begin
        {C,S} = A+B;
    end

endmodule