`timescale 1ns / 1ps

module tb_alu_top;

    localparam DATA_WIDTH   = 32;
    localparam OPCODE_WIDTH = 6;

    // Entradas al DUT (Device Under Test)
    reg  [DATA_WIDTH-1:0]   A;
    reg  [DATA_WIDTH-1:0]   B;
    reg                     CLK;
    reg  [OPCODE_WIDTH-1:0] OPCODE;

    // Salidas del DUT
    wire                    ZERO;
    wire [DATA_WIDTH-1:0]   OUT;

    // Códigos de operación (deben coincidir con ALU_BASE_COMBIN)
    localparam [OPCODE_WIDTH-1:0] SUM_CODE  = 6'b100000;
    localparam [OPCODE_WIDTH-1:0] SUB_CODE  = 6'b100010;
    localparam [OPCODE_WIDTH-1:0] AND_CODE  = 6'b100100;
    localparam [OPCODE_WIDTH-1:0] OR_CODE   = 6'b100101;
    localparam [OPCODE_WIDTH-1:0] XOR_CODE  = 6'b100110;
    localparam [OPCODE_WIDTH-1:0] SRA_CODE  = 6'b000011;
    localparam [OPCODE_WIDTH-1:0] SRL_CODE  = 6'b000010;
    localparam [OPCODE_WIDTH-1:0] NOR_CODE  = 6'b100111;
    localparam [OPCODE_WIDTH-1:0] SLL_CODE  = 6'b000001;
    localparam [OPCODE_WIDTH-1:0] SLT_CODE  = 6'b101010;
    localparam [OPCODE_WIDTH-1:0] SLTU_CODE = 6'b101011;

    // Instancia de alu_top
    alu_top #(
        .DATA_WIDTH(DATA_WIDTH),
        .OPCODE_WIDTH(OPCODE_WIDTH)
    ) dut (
        .A(A),
        .B(B),
        .CLK(CLK),
        .OPCODE(OPCODE),
        .ZERO(ZERO),
        .OUT(OUT)
    );

    // Generación de reloj: período de 10 ns (100 MHz)
    initial begin
        CLK = 1'b0;
        forever #5 CLK = ~CLK;
    end

    // Tarea auxiliar para aplicar estímulos y esperar el flanco de reloj
    task apply_and_check(
        input [DATA_WIDTH-1:0]   in_a,
        input [DATA_WIDTH-1:0]   in_b,
        input [OPCODE_WIDTH-1:0] in_op,
        input [8*8-1:0]          op_name
    );
    begin
        @(negedge CLK);
        A      = in_a;
        B      = in_b;
        OPCODE = in_op;

        // Como OUT y ZERO se actualizan en posedge CLK, esperamos un ciclo
        @(posedge CLK);
        #1; // Pequeño delta para leer valores estables tras el flanco
        $display("t=%0t ns | OP=%0s (%b) | A=%h (%0d) | B=%h (%0d) | OUT=%h (%0d) | ZERO=%b",
                 $time, op_name, OPCODE, A, $signed(A), B, $signed(B), OUT, $signed(OUT), ZERO);
    end
    endtask

    initial begin
        // Volcado de señales para GTKWave / Vivado / ModelSim
        $dumpfile("tb_alu_top.vcd");
        $dumpvars(0, tb_alu_top);

        // Inicialización
        A      = 32'd0;
        B      = 32'd0;
        OPCODE = 6'b000000;

        @(posedge CLK);

        // 1. Suma normal
        apply_and_check(32'd15, 32'd25, SUM_CODE, "SUM");

        // 2. Resta que da cero -> debe activar ZERO = 1
        apply_and_check(32'd42, 32'd42, SUB_CODE, "SUB_ZERO");

        // 3. Resta con resultado negativo
        apply_and_check(32'd10, 32'd30, SUB_CODE, "SUB_NEG");

        // 4. AND / OR / XOR / NOR
        apply_and_check(32'hF0F0_0000, 32'hFF00_0000, AND_CODE, "AND");
        apply_and_check(32'hF0F0_0000, 32'h0F0F_0000, OR_CODE,  "OR");
        apply_and_check(32'hFF00_AA55, 32'h0FF0_AA55, XOR_CODE, "XOR");
        apply_and_check(32'h0000_0000, 32'h0000_0000, NOR_CODE, "NOR");

        // 5. Desplazamientos: SRA (aritmético con signo) vs SRL (lógico) y SLL
        apply_and_check(-32'sd16, 32'd2, SRA_CODE, "SRA_NEG");
        apply_and_check(32'h8000_0000, 32'd4, SRL_CODE, "SRL");
        apply_and_check(32'h0000_0001, 32'd4, SLL_CODE, "SLL");

        // 6. Comparaciones: SLT (con signo) vs SLTU (sin signo)
        // En sin signo, 32'hFFFF_FFFF es muy grande, así que A < B es falso (0)
        // En con signo, 32'hFFFF_FFFF es -1, por lo que -1 < 1 es verdadero (1)
        apply_and_check(32'hFFFF_FFFF, 32'd1, SLT_CODE,  "SLT");
        apply_and_check(32'hFFFF_FFFF, 32'd1, SLTU_CODE, "SLTU");

        // 7. Opcode no definido -> debe ir a default (OUT = 0, ZERO = 1)
        apply_and_check(32'd123, 32'd456, 6'b111111, "DEFAULT");

        #20;
        $display("--- Fin de la simulacion ---");
        $finish;
    end

endmodule