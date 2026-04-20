// imm_type encoding: 000=I, 001=S, 010=B, 011=U, 100=J, 101=ZIMM(CSR)
module imm_gen #(
    parameter XLEN = 32
) (
    input  logic [XLEN-1:0] instr,
    input  logic [2:0]      imm_type,
    output logic [XLEN-1:0] imm
);

    always_comb begin
        unique case (imm_type)
            3'b000: imm = {{20{instr[31]}}, instr[31:20]};
            3'b001: imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            3'b010: imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
            3'b011: imm = {instr[31:12], 12'b0};
            3'b100: imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
            3'b101: imm = {{27{1'b0}}, instr[19:15]};
            default: imm = {XLEN{1'b0}};
        endcase
    end

endmodule
