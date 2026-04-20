// Pure combinational Hazard Detection & Control Unit
// Handles: Load-Use stall, control hazard flush, trap flush, memory-not-ready stall
module hazard_unit (
    // Load-Use hazard detection
    input  logic       ex_mem_ren,   // EX stage: load instruction in flight
    input  logic [4:0] ex_rd,        // EX stage: destination register
    input  logic [4:0] id_rs1,       // ID stage: source register 1
    input  logic [4:0] id_rs2,       // ID stage: source register 2

    // Control hazard
    input  logic       branch_taken,
    input  logic       ex_jal,
    input  logic       ex_jalr,

    // Trap
    input  logic       trap_en,

    // Memory back-pressure
    input  logic       imem_ready,
    input  logic       dmem_ready,

    // Stall outputs (active-high)
    output logic       stall_if,
    output logic       stall_id,

    // Flush outputs (active-high, inserts NOP)
    output logic       flush_id,
    output logic       flush_ex,
    output logic       flush_mem,
    output logic       flush_wb,

    // PC select: 00=PC+4, 01=branch_target, 10=jal_target, 11=jalr_target
    output logic [1:0] pc_sel
);

    logic load_use_hazard;
    logic control_hazard;
    logic mem_not_ready;

    always_comb begin
        load_use_hazard = ex_mem_ren
                        & (ex_rd != 5'b0)
                        & ((ex_rd == id_rs1) | (ex_rd == id_rs2));

        control_hazard  = branch_taken | ex_jal | ex_jalr;
        mem_not_ready   = ~imem_ready | ~dmem_ready;

        // --------------------------------------------------
        // Stall: load-use or memory back-pressure
        // --------------------------------------------------
        stall_if = load_use_hazard | mem_not_ready;
        stall_id = load_use_hazard | mem_not_ready;

        // --------------------------------------------------
        // Flush: trap takes priority over all
        // --------------------------------------------------
        if (trap_en) begin
            flush_id  = 1'b1;
            flush_ex  = 1'b1;
            flush_mem = 1'b1;
            flush_wb  = 1'b1;
        end else begin
            flush_id  = control_hazard;
            flush_ex  = load_use_hazard;
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
