// MEM/WB Pipeline Register
// Spec: Notion RV32I RTL 설계 명세서 §5
module mem_wb_reg #(
    parameter XLEN = 32
) (
    input  logic             clk,
    input  logic             rst_n,

    // Hazard control — flush takes priority over stall
    input  logic             stall,
    input  logic             flush,

    // ── Inputs from MEM stage ────────────────────────────────────────
    input  logic [XLEN-1:0] alu_result_i,
    input  logic [XLEN-1:0] load_data_i,
    input  logic [XLEN-1:0] pc_plus4_i,
    input  logic [4:0]      rd_i,
    input  logic [1:0]      wb_sel_i,
    input  logic             reg_wen_i,

    // ── Outputs to WB stage ──────────────────────────────────────────
    output logic [XLEN-1:0] mem_wb_alu_result,
    output logic [XLEN-1:0] mem_wb_load_data,
    output logic [XLEN-1:0] mem_wb_pc_plus4,
    output logic [4:0]      mem_wb_rd,
    output logic [1:0]      mem_wb_wb_sel,
    output logic             mem_wb_reg_wen
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n || flush) begin
            mem_wb_alu_result <= {XLEN{1'b0}};
            mem_wb_load_data  <= {XLEN{1'b0}};
            mem_wb_pc_plus4   <= {XLEN{1'b0}};
            mem_wb_rd         <= 5'b0;
            mem_wb_wb_sel     <= 2'b0;
            mem_wb_reg_wen    <= 1'b0;
        end else if (!stall) begin
            mem_wb_alu_result <= alu_result_i;
            mem_wb_load_data  <= load_data_i;
            mem_wb_pc_plus4   <= pc_plus4_i;
            mem_wb_rd         <= rd_i;
            mem_wb_wb_sel     <= wb_sel_i;
            mem_wb_reg_wen    <= reg_wen_i;
        end
    end

endmodule
