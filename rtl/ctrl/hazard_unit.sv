// Pure combinational Hazard Detection & Control Unit
// Handles: Load-Use stall, CSR RAW stall, control hazard flush, trap flush, memory-not-ready stall
module hazard_unit (
    // Load-Use hazard detection
    input  logic       ex_mem_ren,   // EX stage: load instruction in flight
    input  logic [4:0] ex_rd,        // EX stage: destination register
    input  logic [4:0] id_rs1,       // ID stage: source register 1
    input  logic [4:0] id_rs2,       // ID stage: source register 2

    // CSR RAW stall: reg_file has WB→ID bypass, so only EX/MEM need stalling
    input  logic       id_csr_uses_rs1, // ID has a CSR instr that reads rs1 (non-ZIMM)
    input  logic       ex_reg_wen,      // EX stage writes a register
    input  logic [4:0] mem_rd,          // MEM stage destination register
    input  logic       mem_reg_wen,     // MEM stage writes a register

    // Control hazard
    input  logic       branch_taken,
    input  logic       ex_jal,
    input  logic       ex_jalr,

    // Trap
    input  logic       trap_en,

    // Memory back-pressure
    input  logic       imem_ready,
    input  logic       dmem_ready,
    input  logic       dmem_active,  // EX/MEM stage has an active load or store

    // Stall outputs (active-high)
    output logic       stall_if,
    output logic       stall_id,
    // Full-pipeline stall (memory back-pressure only, not load-use)
    output logic       stall_ex,
    output logic       stall_mem,
    output logic       stall_wb,

    // Flush outputs (active-high, inserts NOP)
    output logic       flush_id,
    output logic       flush_ex,
    output logic       flush_mem,
    output logic       flush_wb,

    // PC select: 00=PC+4, 01=branch_target, 10=jal_target, 11=jalr_target
    output logic [1:0] pc_sel
);

    logic load_use_hazard;
    logic csr_raw_hazard;
    logic control_hazard;
    logic mem_not_ready;

    always_comb begin
        load_use_hazard = ex_mem_ren
                        & (ex_rd != 5'b0)
                        & ((ex_rd == id_rs1) | (ex_rd == id_rs2));

        // CSR rs1 cannot be forwarded (write occurs inside ID).
        // Stall until the pending writer reaches WB where reg_file bypass takes over.
        csr_raw_hazard  = id_csr_uses_rs1
                        & (id_rs1 != 5'b0)
                        & ((ex_reg_wen  & (ex_rd  != 5'b0) & (ex_rd  == id_rs1))
                         | (mem_reg_wen & (mem_rd != 5'b0) & (mem_rd == id_rs1)));

        control_hazard  = branch_taken | ex_jal | ex_jalr;
        // dmem stall only when a load/store is actually in the MEM stage
        mem_not_ready   = ~imem_ready | (~dmem_ready & dmem_active);

        // --------------------------------------------------
        // Stall: load-use, CSR RAW, or memory back-pressure
        // --------------------------------------------------
        stall_if  = load_use_hazard | csr_raw_hazard | mem_not_ready;
        stall_id  = load_use_hazard | csr_raw_hazard | mem_not_ready;
        // EX/MEM/WB stall only on memory back-pressure
        stall_ex  = mem_not_ready;
        stall_mem = mem_not_ready;
        stall_wb  = mem_not_ready;

        // --------------------------------------------------
        // Flush policy
        //  - Trap (precise): only kill younger instructions (IF/ID, ID/EX).
        //    In-flight instructions in MEM/WB must retire normally per
        //    RISC-V precise-trap semantics.
        //  - Control hazard (branch/jal/jalr): the wrong-path instruction
        //    sits in ID AND will be latched into ID/EX next edge, so both
        //    IF/ID and ID/EX must be flushed.
        //  - Load-use / CSR RAW: bubble into EX (flush_ex) while holding IF/ID.
        // --------------------------------------------------
        // Suppress all flushes when the pipeline is frozen due to memory stall.
        // When mem_not_ready=1 the whole pipeline is held in place; inserting a
        // bubble via flush while stall_mem=1 would destroy the instruction currently
        // in EX before ex_mem_reg can capture it (stall beats capture).
        // The hazard condition persists across the freeze and fires correctly once
        // mem_not_ready drops.
        if (trap_en) begin
            flush_id  = ~mem_not_ready;
            flush_ex  = ~mem_not_ready;
            flush_mem = 1'b0;
            flush_wb  = 1'b0;
        end else begin
            flush_id  = control_hazard & ~mem_not_ready;
            flush_ex  = (load_use_hazard | csr_raw_hazard | control_hazard) & ~mem_not_ready;
            flush_mem = 1'b0;
            flush_wb  = 1'b0;
        end

        // --------------------------------------------------
        // PC select (overridden by trap logic in TOP)
        // --------------------------------------------------
        if (branch_taken)
            pc_sel = 2'b01;
        else if (ex_jal)
            pc_sel = 2'b10;
        else if (ex_jalr)
            pc_sel = 2'b11;
        else
            pc_sel = 2'b00;
    end

endmodule
