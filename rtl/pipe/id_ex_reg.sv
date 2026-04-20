// ID/EX Pipeline Register
// Spec: Notion RV32I RTL 설계 명세서 §5
module id_ex_reg #(
    parameter XLEN = 32
) (
    input  logic             clk,
    input  logic             rst_n,

    // Hazard control — flush takes priority over stall
    input  logic             stall,
    input  logic             flush,

    // ── Inputs from ID stage ──────────────────────────────────────────
    input  logic [XLEN-1:0] pc_i,
    input  logic [XLEN-1:0] pc_plus4_i,
    input  logic [XLEN-1:0] rs1_data_i,
    input  logic [XLEN-1:0] rs2_data_i,
    input  logic [XLEN-1:0] imm_i,
    input  logic [4:0]      rs1_i,
    input  logic [4:0]      rs2_i,
    input  logic [4:0]      rd_i,
    input  logic [4:0]      alu_op_i,
    input  logic             alu_src_a_i,
    input  logic             alu_src_b_i,
    input  logic             mem_ren_i,
    input  logic             mem_wen_i,
    input  logic [2:0]      mem_size_i,
    input  logic [1:0]      wb_sel_i,
    input  logic             reg_wen_i,
    input  logic             branch_i,
    input  logic             jal_i,
    input  logic             jalr_i,
    input  logic [2:0]      csr_op_i,
    input  logic [11:0]     csr_addr_i,
    input  logic [2:0]      funct3_i,

    // ── Outputs to EX stage ───────────────────────────────────────────
    output logic [XLEN-1:0] id_ex_pc,
    output logic [XLEN-1:0] id_ex_pc_plus4,
    output logic [XLEN-1:0] id_ex_rs1_data,
    output logic [XLEN-1:0] id_ex_rs2_data,
    output logic [XLEN-1:0] id_ex_imm,
    output logic [4:0]      id_ex_rs1,
    output logic [4:0]      id_ex_rs2,
    output logic [4:0]      id_ex_rd,
    output logic [4:0]      id_ex_alu_op,
    output logic             id_ex_alu_src_a,
    output logic             id_ex_alu_src_b,
    output logic             id_ex_mem_ren,
    output logic             id_ex_mem_wen,
    output logic [2:0]      id_ex_mem_size,
    output logic [1:0]      id_ex_wb_sel,
    output logic             id_ex_reg_wen,
    output logic             id_ex_branch,
    output logic             id_ex_jal,
    output logic             id_ex_jalr,
    output logic [2:0]      id_ex_csr_op,
    output logic [11:0]     id_ex_csr_addr,
    output logic [2:0]      id_ex_funct3
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n || flush) begin
            id_ex_pc       <= {XLEN{1'b0}};
            id_ex_pc_plus4 <= {XLEN{1'b0}};
            id_ex_rs1_data <= {XLEN{1'b0}};
            id_ex_rs2_data <= {XLEN{1'b0}};
            id_ex_imm      <= {XLEN{1'b0}};
            id_ex_rs1      <= 5'b0;
            id_ex_rs2      <= 5'b0;
            id_ex_rd       <= 5'b0;
            id_ex_alu_op   <= 5'b0;
            id_ex_alu_src_a <= 1'b0;
            id_ex_alu_src_b <= 1'b0;
            id_ex_mem_ren  <= 1'b0;
            id_ex_mem_wen  <= 1'b0;
            id_ex_mem_size <= 3'b0;
            id_ex_wb_sel   <= 2'b0;
            id_ex_reg_wen  <= 1'b0;
            id_ex_branch   <= 1'b0;
            id_ex_jal      <= 1'b0;
            id_ex_jalr     <= 1'b0;
            id_ex_csr_op   <= 3'b0;
            id_ex_csr_addr <= 12'b0;
            id_ex_funct3   <= 3'b0;
        end else if (!stall) begin
            id_ex_pc       <= pc_i;
            id_ex_pc_plus4 <= pc_plus4_i;
            id_ex_rs1_data <= rs1_data_i;
            id_ex_rs2_data <= rs2_data_i;
            id_ex_imm      <= imm_i;
            id_ex_rs1      <= rs1_i;
            id_ex_rs2      <= rs2_i;
            id_ex_rd       <= rd_i;
            id_ex_alu_op   <= alu_op_i;
            id_ex_alu_src_a <= alu_src_a_i;
            id_ex_alu_src_b <= alu_src_b_i;
            id_ex_mem_ren  <= mem_ren_i;
            id_ex_mem_wen  <= mem_wen_i;
            id_ex_mem_size <= mem_size_i;
            id_ex_wb_sel   <= wb_sel_i;
            id_ex_reg_wen  <= reg_wen_i;
            id_ex_branch   <= branch_i;
            id_ex_jal      <= jal_i;
            id_ex_jalr     <= jalr_i;
            id_ex_csr_op   <= csr_op_i;
            id_ex_csr_addr <= csr_addr_i;
            id_ex_funct3   <= funct3_i;
        end
    end

endmodule
