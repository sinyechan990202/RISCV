// EX Stage — instantiates alu, branch_unit, forwarding_unit
module ex_stage #(
    parameter XLEN = 32
) (
    // Datapath inputs (from ID/EX register)
    input  logic [XLEN-1:0] rs1_data_i,
    input  logic [XLEN-1:0] rs2_data_i,
    input  logic [XLEN-1:0] imm_i,
    input  logic [XLEN-1:0] pc_i,
    input  logic [4:0]      rs1_i,          // rs1 register address (for forwarding)
    input  logic [4:0]      rs2_i,          // rs2 register address (for forwarding)
    input  logic [4:0]      alu_op_i,
    input  logic            alu_src_a_i,    // 0=rs1, 1=pc  (AUIPC)
    input  logic            alu_src_b_i,    // 0=rs2, 1=imm
    input  logic [2:0]      funct3_i,
    input  logic            branch_i,
    input  logic            jal_i,
    input  logic            jalr_i,

    // Forwarding data
    input  logic [XLEN-1:0] ex_mem_data_i,  // EX→EX: MEM stage ALU result
    input  logic [XLEN-1:0] wb_rd_wdata_i,  // MEM→EX: WB stage write data

    // Forwarding control (from EX/MEM and MEM/WB stages)
    input  logic [4:0]      ex_mem_rd_i,
    input  logic            ex_mem_reg_wen_i,
    input  logic [4:0]      mem_wb_rd_i,
    input  logic            mem_wb_reg_wen_i,

    // Outputs
    output logic [XLEN-1:0] alu_result_o,
    output logic [XLEN-1:0] rs2_fwd_o,      // forwarded rs2 (for MEM stage store)
    output logic             branch_taken_o,
    output logic [XLEN-1:0] branch_target_o,
    output logic [XLEN-1:0] jal_target_o,
    output logic [XLEN-1:0] jalr_target_o
);

    // Forwarding MUX select signals
    logic [1:0] fwd_a_sel;
    logic [1:0] fwd_b_sel;

    // Forwarded operands
    logic [XLEN-1:0] rs1_fwd;
    logic [XLEN-1:0] rs2_fwd;

    // ALU inputs after src mux
    logic [XLEN-1:0] alu_a;
    logic [XLEN-1:0] alu_b;

    // -------------------------------------------------------
    // forwarding_unit
    // -------------------------------------------------------
    forwarding_unit u_fwd (
        .ex_rs1_i      (rs1_i),
        .ex_rs2_i      (rs2_i),
        .mem_rd_i      (ex_mem_rd_i),
        .mem_reg_wen_i (ex_mem_reg_wen_i),
        .wb_rd_i       (mem_wb_rd_i),
        .wb_reg_wen_i  (mem_wb_reg_wen_i),
        .fwd_a_sel_o   (fwd_a_sel),
        .fwd_b_sel_o   (fwd_b_sel)
    );

    // -------------------------------------------------------
    // Forwarding MUXes
    // -------------------------------------------------------
    always_comb begin
        unique case (fwd_a_sel)
            2'b10:   rs1_fwd = ex_mem_data_i;
            2'b01:   rs1_fwd = wb_rd_wdata_i;
            default: rs1_fwd = rs1_data_i;
        endcase

        unique case (fwd_b_sel)
            2'b10:   rs2_fwd = ex_mem_data_i;
            2'b01:   rs2_fwd = wb_rd_wdata_i;
            default: rs2_fwd = rs2_data_i;
        endcase
    end

    // -------------------------------------------------------
    // ALU source MUXes
    // -------------------------------------------------------
    always_comb begin
        alu_a = alu_src_a_i ? pc_i     : rs1_fwd;
        alu_b = alu_src_b_i ? imm_i    : rs2_fwd;
    end

    // -------------------------------------------------------
    // ALU
    // -------------------------------------------------------
    alu #(.XLEN(XLEN)) u_alu (
        .a_i      (alu_a),
        .b_i      (alu_b),
        .alu_op_i (alu_op_i),
        .result_o (alu_result_o)
    );

    // -------------------------------------------------------
    // Branch/Jump Unit
    // -------------------------------------------------------
    branch_unit #(.XLEN(XLEN)) u_branch (
        .rs1_i          (rs1_fwd),
        .rs2_i          (rs2_fwd),
        .pc_i           (pc_i),
        .imm_i          (imm_i),
        .funct3_i       (funct3_i),
        .branch_i       (branch_i),
        .jal_i          (jal_i),
        .jalr_i         (jalr_i),
        .branch_taken_o (branch_taken_o),
        .branch_target_o(branch_target_o),
        .jal_target_o   (jal_target_o),
        .jalr_target_o  (jalr_target_o)
    );

    assign rs2_fwd_o = rs2_fwd;

endmodule
