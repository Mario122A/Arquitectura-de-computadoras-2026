`timescale 1ns / 1ps

module alu_top_tb;

    // Parameters
    parameter DATA_WIDTH = 8;
    parameter OPCODE_WIDTH = 6;

    // Testbench signals
    reg [DATA_WIDTH-1:0] SW;
    reg A_btn;
    reg B_btn;
    reg OP_btn;
    reg clk;
    reg rst;

    wire [DATA_WIDTH-1:0] S_LED;
    wire C_LED;

    // Instantiate the Unit Under Test (UUT)
    alu_top #(
        .DATA_WIDTH(DATA_WIDTH),
        .OPCODE_WIDTH(OPCODE_WIDTH)
    ) uut (
        .SW(SW),
        .S_LED(S_LED),
        .C_LED(C_LED),
        .A_btn(A_btn),
        .B_btn(B_btn),
        .OP_btn(OP_btn),
        .rst(rst),
        .clk(clk)
    );

    // Generate a 100 MHz clock (10ns period)
    always #5 clk = ~clk;

    initial begin
        // Initialize inputs
        clk = 0;
        SW = 0;
        A_btn = 0;
        B_btn = 0;
        OP_btn = 0;

        // Wait for global reset
        #20;

        // --- Step 1: Load A = 10 ---
        SW = 8'd10;
        #10;
        A_btn = 1; // Press button A
        #20;
        A_btn = 0; // Release button A
        #10;

        // --- Step 2: Load B = 5 ---
        SW = 8'd5;
        #10;
        B_btn = 1; // Press button B
        #20;
        B_btn = 0; // Release button B
        #10;

        // --- Step 3: Load OP = SUM_CODE (6'b100000) ---
        SW = 6'b100000; 
        #10;
        OP_btn = 1; // Press button OP (triggers S_CALC instantly)
        #20;
        OP_btn = 0; // Release button OP
        
        // Wait a couple clock cycles to observe the LED output
        #30;

        // --- Step 4: Try a second calculation (SUB_CODE: 6'b100010) ---
        // Back to state S_WAIT_A automatically
        SW = 8'd20; // New A
        #10;
        A_btn = 1; #20; A_btn = 0; #10;

        SW = 8'd8;  // New B
        #10;
        B_btn = 1; #20; B_btn = 0; #10;

        SW = 6'b100010; // SUB_CODE
        #10;
        OP_btn = 1; #20; OP_btn = 0; #10;

        #40;
        
        
        // --- Step 5: Try an addition with a Carry (250 + 10 = 260 -> C_LED = 1) ---
        SW = 8'd250; // New A
        #10;
        A_btn = 1; #20; A_btn = 0; #10;

        SW = 8'd8;   // New B (using 8 for a nice clean result: 250 + 8 = 258 -> S_LED = 2, C_LED = 1)
        #10;
        B_btn = 1; #20; B_btn = 0; #10;

        SW = 6'b100000; // SUM_CODE
        #10;
        OP_btn = 1; #20; OP_btn = 0; #10;

        #40;
        
        // --- Step 6: Test Reset Functionality ---
        rst = 0;
        #10;
        
        // Load A = 50, then get stuck waiting for B
        SW = 8'd50;
        #10;
        A_btn = 1; #20; A_btn = 0; #10; 
        // At this point, the FSM is in S_WAIT_B. Let's abort and reset!

        #20;
        rst = 1; // Assert reset
        #20;
        rst = 0; // Release reset
        #20;
        
        $finish;
    end
    //initial $monitor($time, A_btn, B_btn, OP_btn, S_LED, C_LED);
endmodule