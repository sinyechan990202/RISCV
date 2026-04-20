// EX/MEM Pipeline Register
// Spec: Notion RV32I RTL 설계 명세서 §5
module ex_mem_reg #(
    parameter XLEN = 32
) (
    input  logic             clk,
    input  logic             rst_n,

    // Hazard control — flush takes priority over stall
    input  logic             stall,
    input  logic             flush,

    // ── Inputs from EX stage ─────────────────────────────────────────
    input  logic [XLEN-1:0] alu_result_i,
    input  logic [XLEN-1:0] rs2_data_i,
    input  logic [XLEN-1:0] pc_plus4_i,
    input  logic [4:0]      rd_i,
    input  logic             mem_ren_i,
    input  logic             mem_wen_i,
    input  logic [2:0]      mem_size_i,
    input  logic [1:0]      wb_sel_i,
    input  logic             reg_wen_i,

    // ── Outputs to MEM stage ─────────────────────────────────────────
    output logic [XLEN-1:0] ex_mem_alu_result,
    output logic [XLEN-1:0] ex_mem_rs2_data,
    output logic [XLEN-1:0] ex_mem_pc_plus4,
    output logic [4:0]      ex_mem_rd,
    output logic             ex_mem_mem_ren,
    output logic             ex_mem_mem_wen,
    output logic [2:0]      ex_mem_mem_size,
    output logic [1:0]      ex_mem_wb_sel,
    output logic             ex_mem_reg_wen
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n || flush) begin
            ex_mem_alu_result <= {XLEN{1'b0}};
            ex_mem_rs2_data   <= {XLEN{1'b0}};
            ex_mem_pc_plus4   <= {XLEN{1'b0}};
            ex_mem_rd         <= 5'b0;
            ex_mem_mem_ren    <= 1'b0;
            ex_mem_mem_wen    <= 1'b0;
            ex_mem_mem_size   <= 3'b0;
            ex_mem_wb_sel     <= 2'b0;
            ex_mem_reg_wen    <= 1'b0;
        end else if (!stall) begin
            ex_mem_alu_result <= alu_result_i;
            ex_mem_rs2_data   <= rs2_data_i;
            ex_mem_pc_plus4   <= pc_plus4_i;
            ex_mem_rd         <= rd_i;
            ex_mem_mem_ren    <= mem_ren_i;
            ex_mem_mem_wen    <= mem_wen_i;
            ex_mem_mem_size   <= mem_size_i;
            ex_mem_wb_sel     <= wb_sel_i;
            ex_mem_reg_wen    <= reg_wen_i;
        end
    end

endmodule
