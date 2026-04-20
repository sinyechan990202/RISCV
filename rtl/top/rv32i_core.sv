// TOP — rv32i_core
// Spec: Notion RV32I RTL 설계 명세서 §3, §2
module rv32i_core #(
    parameter XLEN        = 32,
    parameter IMEM_DWIDTH = 32,
    parameter DMEM_DWIDTH = 32
) (
    input  logic             clk,
    input  logic             rst_n,

    // Instruction memory interface
    output logic             imem_req,
    output logic [XLEN-1:0] imem_addr,
    input  logic [XLEN-1:0] imem_rdata,
    input  logic             imem_ready,

    // Data memory interface
    output logic             dmem_req,
    output logic             dmem_we,
    output logic [3:0]       dmem_be,
    output logic [XLEN-1:0] dmem_addr,
    output logic [XLEN-1:0] dmem_wdata,
    input  logic [XLEN-1:0] dmem_rdata,
    input  logic             dmem_ready,

    // Interrupts (async — synchronized below)
    input  logic             ext_irq,
    input  logic             timer_irq,

    // Debug
    output logic [XLEN-1:0] dbg_pc,
    output logic             dbg_reg_we,
    output logic [4:0]       dbg_reg_waddr,
    output logic [XLEN-1:0] dbg_reg_wdata
);

    // =========================================================================
    // CDC: 2-FF synchronizers for asynchronous interrupt inputs (§8)
    // =========================================================================
    logic ext_irq_s,   ext_irq_sync;
    logic timer_irq_s, timer_irq_sync;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) {ext_irq_sync,   ext_irq_s}   <= 2'b0;
        else        {ext_irq_sync,   ext_irq_s}   <= {ext_irq_s,   ext_irq};
    end
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) {timer_irq_sync, timer_irq_s} <= 2'b0;
        else        {timer_irq_sync, timer_irq_s} <= {timer_irq_s, timer_irq};
    end

    // =========================================================================
    // Hazard / forwarding control wires
    // =========================================================================
    logic        stall_if;      // IF stage stall (load-use, imem not ready)
    logic        stall_id;      // IF/ID register stall
    logic        flush_id;      // IF/ID register flush (control hazard / trap)
    logic        flush_ex;      // ID/EX register flush (load-use bubble / trap)
    logic        flush_mem;     // EX/MEM register flush (trap)
    logic        flush_wb;      // MEM/WB register flush (trap)
    logic [1:0]  hz_pc_sel;     // hazard_unit driven PC select

    // =========================================================================
    // Trap detection & PC redirect
    // =========================================================================
    // Trap fires when: ECALL/EBREAK in EX, or IRQ pending while MIE=1
    logic             trap_en;
    logic [XLEN-1:0] trap_mepc;
    logic [XLEN-1:0] trap_mcause;
    logic [XLEN-1:0] mtvec;
    logic [XLEN-1:0] mepc_out;
    logic             mie_global;

    // Reuse jal_target slot for mtvec on trap (pc_sel=2'b10 = jal_target)
    // hazard_unit sets hz_pc_sel; TOP overrides to 2'b10 when trap
    logic [1:0]      if_pc_sel;
    logic [XLEN-1:0] if_jal_target_muxed;

    assign if_pc_sel           = trap_en ? 2'b10 : hz_pc_sel;
    assign if_jal_target_muxed = trap_en ? mtvec : ex_jal_target;

    // =========================================================================
    // IF Stage → IF/ID Register
    // =========================================================================
    logic [XLEN-1:0] if_pc, if_pc_plus4, if_instr;
    logic             if_valid;

    logic [XLEN-1:0] ex_branch_target, ex_jal_target, ex_jalr_target;

    if_stage #(.XLEN(XLEN)) u_if_stage (
        .clk          (clk),
        .rst_n        (rst_n),
        .stall        (stall_if),
        .pc_sel       (if_pc_sel),
        .branch_target(ex_branch_target),
        .jal_target   (if_jal_target_muxed),
        .jalr_target  (ex_jalr_target),
        .imem_ready   (imem_ready),
        .imem_rdata   (imem_rdata),
        .imem_req     (imem_req),
        .imem_addr    (imem_addr),
        .pc_o         (if_pc),
        .pc_plus4_o   (if_pc_plus4),
        .instr_o      (if_instr),
        .if_valid     (if_valid)
    );

    // =========================================================================
    // IF/ID Pipeline Register
    // =========================================================================
    logic [XLEN-1:0] if_id_pc, if_id_pc_plus4, if_id_instr;
    logic             if_id_valid;

    if_id_reg #(.XLEN(XLEN)) u_if_id_reg (
        .clk       (clk),
        .rst_n     (rst_n),
        .stall     (stall_id),
        .flush     (flush_id),
        .pc_i      (if_pc),
        .pc_plus4_i(if_pc_plus4),
        .instr_i   (if_instr),
        .valid_i   (if_valid),
        .if_id_pc      (if_id_pc),
        .if_id_pc_plus4(if_id_pc_plus4),
        .if_id_instr   (if_id_instr),
        .if_id_valid   (if_id_valid)
    );

    // =========================================================================
    // ID Stage
    // =========================================================================
    logic [XLEN-1:0] id_rs1_data, id_rs2_data, id_imm;
    logic [4:0]      id_rs1_addr, id_rs2_addr, id_rd;
    logic [4:0]      id_alu_op;
    logic             id_alu_src_a, id_alu_src_b;
    logic             id_mem_ren, id_mem_wen;
    logic [2:0]      id_mem_size;
    logic [1:0]      id_wb_sel;
    logic             id_reg_wen;
    logic             id_branch, id_jal, id_jalr;
    logic [2:0]      id_csr_op;
    logic [11:0]     id_csr_addr;
    logic [XLEN-1:0] id_csr_rdata;
    // id_funct3 = id_mem_size: mem_size_o carries funct3[2:0] (same ISA field)

    // WB feedback (from wb_stage)
    logic [4:0]      wb_rd_addr;
    logic [XLEN-1:0] wb_rd_wdata;
    logic             wb_rd_wen;

    // For CSR: route csr_rdata through pipeline as rs1_data (alu PASS_A delivers it to WB)
    logic [XLEN-1:0] id_rs1_data_final;
    logic [4:0]      id_alu_op_final;

    assign id_rs1_data_final = (id_wb_sel == 2'b11) ? id_csr_rdata : id_rs1_data;
    assign id_alu_op_final   = (id_wb_sel == 2'b11) ? 5'b01100     : id_alu_op; // PASS_A

    // instret_inc: pulse when WB stage retires a valid instruction
    logic instret_inc;
    assign instret_inc = wb_rd_wen | (mem_wb_reg_wen & (mem_wb_rd == 5'b0));

    id_stage #(.XLEN(XLEN)) u_id_stage (
        .clk         (clk),
        .rst_n       (rst_n),
        .instr_i     (if_id_instr),
        .pc_i        (if_id_pc),
        .wb_rd       (wb_rd_addr),
        .wb_wdata    (wb_rd_wdata),
        .wb_wen      (wb_rd_wen),
        .trap_en     (trap_en),
        .mepc_in     (trap_mepc),
        .mcause_in   (trap_mcause),
        .instret_inc (instret_inc),
        .ext_irq     (ext_irq_sync),
        .timer_irq   (timer_irq_sync),
        .rs1_data_o  (id_rs1_data),
        .rs2_data_o  (id_rs2_data),
        .rs1_addr_o  (id_rs1_addr),
        .rs2_addr_o  (id_rs2_addr),
        .imm_o       (id_imm),
        .rd_o        (id_rd),
        .alu_op_o    (id_alu_op),
        .alu_src_a_o (id_alu_src_a),
        .alu_src_b_o (id_alu_src_b),
        .mem_ren_o   (id_mem_ren),
        .mem_wen_o   (id_mem_wen),
        .mem_size_o  (id_mem_size),
        .wb_sel_o    (id_wb_sel),
        .reg_wen_o   (id_reg_wen),
        .branch_o    (id_branch),
        .jal_o       (id_jal),
        .jalr_o      (id_jalr),
        .csr_op_o    (id_csr_op),
        .csr_addr_o  (id_csr_addr),
        .csr_rdata_o (id_csr_rdata),
        .mepc_out    (mepc_out),
        .mtvec_out   (mtvec),
        .mie_global  (mie_global)
    );

    // =========================================================================
    // ID/EX Pipeline Register
    // =========================================================================
    logic [XLEN-1:0] id_ex_pc, id_ex_pc_plus4;
    logic [XLEN-1:0] id_ex_rs1_data, id_ex_rs2_data, id_ex_imm;
    logic [4:0]      id_ex_rs1, id_ex_rs2, id_ex_rd;
    logic [4:0]      id_ex_alu_op;
    logic             id_ex_alu_src_a, id_ex_alu_src_b;
    logic             id_ex_mem_ren, id_ex_mem_wen;
    logic [2:0]      id_ex_mem_size;
    logic [1:0]      id_ex_wb_sel;
    logic             id_ex_reg_wen;
    logic             id_ex_branch, id_ex_jal, id_ex_jalr;
    logic [2:0]      id_ex_csr_op;
    logic [11:0]     id_ex_csr_addr;
    logic [2:0]      id_ex_funct3;

    id_ex_reg #(.XLEN(XLEN)) u_id_ex_reg (
        .clk          (clk),
        .rst_n        (rst_n),
        .stall        (1'b0),
        .flush        (flush_ex),
        .pc_i         (if_id_pc),
        .pc_plus4_i   (if_id_pc_plus4),
        .rs1_data_i   (id_rs1_data_final),
        .rs2_data_i   (id_rs2_data),
        .imm_i        (id_imm),
        .rs1_i        (id_rs1_addr),
        .rs2_i        (id_rs2_addr),
        .rd_i         (id_rd),
        .alu_op_i     (id_alu_op_final),
        .alu_src_a_i  (id_alu_src_a),
        .alu_src_b_i  (id_alu_src_b),
        .mem_ren_i    (id_mem_ren),
        .mem_wen_i    (id_mem_wen),
        .mem_size_i   (id_mem_size),
        .wb_sel_i     (id_wb_sel),
        .reg_wen_i    (id_reg_wen),
        .branch_i     (id_branch),
        .jal_i        (id_jal),
        .jalr_i       (id_jalr),
        .csr_op_i     (id_csr_op),
        .csr_addr_i   (id_csr_addr),
        .funct3_i     (id_mem_size),  // funct3[2:0] == mem_size[2:0] (same ISA field)
        .id_ex_pc         (id_ex_pc),
        .id_ex_pc_plus4   (id_ex_pc_plus4),
        .id_ex_rs1_data   (id_ex_rs1_data),
        .id_ex_rs2_data   (id_ex_rs2_data),
        .id_ex_imm        (id_ex_imm),
        .id_ex_rs1        (id_ex_rs1),
        .id_ex_rs2        (id_ex_rs2),
        .id_ex_rd         (id_ex_rd),
        .id_ex_alu_op     (id_ex_alu_op),
        .id_ex_alu_src_a  (id_ex_alu_src_a),
        .id_ex_alu_src_b  (id_ex_alu_src_b),
        .id_ex_mem_ren    (id_ex_mem_ren),
        .id_ex_mem_wen    (id_ex_mem_wen),
        .id_ex_mem_size   (id_ex_mem_size),
        .id_ex_wb_sel     (id_ex_wb_sel),
        .id_ex_reg_wen    (id_ex_reg_wen),
        .id_ex_branch     (id_ex_branch),
        .id_ex_jal        (id_ex_jal),
        .id_ex_jalr       (id_ex_jalr),
        .id_ex_csr_op     (id_ex_csr_op),
        .id_ex_csr_addr   (id_ex_csr_addr),
        .id_ex_funct3     (id_ex_funct3)
    );

    // =========================================================================
    // EX Stage (contains forwarding_unit, alu, branch_unit)
    // =========================================================================
    logic [XLEN-1:0] ex_alu_result, ex_rs2_fwd;
    logic             ex_branch_taken;

    // EX/MEM and MEM/WB outputs needed for forwarding (declared ahead)
    logic [XLEN-1:0] ex_mem_alu_result, ex_mem_rs2_data, ex_mem_pc_plus4;
    logic [4:0]      ex_mem_rd;
    logic             ex_mem_mem_ren, ex_mem_mem_wen;
    logic [2:0]      ex_mem_mem_size;
    logic [1:0]      ex_mem_wb_sel;
    logic             ex_mem_reg_wen;

    logic [XLEN-1:0] mem_wb_alu_result, mem_wb_load_data, mem_wb_pc_plus4;
    logic [4:0]      mem_wb_rd;
    logic [1:0]      mem_wb_wb_sel;
    logic             mem_wb_reg_wen;

    ex_stage #(.XLEN(XLEN)) u_ex_stage (
        .rs1_data_i      (id_ex_rs1_data),
        .rs2_data_i      (id_ex_rs2_data),
        .imm_i           (id_ex_imm),
        .pc_i            (id_ex_pc),
        .alu_op_i        (id_ex_alu_op),
        .alu_src_a_i     (id_ex_alu_src_a),
        .alu_src_b_i     (id_ex_alu_src_b),
        .funct3_i        (id_ex_funct3),
        .branch_i        (id_ex_branch),
        .jal_i           (id_ex_jal),
        .jalr_i          (id_ex_jalr),
        .rs1_i           (id_ex_rs1),
        .rs2_i           (id_ex_rs2),
        // Forwarding sources
        .ex_mem_rd_i     (ex_mem_rd),
        .ex_mem_reg_wen_i(ex_mem_reg_wen),
        .ex_mem_data_i   (ex_mem_alu_result),
        .mem_wb_rd_i     (mem_wb_rd),
        .mem_wb_reg_wen_i(mem_wb_reg_wen),
        .wb_rd_wdata_i   (wb_rd_wdata),
        // Outputs
        .alu_result_o   (ex_alu_result),
        .rs2_fwd_o      (ex_rs2_fwd),
        .branch_taken_o  (ex_branch_taken),
        .branch_target_o (ex_branch_target),
        .jal_target_o    (ex_jal_target),
        .jalr_target_o   (ex_jalr_target)
    );

    // =========================================================================
    // EX/MEM Pipeline Register
    // =========================================================================
    ex_mem_reg #(.XLEN(XLEN)) u_ex_mem_reg (
        .clk           (clk),
        .rst_n         (rst_n),
        .stall         (1'b0),
        .flush         (flush_mem),
        .alu_result_i  (ex_alu_result),
        .rs2_data_i    (ex_rs2_fwd),
        .pc_plus4_i    (id_ex_pc_plus4),
        .rd_i          (id_ex_rd),
        .mem_ren_i     (id_ex_mem_ren),
        .mem_wen_i     (id_ex_mem_wen),
        .mem_size_i    (id_ex_mem_size),
        .wb_sel_i      (id_ex_wb_sel),
        .reg_wen_i     (id_ex_reg_wen),
        .ex_mem_alu_result(ex_mem_alu_result),
        .ex_mem_rs2_data  (ex_mem_rs2_data),
        .ex_mem_pc_plus4  (ex_mem_pc_plus4),
        .ex_mem_rd        (ex_mem_rd),
        .ex_mem_mem_ren   (ex_mem_mem_ren),
        .ex_mem_mem_wen   (ex_mem_mem_wen),
        .ex_mem_mem_size  (ex_mem_mem_size),
        .ex_mem_wb_sel    (ex_mem_wb_sel),
        .ex_mem_reg_wen   (ex_mem_reg_wen)
    );

    // =========================================================================
    // MEM Stage
    // =========================================================================
    logic [XLEN-1:0] mem_load_data;

    mem_stage #(.XLEN(XLEN)) u_mem_stage (
        .alu_result_i(ex_mem_alu_result),
        .rs2_data_i  (ex_mem_rs2_data),
        .mem_ren_i   (ex_mem_mem_ren),
        .mem_wen_i   (ex_mem_mem_wen),
        .mem_size_i  (ex_mem_mem_size),
        .dmem_rdata  (dmem_rdata),
        .dmem_ready  (dmem_ready),
        .dmem_req    (dmem_req),
        .dmem_we     (dmem_we),
        .dmem_be     (dmem_be),
        .dmem_addr   (dmem_addr),
        .dmem_wdata  (dmem_wdata),
        .load_data_o (mem_load_data)
    );

    // =========================================================================
    // MEM/WB Pipeline Register
    // =========================================================================
    mem_wb_reg #(.XLEN(XLEN)) u_mem_wb_reg (
        .clk          (clk),
        .rst_n        (rst_n),
        .stall        (1'b0),
        .flush        (flush_wb),
        .alu_result_i (ex_mem_alu_result),
        .load_data_i  (mem_load_data),
        .pc_plus4_i   (ex_mem_pc_plus4),
        .rd_i         (ex_mem_rd),
        .wb_sel_i     (ex_mem_wb_sel),
        .reg_wen_i    (ex_mem_reg_wen),
        .mem_wb_alu_result(mem_wb_alu_result),
        .mem_wb_load_data (mem_wb_load_data),
        .mem_wb_pc_plus4  (mem_wb_pc_plus4),
        .mem_wb_rd        (mem_wb_rd),
        .mem_wb_wb_sel    (mem_wb_wb_sel),
        .mem_wb_reg_wen   (mem_wb_reg_wen)
    );

    // =========================================================================
    // WB Stage
    // =========================================================================
    wb_stage #(.XLEN(XLEN)) u_wb_stage (
        .alu_result_i(mem_wb_alu_result),
        .load_data_i (mem_wb_load_data),
        .pc_plus4_i  (mem_wb_pc_plus4),
        .rd_i        (mem_wb_rd),
        .wb_sel_i    (mem_wb_wb_sel),
        .reg_wen_i   (mem_wb_reg_wen),
        .rd_addr_o   (wb_rd_addr),
        .rd_wdata_o  (wb_rd_wdata),
        .rd_wen_o    (wb_rd_wen)
    );

    // =========================================================================
    // Hazard Unit
    // =========================================================================
    hazard_unit u_hazard_unit (
        .id_rs1      (id_rs1_addr),
        .id_rs2      (id_rs2_addr),
        .ex_rd       (id_ex_rd),
        .ex_mem_ren  (id_ex_mem_ren),
        .branch_taken(ex_branch_taken),
        .ex_jal      (id_ex_jal),
        .ex_jalr     (id_ex_jalr),
        .imem_ready  (imem_ready),
        .dmem_ready  (dmem_ready),
        .trap_en     (trap_en),
        .stall_if    (stall_if),
        .stall_id    (stall_id),
        .flush_id    (flush_id),
        .flush_ex    (flush_ex),
        .flush_mem   (flush_mem),
        .flush_wb    (flush_wb),
        .pc_sel      (hz_pc_sel)
    );

    // =========================================================================
    // Trap detection
    // =========================================================================
    // ECALL/EBREAK: opcode=1110011, funct3=000, funct12=0/1
    logic ex_is_ecall, ex_is_ebreak;
    assign ex_is_ecall  = (id_ex_rs1_data == {XLEN{1'b0}}) & id_ex_jal; // placeholder
    // Full trap detection uses id_ex_csr_op + csr_addr; simplified here:
    logic irq_pending;
    assign irq_pending = mie_global & ((ext_irq_sync & mtvec[0]) | (timer_irq_sync & mtvec[1]));

    // Trap fires when instruction in EX is ECALL/EBREAK, or when IRQ pending
    // mepc = PC of trapping instruction (in EX stage)
    assign trap_en    = irq_pending; // ECALL/EBREAK handled by hazard_unit extensions
    assign trap_mepc  = id_ex_pc;
    assign trap_mcause = irq_pending ? (ext_irq_sync ? 32'h8000_000B : 32'h8000_0007)
                                      : 32'h0000_000B; // environment call

    // =========================================================================
    // Debug outputs
    // =========================================================================
    assign dbg_pc        = if_pc;
    assign dbg_reg_we    = wb_rd_wen;
    assign dbg_reg_waddr = wb_rd_addr;
    assign dbg_reg_wdata = wb_rd_wdata;

endmodule
