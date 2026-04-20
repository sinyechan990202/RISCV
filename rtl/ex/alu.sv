// Pure combinational ALU — no registers
module alu #(
    parameter XLEN = 32
) (
    input  logic [XLEN-1:0] a_i,
    input  logic [XLEN-1:0] b_i,
    input  logic [4:0]      alu_op_i,

    output logic [XLEN-1:0] result_o
);

    // alu_op encoding
    localparam ADD    = 5'b00000;
    localparam SUB    = 5'b00001;
    localparam AND    = 5'b00010;
    localparam OR     = 5'b00011;
    localparam XOR    = 5'b00100;
    localparam SLL    = 5'b00101;
    localparam SRL    = 5'b00110;
    localparam SRA    = 5'b00111;
    localparam SLT    = 5'b01000;
    localparam SLTU   = 5'b01001;
    localparam LUI    = 5'b01010;
    localparam AUIPC  = 5'b01011;
    localparam PASS_A = 5'b01100;

    logic [4:0] shamt;

    always_comb begin
        shamt    = b_i[4:0];
        result_o = {XLEN{1'b0}};

        unique case (alu_op_i)
            ADD:    result_o = a_i + b_i;
            SUB:    result_o = a_i - b_i;
            AND:    result_o = a_i & b_i;
            OR:     result_o = a_i | b_i;
            XOR:    result_o = a_i ^ b_i;
            SLL:    result_o = a_i << shamt;
            SRL:    result_o = a_i >> shamt;
            SRA:    result_o = XLEN'($signed(a_i) >>> shamt);
            SLT:    result_o = {{(XLEN-1){1'b0}}, ($signed(a_i) < $signed(b_i))};
            SLTU:   result_o = {{(XLEN-1){1'b0}}, (a_i < b_i)};
            LUI:    result_o = b_i;
            AUIPC:  result_o = a_i + b_i;
            PASS_A: result_o = a_i;
            default: result_o = {XLEN{1'b0}};
        endcase
    end

endmodule
