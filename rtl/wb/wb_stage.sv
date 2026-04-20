// WB Stage Logic — Write-Back
// Spec: Notion RV32I RTL 설계 명세서 §4.5
// Pure combinational: selects write-back data and drives register file
module wb_stage #(
    parameter XLEN = 32
) (
    // ── Inputs from MEM/WB register ──────────────────────────────────
    input  logic [XLEN-1:0] alu_result_i,
    input  logic [XLEN-1:0] load_data_i,
    input  logic [XLEN-1:0] pc_plus4_i,
    input  logic [4:0]      rd_i,
    input  logic [1:0]      wb_sel_i,
    input  logic             reg_wen_i,

    // ── Outputs to reg_file ──────────────────────────────────────────
    output logic [4:0]      rd_addr_o,
    output logic [XLEN-1:0] rd_wdata_o,
    output logic             rd_wen_o
);

    // wb_sel encoding: 2'b00=ALU, 2'b01=Load, 2'b10=PC+4 (JAL/JALR link)
    always_comb begin
        case (wb_sel_i)
            2'b01:   rd_wdata_o = load_data_i;
            2'b10:   rd_wdata_o = pc_plus4_i;
            default: rd_wdata_o = alu_result_i;
        endcase
    end

    assign rd_addr_o = rd_i;
    assign rd_wen_o  = reg_wen_i;

endmodule
