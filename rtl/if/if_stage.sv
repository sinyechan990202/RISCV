// IF Stage Logic — Instruction Fetch
// Spec: Notion RV32I RTL 설계 명세서 §4.1
module if_stage #(
    parameter XLEN = 32
) (
    input  logic             clk,
    input  logic             rst_n,

    // Hazard control
    input  logic             stall,

    // PC source select (from hazard_unit / branch_unit)
    // 2'b00 = PC+4, 2'b01 = branch_target, 2'b10 = jal_target, 2'b11 = jalr_target
    input  logic [1:0]       pc_sel,

    // Redirect targets (from EX stage)
    input  logic [XLEN-1:0] branch_target,
    input  logic [XLEN-1:0] jal_target,
    input  logic [XLEN-1:0] jalr_target,

    // Instruction memory interface
    input  logic             imem_ready,
    input  logic [XLEN-1:0] imem_rdata,
    output logic             imem_req,
    output logic [XLEN-1:0] imem_addr,

    // Pipeline outputs to IF/ID register
    output logic [XLEN-1:0] pc_o,
    output logic [XLEN-1:0] pc_plus4_o,
    output logic [XLEN-1:0] instr_o,
    output logic             if_valid
);

    // ADDI x0, x0, 0 — canonical NOP
    localparam logic [31:0] NOP = 32'h0000_0013;

    logic [XLEN-1:0] pc_current;
    logic [XLEN-1:0] pc_next;
    logic            flush;

    // Redirect takes priority over stall
    assign flush = (pc_sel != 2'b00);

    // PC mux
    always_comb begin
        case (pc_sel)
            2'b01:   pc_next = branch_target;
            2'b10:   pc_next = jal_target;
            2'b11:   pc_next = jalr_target;
            default: pc_next = pc_current + {{(XLEN-3){1'b0}}, 3'd4};
        endcase
    end

    // PC register — flush overrides stall so redirect always commits
    pc_reg #(
        .XLEN(XLEN)
    ) u_pc_reg (
        .clk    (clk),
        .rst_n  (rst_n),
        .stall  (stall && !flush),
        .pc_next(pc_next),
        .pc     (pc_current)
    );

    // Always-on fetch request
    assign imem_req  = 1'b1;
    assign imem_addr = pc_current;

    assign pc_o       = pc_current;
    assign pc_plus4_o = pc_current + {{(XLEN-3){1'b0}}, 3'd4};

    // Insert NOP on flush (wrong-path instruction) or when memory not ready
    assign instr_o  = (flush || !imem_ready) ? NOP : imem_rdata;
    assign if_valid = imem_ready && !flush;

endmodule
