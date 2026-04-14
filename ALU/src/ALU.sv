// ============================================================
// RISC-V RV32I ALU
// Target Board : Zybo Z7-20 (Xilinx Zynq-7000 XC7Z020-1CLG400C)
// ============================================================
`timescale 1ns / 1ps

module ALU (
    input  logic [31:0] operand_a,   // rs1 or PC
    input  logic [31:0] operand_b,   // rs2 or immediate
    input  logic [ 3:0] alu_ctrl,    // ALU operation select
    output logic [31:0] result,      // ALU result
    output logic        zero,        // result == 0
    output logic        negative,    // result[31]
    output logic        overflow,    // signed overflow
    output logic        carry_out    // unsigned carry/borrow
);

    // ----------------------------------------------------------
    // ALU control encoding (matches standard RISC-V decode)
    // ----------------------------------------------------------
    localparam ALU_ADD  = 4'b0000;  // ADD
    localparam ALU_SUB  = 4'b0001;  // SUB
    localparam ALU_AND  = 4'b0010;  // AND
    localparam ALU_OR   = 4'b0011;  // OR
    localparam ALU_XOR  = 4'b0100;  // XOR
    localparam ALU_SLL  = 4'b0101;  // Shift Left Logical
    localparam ALU_SRL  = 4'b0110;  // Shift Right Logical
    localparam ALU_SRA  = 4'b0111;  // Shift Right Arithmetic
    localparam ALU_SLT  = 4'b1000;  // Set Less Than (signed)
    localparam ALU_SLTU = 4'b1001;  // Set Less Than Unsigned
    localparam ALU_LUI  = 4'b1010;  // Pass operand_b (LUI / AUIPC support)

    // ----------------------------------------------------------
    // Internal signals
    // ----------------------------------------------------------
    logic [32:0] add_sub_result;    // 33-bit for carry/borrow detection
    logic        sub_mode;

    assign sub_mode = (alu_ctrl == ALU_SUB)  ||
                      (alu_ctrl == ALU_SLT)  ||
                      (alu_ctrl == ALU_SLTU);

    // Shared adder/subtractor (saves LUTs on XC7Z020)
    assign add_sub_result = sub_mode
        ? ({1'b0, operand_a} + {1'b0, ~operand_b} + 33'd1)  // A - B
        : ({1'b0, operand_a} + {1'b0,  operand_b});          // A + B

    // ----------------------------------------------------------
    // Main ALU mux
    // ----------------------------------------------------------
    always_comb begin
        result = 32'd0;
        case (alu_ctrl)
            ALU_ADD  : result = add_sub_result[31:0];
            ALU_SUB  : result = add_sub_result[31:0];
            ALU_AND  : result = operand_a & operand_b;
            ALU_OR   : result = operand_a | operand_b;
            ALU_XOR  : result = operand_a ^ operand_b;
            ALU_SLL  : result = operand_a << operand_b[4:0];
            ALU_SRL  : result = operand_a >> operand_b[4:0];
            ALU_SRA  : result = $signed(operand_a) >>> operand_b[4:0];
            ALU_SLT  : result = {31'd0, $signed(operand_a) < $signed(operand_b)};
            ALU_SLTU : result = {31'd0, operand_a < operand_b};
            ALU_LUI  : result = operand_b;
            default  : result = 32'd0;
        endcase
    end

    // ----------------------------------------------------------
    // Flags
    // ----------------------------------------------------------
    assign zero      = (result == 32'd0);
    assign negative  = result[31];
    assign carry_out = add_sub_result[32];
    assign overflow  = (alu_ctrl == ALU_ADD)
                       ? (~operand_a[31] & ~operand_b[31] &  result[31]) |
                         ( operand_a[31] &  operand_b[31] & ~result[31])
                       : (alu_ctrl == ALU_SUB)
                       ? (~operand_a[31] &  operand_b[31] &  result[31]) |
                         ( operand_a[31] & ~operand_b[31] & ~result[31])
                       : 1'b0;

endmodule
