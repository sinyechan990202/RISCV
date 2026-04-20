module if_id_reg #(
    parameter XLEN        = 32,
    parameter IMEM_DWIDTH = 32
) (
    input  logic                   clk,
    input  logic                   rst_n,

    // Hazard control
    input  logic                   stall,   // from hazard_unit: if_stall
    input  logic                   flush,   // from hazard_unit: id_flush

    // From IF stage
    input  logic [XLEN-1:0]        pc_i,
    input  logic [XLEN-1:0]        pc_plus4_i,
    input  logic [IMEM_DWIDTH-1:0] instr_i,
    input  logic                   valid_i,

    // To ID stage
    output logic [XLEN-1:0]        if_id_pc,
    output logic [XLEN-1:0]        if_id_pc_plus4,
    output logic [IMEM_DWIDTH-1:0] if_id_instr,
    output logic                   if_id_valid
);

    localparam NOP = 32'h0000_0013; // ADDI x0, x0, 0

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            if_id_pc       <= {XLEN{1'b0}};
            if_id_pc_plus4 <= {XLEN{1'b0}};
            if_id_instr    <= NOP;
            if_id_valid    <= 1'b0;
        end else if (flush) begin
            if_id_pc       <= {XLEN{1'b0}};
            if_id_pc_plus4 <= {XLEN{1'b0}};
            if_id_instr    <= NOP;
            if_id_valid    <= 1'b0;
        end else if (!stall) begin
            if_id_pc       <= pc_i;
            if_id_pc_plus4 <= pc_plus4_i;
            if_id_instr    <= instr_i;
            if_id_valid    <= valid_i;
        end
    end

endmodule
