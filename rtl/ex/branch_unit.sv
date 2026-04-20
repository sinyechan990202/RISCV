// Pure combinational Branch/Jump Unit
// Evaluates branch conditions and computes all jump/branch targets.
module branch_unit #(
    parameter XLEN = 32
) (
    input  logic [XLEN-1:0] rs1_i,
    input  logic [XLEN-1:0] rs2_i,
    input  logic [XLEN-1:0] pc_i,
    input  logic [XLEN-1:0] imm_i,
    input  logic [2:0]      funct3_i,

    input  logic             branch_i,
    input  logic             jal_i,
    input  logic             jalr_i,

    output logic             branch_taken_o,
    output logic [XLEN-1:0] branch_target_o, // pc + B-type imm
    output logic [XLEN-1:0] jal_target_o,    // pc + J-type imm
    output logic [XLEN-1:0] jalr_target_o    // (rs1 + I-type imm) & ~1
);

    // Branch condition encoding (funct3)
    localparam BEQ  = 3'b000;
    localparam BNE  = 3'b001;
    localparam BLT  = 3'b100;
    localparam BGE  = 3'b101;
    localparam BLTU = 3'b110;
    localparam BGEU = 3'b111;

    logic cond;

    always_comb begin
        unique case (funct3_i)
            BEQ:    cond = (rs1_i == rs2_i);
            BNE:    cond = (rs1_i != rs2_i);
            BLT:    cond = ($signed(rs1_i) < $signed(rs2_i));
            BGE:    cond = ($signed(rs1_i) >= $signed(rs2_i));
            BLTU:   cond = (rs1_i < rs2_i);
            BGEU:   cond = (rs1_i >= rs2_i);
            default: cond = 1'b0;
        endcase

        branch_taken_o  = branch_i & cond;
        branch_target_o = pc_i + imm_i;
        jal_target_o    = pc_i + imm_i;
        jalr_target_o   = (rs1_i + imm_i) & {{(XLEN-1){1'b1}}, 1'b0}; // LSB clear
    end

endmodule
